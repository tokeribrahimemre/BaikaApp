//
//  SpeechService.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 8.04.2026.
//

import AVFoundation

protocol SpeechServiceDelegate: AnyObject {
    func speechDidStart()
    func speechDidHighlight(characterRange: NSRange, sentenceRange: NSRange)
    func speechDidFinish()
}

class SpeechService: NSObject {

    weak var delegate: SpeechServiceDelegate?

    private let synthesizer = AVSpeechSynthesizer()
    private(set) var fullText: String = ""

    var isSpeaking: Bool { synthesizer.isSpeaking }
    var isPaused: Bool { synthesizer.isPaused }

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func startSpeaking(text: String) {
        fullText = text
        activateAudioSession()

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = bestTurkishVoice()
        utterance.rate = 0.50
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.0
        utterance.postUtteranceDelay = 0.0

        synthesizer.speak(utterance)
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        synthesizer.continueSpeaking()
    }

    func stop() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        deactivateAudioSession()
    }

    // MARK: - Private

    private func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession hatası: \(error.localizedDescription)")
        }
    }

    private func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func bestTurkishVoice() -> AVSpeechSynthesisVoice? {
        let turkishVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "tr-TR" }

        if let premium = turkishVoices.first(where: { $0.quality == .premium }) {
            return premium
        }
        if let enhanced = turkishVoices.first(where: { $0.quality == .enhanced }) {
            return enhanced
        }
        return AVSpeechSynthesisVoice(language: "tr-TR")
    }

    private func findSentenceRange(for characterRange: NSRange, in text: String) -> NSRange {
        let nsText = text as NSString
        let startIndex = text.index(text.startIndex, offsetBy: characterRange.location)

        // Find sentence start
        var sentenceStart = text.startIndex
        if startIndex > text.startIndex {
            var idx = text.index(before: startIndex)
            while idx > text.startIndex {
                let c = text[idx]
                if c == "." || c == "?" || c == "!" {
                    sentenceStart = text.index(after: idx)
                    while sentenceStart < startIndex && text[sentenceStart] == " " {
                        sentenceStart = text.index(after: sentenceStart)
                    }
                    break
                }
                idx = text.index(before: idx)
            }
        }

        // Find sentence end
        var sentenceEnd = text.endIndex
        var idx = startIndex
        while idx < text.endIndex {
            let c = text[idx]
            if c == "." || c == "?" || c == "!" {
                sentenceEnd = text.index(after: idx)
                break
            }
            idx = text.index(after: idx)
        }

        let finalStart = text.distance(from: text.startIndex, to: sentenceStart)
        let finalLength = text.distance(from: sentenceStart, to: sentenceEnd)
        return NSRange(location: finalStart, length: min(finalLength, nsText.length - finalStart))
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechService: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        delegate?.speechDidStart()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let sentenceRange = findSentenceRange(for: characterRange, in: fullText)
        delegate?.speechDidHighlight(characterRange: characterRange, sentenceRange: sentenceRange)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        delegate?.speechDidFinish()
    }
}
