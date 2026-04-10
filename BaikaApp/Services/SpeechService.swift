//
//  SpeechService.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 8.04.2026.
//

import AVFoundation
import UIKit
import FirebaseFunctions
import FirebaseStorage

// MARK: - Delegate

protocol SpeechServiceDelegate: AnyObject {
    func speechDidStart()
    func speechDidHighlight(characterRange: NSRange, sentenceRange: NSRange)
    func speechDidFinish()
}

// MARK: - Chunk model

private struct AudioChunk {
    let index: Int
    let text: String
    let startOffset: Int   // fullText içindeki başlangıç karakter pozisyonu
    var data: Data?
    var isReady: Bool { data != nil }
}

// MARK: - SpeechService

class SpeechService: NSObject {

    // MARK: - Public

    weak var delegate: SpeechServiceDelegate?

    /// İlk chunk yüklenmeye başladığında true, oynatma başladığında false çağrılır.
    /// (Sadece ilk chunk için tetiklenir — sonraki chunk'lar arka planda sessizce hazırlanır.)
    var onLoadingStateChanged: ((Bool) -> Void)?

    private lazy var functions = Functions.functions(region: "us-central1")
    private var audioPlayer: AVAudioPlayer?
    private(set) var fullText: String = ""

    private(set) var isLoading: Bool = false {
        didSet {
            guard oldValue != isLoading else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.onLoadingStateChanged?(self.isLoading)
            }
        }
    }

    var isSpeaking: Bool { audioPlayer?.isPlaying ?? false }
    var isPaused: Bool {
        guard let player = audioPlayer else { return false }
        return !player.isPlaying && player.currentTime > 0
    }

    // MARK: - Private - Chunk state

    private var chunks: [AudioChunk] = []            // Tüm chunk'lar sıralı
    private var nextPlayIndex: Int = 0               // Sıradaki oynatılacak chunk
    private var activeRequestCount: Int = 0          // Ağda uçan istek sayısı
    private let chunkQueue = DispatchQueue(label: "com.baikaapp.speechchunkqueue", qos: .userInitiated)

    // Birden fazla eşzamanlı isteği geçersiz kılmak için session ID
    private var sessionID: UUID?

    // Firestore story session
    private var currentStoryID: String?
    private var currentVoice: VoiceOption = .defaultVoice

    // MARK: - Private - Playback

    private var highlightTimer: Timer?
    private var wordRanges: [(range: NSRange, time: TimeInterval, chunkOffset: Int)] = []
    private var currentHighlightIndex: Int = 0
    private var playingChunkOffset: Int = 0          // Oynatılan chunk'ın fullText içindeki başlangıç offset'i

    // MARK: - Private - Background

    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    // MARK: - Private - Cache

    private let cacheManager = AudioCacheManager.shared
    
    /// true olduğunda chunk'lar sadece cache'e yazılır, ses çıkmaz.
    /// PlayerVC'deki prefetchService bu modda kullanılır.
    var prefetchOnly: Bool = false

    // MARK: - Init

    override init() { super.init() }

    // MARK: - Public API — AI hikayeler

    func startSpeaking(text: String) {
        guard soundEnabled else { delegate?.speechDidFinish(); return }
        launchSession(text: text, storyID: nil)
    }

    // MARK: - Public API — Firestore hikayeler

    func startSpeakingForStory(text: String, storyID: String) {
        guard soundEnabled else { delegate?.speechDidFinish(); return }
        launchSession(text: text, storyID: storyID)
    }

    // MARK: - Public API — Kaydedilmiş AI hikaye (Storage path'i biliniyor)

    func startSpeakingFromStorage(text: String, storagePath: String) {
        guard soundEnabled else { delegate?.speechDidFinish(); return }

        resetSession()
        fullText = text
        isLoading = true

        let sid = sessionID!
        let cacheKey = storagePath
        let voiceKey = "storage"

        if let cached = cacheManager.cachedAudioData(for: cacheKey, voiceName: voiceKey) {
            isLoading = false
            guard sessionID == sid else { return }
            playData(cached, chunkOffset: 0)
            return
        }

        beginBackgroundTask()
        let ref = Storage.storage().reference().child(storagePath)
        ref.getData(maxSize: 10 * 1024 * 1024) { [weak self] data, error in
            guard let self, self.sessionID == sid else {
                self?.endBackgroundTask(); return
            }
            if let error {
                print("Storage indirme hatası: \(error.localizedDescription)")
                self.endBackgroundTask()
                self.startSpeaking(text: text)   // fallback
                return
            }
            guard let d = data, !d.isEmpty else {
                self.isLoading = false
                self.endBackgroundTask()
                DispatchQueue.main.async { self.delegate?.speechDidFinish() }
                return
            }
            self.cacheManager.cacheAudioData(d, for: cacheKey, voiceName: voiceKey)
            self.endBackgroundTask()
            DispatchQueue.main.async {
                guard self.sessionID == sid else { return }
                self.isLoading = false
                self.playData(d, chunkOffset: 0)
            }
        }
    }

    // MARK: - Public API — Playback controls

    func pause() {
        audioPlayer?.pause()
        highlightTimer?.invalidate()
        highlightTimer = nil
    }

    func resume() {
        guard let player = audioPlayer, !player.isPlaying else { return }
        player.play()
        startHighlightTimer()
    }

    func stop() {
        resetSession()
        if !prefetchOnly { isLoading = false }
        endBackgroundTask()
    }

    // MARK: - Public API — Kaydetme için birleştirilmiş ses verisi

    /// Tüm chunk'ların MP3 data'sını sırasıyla birleştirip döndürür.
    /// Henüz hazır olmayan chunk varsa nil döner.
    func mergedAudioDataForSave() -> Data? {
        guard !chunks.isEmpty, chunks.allSatisfy({ $0.isReady }) else { return nil }
        // MP3 binary concat: ID3 header sadece ilk chunk'ta olacak, geri kalanlar ham frame
        var merged = Data()
        chunks.sorted { $0.index < $1.index }.forEach { chunk in
            if let d = chunk.data { merged.append(d) }
        }
        return merged.isEmpty ? nil : merged
    }

    // MARK: - Private - Session management

    private func launchSession(text: String, storyID: String?) {
        resetSession()
        fullText = text
        currentStoryID = storyID
        currentVoice = VoiceOption.selectedVoice
        if !prefetchOnly { isLoading = true }

        let sid = sessionID!
        let rawChunks = splitIntoChunks(text)

        chunkQueue.async { [weak self] in
            guard let self else { return }
            self.chunks = rawChunks.map { AudioChunk(index: $0.index, text: $0.text, startOffset: $0.offset) }
            self.nextPlayIndex = 0
            self.activeRequestCount = 0
            self.fetchChunk(index: 0, sid: sid)
        }
    }

    private func resetSession() {
        sessionID = UUID()
        audioPlayer?.stop()
        audioPlayer = nil
        highlightTimer?.invalidate()
        highlightTimer = nil
        chunks = []
        wordRanges = []
        nextPlayIndex = 0
        activeRequestCount = 0
        currentHighlightIndex = 0
        playingChunkOffset = 0
        currentStoryID = nil
        // prefetchOnly modda audio session'a dokunma — ana SpeechService'i bozar
        if !prefetchOnly { deactivateAudioSession() }
    }

    // MARK: - Private - Text splitting

    /// Metni ~200 karakterlik parçalara böler.
    /// Her zaman kelime sınırında keser — bir kelimeyi ortadan bölmez.
    /// Dönen tuple: (index, text, fullText içindeki başlangıç offset)
    private func splitIntoChunks(_ text: String) -> [(index: Int, text: String, offset: Int)] {
        let maxLen = 200
        let words = text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

        var result: [(index: Int, text: String, offset: Int)] = []
        var buffer = ""
        var chunkStartOffset = 0   // Bu chunk'ın fullText içindeki başlangıcı
        var cursor = 0             // fullText içindeki mevcut karakter pozisyonu

        for word in words {
            // Kelimenin fullText içindeki gerçek konumunu bul
            if let range = text.range(of: word, range: text.index(text.startIndex, offsetBy: cursor)..<text.endIndex) {
                cursor = text.distance(from: text.startIndex, to: range.upperBound)
            }

            let candidate = buffer.isEmpty ? word : buffer + " " + word
            if candidate.count <= maxLen {
                buffer = candidate
            } else {
                if !buffer.isEmpty {
                    result.append((index: result.count, text: buffer, offset: chunkStartOffset))
                }
                // Yeni chunk başlangıç offset'ini hesapla
                if let range = text.range(of: word, range: text.index(text.startIndex, offsetBy: max(0, cursor - word.count))..<text.endIndex) {
                    chunkStartOffset = text.distance(from: text.startIndex, to: range.lowerBound)
                }
                buffer = word
            }
        }
        if !buffer.isEmpty {
            result.append((index: result.count, text: buffer, offset: chunkStartOffset))
        }
        return result.isEmpty ? [(index: 0, text: text, offset: 0)] : result
    }

    // MARK: - Private - Chunk fetching (sıralı kuyruk)

    private func fetchChunk(index: Int, sid: UUID) {
        chunkQueue.async { [weak self] in
            guard let self, self.sessionID == sid else { return }
            guard index < self.chunks.count else { return }
            guard self.chunks[index].data == nil else {
                // Zaten hazır — oynatmaya gönder
                self.onChunkReady(index: index, sid: sid)
                return
            }

            let chunk = self.chunks[index]
            let voice = self.currentVoice
            let cacheKey: String
            let isCacheStory: Bool

            if let storyID = self.currentStoryID {
                cacheKey = "story::\(storyID)::\(voice.name)::chunk\(index)"
                isCacheStory = true
            } else {
                cacheKey = "chunk::\(voice.cacheKey)::\(chunk.text.prefix(60))"
                isCacheStory = false
            }

            // Disk cache kontrolü
            if let cached = self.cacheManager.cachedAudioData(for: cacheKey, voiceName: "chunkv1") {
                print("🎵 Chunk \(index) disk cache hit")
                self.chunks[index].data = cached
                self.onChunkReady(index: index, sid: sid)
                return
            }

            // Cloud Function'a istek at
            self.activeRequestCount += 1
            self.beginBackgroundTask()

            var params: [String: Any] = [
                "text": chunk.text,
                "voiceName": voice.name,
                "modelName": voice.modelName
            ]
            if isCacheStory, let storyID = self.currentStoryID {
                params["storyID"] = storyID
                params["chunkIndex"] = index
            }

            self.functions.httpsCallable("generateStoryAudio").call(params) { [weak self] result, error in
                guard let self, self.sessionID == sid else {
                    self?.endBackgroundTask(); return
                }

                defer {
                    self.chunkQueue.async {
                        self.activeRequestCount -= 1
                        self.endBackgroundTask()
                    }
                }

                if let error {
                    print("TTS chunk \(index) hatası: \(error.localizedDescription)")
                    DispatchQueue.main.async { self.delegate?.speechDidFinish() }
                    return
                }

                guard let data = result?.data as? [String: Any],
                      let urlStr = data["audioURL"] as? String,
                      let url = URL(string: urlStr) else {
                    print("TTS chunk \(index): geçersiz yanıt")
                    DispatchQueue.main.async { self.delegate?.speechDidFinish() }
                    return
                }

                // URL'den indir
                URLSession.shared.dataTask(with: url) { [weak self] dlData, _, dlError in
                    guard let self, self.sessionID == sid else { return }

                    if let dlError {
                        print("Chunk \(index) indirme hatası: \(dlError.localizedDescription)")
                        self.isLoading = false
                        DispatchQueue.main.async { self.delegate?.speechDidFinish() }
                        return
                    }
                    guard let audioData = dlData, !audioData.isEmpty else {
                        print("Chunk \(index): boş ses verisi")
                        self.isLoading = false
                        DispatchQueue.main.async { self.delegate?.speechDidFinish() }
                        return
                    }

                    // Disk cache'e kaydet
                    self.cacheManager.cacheAudioData(audioData, for: cacheKey, voiceName: "chunkv1")

                    self.chunkQueue.async {
                        guard self.sessionID == sid else { return }
                        self.chunks[index].data = audioData
                        self.onChunkReady(index: index, sid: sid)
                    }
                }.resume()
            }
        }
    }

    /// Bir chunk hazır olduğunda: oynatma kuyruğunu ilerlet + sıradaki chunk'ı prefetch et
    private func onChunkReady(index: Int, sid: UUID) {
        // chunkQueue'da çalışır
        guard sessionID == sid else { return }

        // prefetchOnly modda ses çalmıyoruz — sadece cache'e yazdık, iş bitti
        if prefetchOnly {
            // Sıradaki chunk'ı da prefetch et
            let nextFetch = index + 1
            if nextFetch < chunks.count, chunks[nextFetch].data == nil {
                fetchChunk(index: nextFetch, sid: sid)
            }
            return
        }

        // Sıradaki oynatılacak chunk bu mu?
        if index == nextPlayIndex {
            let data = chunks[index].data!
            let offset = chunks[index].startOffset

            DispatchQueue.main.async { [weak self] in
                guard let self, self.sessionID == sid else { return }
                if index == 0 { self.isLoading = false }
                self.playData(data, chunkOffset: offset)
            }
        }

        // Sıradaki chunk'ı prefetch et (sadece henüz başlatılmamışsa)
        let nextFetch = index + 1
        if nextFetch < chunks.count, chunks[nextFetch].data == nil {
            fetchChunk(index: nextFetch, sid: sid)
        }
    }

    // MARK: - Private - Audio playback

    private func playData(_ data: Data, chunkOffset: Int) {
        activateAudioSession()
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            playingChunkOffset = chunkOffset
            buildWordTimings(for: data, offset: chunkOffset)
            audioPlayer?.play()
            currentHighlightIndex = 0
            delegate?.speechDidStart()
            startHighlightTimer()
        } catch {
            print("AVAudioPlayer hatası: \(error)")
            delegate?.speechDidFinish()
        }
    }

    // MARK: - Private - Highlight

    private func buildWordTimings(for data: Data, offset: Int) {
        // Yeni chunk için zamanlama hesapla (mecut listeyi korur, chunk offset'e göre ekler)
        do {
            let tempPlayer = try AVAudioPlayer(data: data)
            let duration = tempPlayer.duration
            guard duration > 0 else { return }

            // Bu chunk'a ait text'i bul
            let chunkIdx = nextPlayIndex
            guard chunkIdx < chunks.count else { return }
            let chunkText = chunks[chunkIdx].text as NSString

            var ranges: [NSRange] = []
            chunkText.enumerateSubstrings(in: NSRange(location: 0, length: chunkText.length), options: .byWords) { _, r, _, _ in
                ranges.append(r)
            }
            guard !ranges.isEmpty else { return }

            let timePerWord = duration / Double(ranges.count)
            wordRanges = ranges.enumerated().map { i, r in
                (range: NSRange(location: r.location + offset, length: r.length),
                 time: Double(i) * timePerWord,
                 chunkOffset: offset)
            }
        } catch {}
    }

    private func startHighlightTimer() {
        highlightTimer?.invalidate()
        highlightTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateHighlight()
        }
    }

    private func updateHighlight() {
        guard let player = audioPlayer, player.isPlaying else { return }
        let currentTime = player.currentTime

        while currentHighlightIndex < wordRanges.count - 1 &&
              wordRanges[currentHighlightIndex + 1].time <= currentTime {
            currentHighlightIndex += 1
        }
        guard currentHighlightIndex < wordRanges.count else { return }

        let wr = wordRanges[currentHighlightIndex]
        let sentenceRange = findSentenceRange(for: wr.range, in: fullText)
        delegate?.speechDidHighlight(characterRange: wr.range, sentenceRange: sentenceRange)
    }

    // MARK: - Private - Audio session

    private func activateAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Private - Background task

    private func beginBackgroundTask() {
        guard backgroundTaskID == .invalid else { return }
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "TTSAudioGeneration") { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        guard backgroundTaskID != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }

    // MARK: - Private - Helpers

    private var soundEnabled: Bool {
        UserDefaults.standard.object(forKey: "isSoundEnabled") as? Bool ?? true
    }

    private func findSentenceRange(for characterRange: NSRange, in text: String) -> NSRange {
        let nsText = text as NSString
        let loc = characterRange.location
        guard loc < nsText.length else { return characterRange }

        var start = 0
        for i in stride(from: loc - 1, through: 0, by: -1) {
            let c = nsText.character(at: i)
            if c == 46 || c == 63 || c == 33 { // . ? !
                start = i + 1
                break
            }
        }
        while start < loc, nsText.character(at: start) == 32 { start += 1 }

        var end = nsText.length
        for i in loc..<nsText.length {
            let c = nsText.character(at: i)
            if c == 46 || c == 63 || c == 33 {
                end = min(i + 1, nsText.length)
                break
            }
        }
        return NSRange(location: start, length: max(0, end - start))
    }
}

// MARK: - AVAudioPlayerDelegate

extension SpeechService: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let sid = sessionID
        chunkQueue.async { [weak self] in
            guard let self, self.sessionID == sid else { return }

            let finishedIndex = self.nextPlayIndex
            self.nextPlayIndex += 1

            // Tüm chunk'lar bitti mi?
            if self.nextPlayIndex >= self.chunks.count {
                DispatchQueue.main.async {
                    self.highlightTimer?.invalidate()
                    self.highlightTimer = nil
                    self.audioPlayer = nil
                    self.wordRanges = []
                    self.delegate?.speechDidFinish()
                }
                return
            }

            // Sıradaki chunk hazır mı?
            let next = self.nextPlayIndex
            if self.chunks[next].isReady {
                let data = self.chunks[next].data!
                let offset = self.chunks[next].startOffset
                DispatchQueue.main.async {
                    guard self.sessionID == sid else { return }
                    self.highlightTimer?.invalidate()
                    self.currentHighlightIndex = 0
                    self.playData(data, chunkOffset: offset)
                }
            } else {
                // Hazır değil — yüklenene kadar bekle (isLoading false kalır, zaten loading göstermiyoruz)
                print("⏳ Chunk \(next) henüz hazır değil, bekleniyor...")
                // fetchChunk zaten tetiklenmişti (prefetch), onChunkReady gelince otomatik oynatacak
            }
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio decode hatası: \(error?.localizedDescription ?? "")")
        DispatchQueue.main.async { [weak self] in
            self?.resetSession()
            self?.isLoading = false
            self?.delegate?.speechDidFinish()
        }
    }
}
