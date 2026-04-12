import UIKit
import AVFoundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Network

class StoryReadViewController: UIViewController {

    var story: GeneratedStory!
    private let speechService = SpeechService()
    private var isSpeaking = false
    private var isSaved = false
    private var displayedContent: String = ""
    private var contentOffset: Int = 0  // story.content içinde displayedContent'in başlangıç index'i

    // MARK: - UI Elements

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Nunito-Bold", size: 18) ?? .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let headerSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont(name: "Nunito-Regular", size: 12) ?? .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let sparkleButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18)
        button.setImage(UIImage(systemName: "sparkles", withConfiguration: config), for: .normal)
        button.tintColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let storyTitleCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 30/255, green: 25/255, blue: 60/255, alpha: 1.0)
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let storyTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Nunito-Bold", size: 18) ?? .boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emojisLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let storyContentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.font = UIFont(name: "Nunito-Regular", size: 16) ?? .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let listenButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let regenerateButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let purpleColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
        checkIfAlreadySaved()
        
        // Ses yüklenirken IndicatorView göster
        speechService.onLoadingStateChanged = { isLoading in
            if isLoading {
                IndicatorView.shared.showIndicator()
            } else {
                IndicatorView.shared.removeIndicator()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        speechService.stop()
        IndicatorView.shared.removeIndicator()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 35/255, alpha: 1.0)
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(backButton)
        view.addSubview(headerTitleLabel)
        view.addSubview(headerSubtitleLabel)
        view.addSubview(sparkleButton)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(storyTitleCard)
        storyTitleCard.addSubview(storyTitleLabel)
        storyTitleCard.addSubview(emojisLabel)
        contentView.addSubview(storyContentLabel)
        contentView.addSubview(listenButton)
        contentView.addSubview(saveButton)
        contentView.addSubview(regenerateButton)

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        listenButton.addTarget(self, action: #selector(listenTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        regenerateButton.addTarget(self, action: #selector(regenerateTapped), for: .touchUpInside)

        setupButtons()
        setupConstraints()
    }

    private func setupButtons() {
        configureActionButton(listenButton, title: "  Dinle", icon: "headphones", bgColor: purpleColor.withAlphaComponent(0.15), borderColor: purpleColor.withAlphaComponent(0.4), titleColor: purpleColor)
        configureActionButton(saveButton, title: "  Kaydet", icon: "square.and.arrow.down", bgColor: purpleColor.withAlphaComponent(0.15), borderColor: purpleColor.withAlphaComponent(0.4), titleColor: purpleColor)
        configureActionButton(regenerateButton, title: "  Yeniden Oluştur", icon: "arrow.clockwise", bgColor: UIColor.white.withAlphaComponent(0.06), borderColor: UIColor.white.withAlphaComponent(0.1), titleColor: UIColor.white.withAlphaComponent(0.7))
    }

    private func configureActionButton(_ button: UIButton, title: String, icon: String, bgColor: UIColor, borderColor: UIColor, titleColor: UIColor) {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: icon)
        config.baseForegroundColor = titleColor
        config.background.backgroundColor = bgColor
        config.background.cornerRadius = 14
        config.background.strokeColor = borderColor
        config.background.strokeWidth = 1.5
        let font = UIFont(name: "Nunito-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
        config.imagePadding = 6
        button.configuration = config
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            headerTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            headerTitleLabel.topAnchor.constraint(equalTo: backButton.topAnchor, constant: -2),

            headerSubtitleLabel.leadingAnchor.constraint(equalTo: headerTitleLabel.leadingAnchor),
            headerSubtitleLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 2),

            sparkleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sparkleButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            scrollView.topAnchor.constraint(equalTo: headerSubtitleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            storyTitleCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            storyTitleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            storyTitleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            storyTitleLabel.topAnchor.constraint(equalTo: storyTitleCard.topAnchor, constant: 16),
            storyTitleLabel.leadingAnchor.constraint(equalTo: storyTitleCard.leadingAnchor, constant: 16),
            storyTitleLabel.trailingAnchor.constraint(equalTo: storyTitleCard.trailingAnchor, constant: -16),

            emojisLabel.topAnchor.constraint(equalTo: storyTitleLabel.bottomAnchor, constant: 8),
            emojisLabel.leadingAnchor.constraint(equalTo: storyTitleCard.leadingAnchor, constant: 16),
            emojisLabel.bottomAnchor.constraint(equalTo: storyTitleCard.bottomAnchor, constant: -16),

            storyContentLabel.topAnchor.constraint(equalTo: storyTitleCard.bottomAnchor, constant: 20),
            storyContentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            storyContentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            listenButton.topAnchor.constraint(equalTo: storyContentLabel.bottomAnchor, constant: 28),
            listenButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            listenButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            listenButton.heightAnchor.constraint(equalToConstant: 50),

            saveButton.topAnchor.constraint(equalTo: listenButton.bottomAnchor, constant: 12),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            regenerateButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            regenerateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            regenerateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            regenerateButton.heightAnchor.constraint(equalToConstant: 50),
            regenerateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Configure

    private func configureContent() {
        headerTitleLabel.text = story.title
        headerSubtitleLabel.text = story.subtitle

        let lines = story.content.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        if let firstLine = lines.first {
            storyTitleLabel.text = firstLine
            let remainingContent = lines.dropFirst().joined(separator: "\n\n")
            displayedContent = remainingContent
            
            // story.content içinde remainingContent'in başladığı yeri bul
            if let range = story.content.range(of: firstLine) {
                contentOffset = story.content.distance(from: story.content.startIndex, to: range.upperBound)
                // Boşluk/newline'ları atla
                var idx = story.content.index(story.content.startIndex, offsetBy: contentOffset)
                while idx < story.content.endIndex && (story.content[idx] == "\n" || story.content[idx] == " ") {
                    idx = story.content.index(after: idx)
                }
                contentOffset = story.content.distance(from: story.content.startIndex, to: idx)
            }

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            let attributed = NSAttributedString(
                string: remainingContent,
                attributes: [
                    .font: UIFont(name: "Nunito-Regular", size: 16) ?? .systemFont(ofSize: 16),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.85),
                    .paragraphStyle: paragraphStyle
                ]
            )
            storyContentLabel.attributedText = attributed
        } else {
            storyTitleLabel.text = story.title
            displayedContent = story.content
            contentOffset = 0
            storyContentLabel.text = story.content
        }

        emojisLabel.text = story.emojis
    }

    /// Hikaye daha önce kaydedilmiş mi kontrol et
    private func checkIfAlreadySaved() {
        let alreadyExists = CreatedStoriesManager.shared.cachedStories.contains {
            $0.title == story.title && $0.content == story.content
        }
        if alreadyExists {
            isSaved = true
            saveButton.isEnabled = false
            configureActionButton(
                saveButton,
                title: "  Kaydedildi ✓",
                icon: "checkmark.circle.fill",
                bgColor: UIColor.systemGreen.withAlphaComponent(0.15),
                borderColor: UIColor.systemGreen.withAlphaComponent(0.4),
                titleColor: UIColor.systemGreen
            )
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        speechService.stop()
        // Modal olarak açıldıysa: en alttaki presenter'a kadar tüm modal'ları kapat
        if let nav = navigationController {
            nav.popToRootViewController(animated: true)
        } else if let rootPresenter = self.presentingViewController?.presentingViewController {
            // CreateAIStoryVC → StoryLoadingVC → StoryReadVC zincirinde en alta dön
            rootPresenter.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func listenTapped() {
        if speechService.isSpeaking || speechService.isPaused || speechService.isLoading {
            speechService.stop()
            isSpeaking = false
            updateListenButton(speaking: false)
            resetHighlight()
            IndicatorView.shared.removeIndicator()
            return
        }

        // Ses ayarı kapalıysa hiç başlatma
        let isSoundEnabled = UserDefaults.standard.object(forKey: "isSoundEnabled") as? Bool ?? true
        guard isSoundEnabled else { return }

        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        var isNetworkHandled = false
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard !isNetworkHandled else { return }
            isNetworkHandled = true
            
            DispatchQueue.main.async {
                monitor.cancel()
                guard let self = self else { return }
                
                if path.status == .satisfied {
                    self.isSpeaking = true
                    self.updateListenButton(speaking: true)
                    self.speechService.delegate = self
                    
                    // Kaydedilmiş hikaye ise Storage'dan oynat, değilse TTS ile oluştur (sadece disk cache)
                    if let audioPath = self.story.audioStoragePath, !audioPath.isEmpty {
                        self.speechService.startSpeakingFromStorage(text: self.story.content, storagePath: audioPath)
                    } else {
                        self.speechService.startSpeaking(text: self.story.content)
                    }
                } else {
                    let alert = UIAlertController(title: "Bağlantı Hatası", message: "Lütfen internet bağlantınızı kontrol edip tekrar deneyin.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
        monitor.start(queue: queue)
    }

    private func updateListenButton(speaking: Bool) {
        let title = speaking ? "  Durdur" : "  Dinle"
        let icon = speaking ? "stop.circle" : "headphones"
        configureActionButton(
            listenButton,
            title: title,
            icon: icon,
            bgColor: purpleColor.withAlphaComponent(0.15),
            borderColor: purpleColor.withAlphaComponent(0.4),
            titleColor: purpleColor
        )
    }

    @objc private func saveTapped() {
        // Zaten kaydedilmişse tekrar kaydetme
        guard !isSaved else { return }
        
        // Auth kontrolü - kullanıcı giriş yapmamışsa uyar
        guard let uid = Auth.auth().currentUser?.uid else {
            let alert = UIAlertController(title: "Hata", message: "Kaydetmek için giriş yapmanız gerekiyor.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }
        
        saveButton.isEnabled = false
        configureActionButton(saveButton, title: "  Kaydediliyor...", icon: "hourglass", bgColor: purpleColor.withAlphaComponent(0.15), borderColor: purpleColor.withAlphaComponent(0.4), titleColor: purpleColor)

        // Chunk'ları doğru sırayla birleştirerek tek MP3 elde et
        let mergedAudio = speechService.mergedAudioDataForSave()

        if let audioData = mergedAudio {
            let audioFileName = UUID().uuidString + ".mp3"
            let storagePath = "users/\(uid)/storyAudio/\(audioFileName)"
            let storageRef = Storage.storage().reference().child(storagePath)

            storageRef.putData(audioData, metadata: StorageMetadata(dictionary: ["contentType": "audio/mpeg"])) { [weak self] _, error in
                guard let self = self else { return }
                if let error = error {
                    print("Storage yükleme hatası: \(error.localizedDescription)")
                    self.saveStoryToFirestore(uid: uid, audioStoragePath: nil)
                } else {
                    print("✅ Birleşik ses Storage'a yüklendi: \(storagePath)")
                    self.saveStoryToFirestore(uid: uid, audioStoragePath: storagePath)
                }
            }
        } else {
            // Ses henüz hazır değil veya hiç oluşturulmadı — sessiz kaydet
            saveStoryToFirestore(uid: uid, audioStoragePath: nil)
        }
    }

    private func saveStoryToFirestore(uid: String, audioStoragePath: String?) {
        let createdStory = CreatedStory(
            title: story.title,
            content: story.content,
            ageCategory: story.ageGroup,
            imageURL: story.characterEmoji,
            createdAt: Date(),
            audioStoragePath: audioStoragePath
        )

        CreatedStoriesManager.shared.saveCreatedStory(createdStory) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if success {
                    self.isSaved = true
                    self.configureActionButton(
                        self.saveButton,
                        title: "  Kaydedildi ✓",
                        icon: "checkmark.circle.fill",
                        bgColor: UIColor.systemGreen.withAlphaComponent(0.15),
                        borderColor: UIColor.systemGreen.withAlphaComponent(0.4),
                        titleColor: UIColor.systemGreen
                    )
                } else {
                    self.saveButton.isEnabled = true
                    self.configureActionButton(
                        self.saveButton,
                        title: "  Kaydet",
                        icon: "square.and.arrow.down",
                        bgColor: self.purpleColor.withAlphaComponent(0.15),
                        borderColor: self.purpleColor.withAlphaComponent(0.4),
                        titleColor: self.purpleColor
                    )
                    let alert = UIAlertController(title: "Hata", message: "Hikaye kaydedilemedi. Lütfen tekrar deneyin.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    @objc private func regenerateTapped() {
        // Parametreler boşsa yeniden oluşturulamaz (favorilerden gelmiş olabilir)
        guard !story.childName.isEmpty else {
            let alert = UIAlertController(
                title: "Yeniden Oluşturulamıyor",
                message: "Bu hikaye kayıtlı parametrelere sahip değil. Lütfen ana sayfadan yeni bir hikaye oluşturun.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }

        speechService.stop()

        // Yeni loading VC hazırla
        let storyboard = UIStoryboard(name: "StoryLoading", bundle: nil)
        let loadingVC = storyboard.instantiateViewController(withIdentifier: "StoryLoadingVC") as! StoryLoadingViewController
        loadingVC.storyParameters = StoryParameters(
            childName: story.childName,
            character: story.character,
            place: story.place,
            theme: story.theme,
            ageGroup: story.ageGroup
        )
        loadingVC.modalPresentationStyle = .fullScreen

        // Modal zincir: CreateAIStoryVC → StoryLoadingVC → StoryReadVC (bu VC)
        // En üstteki presenting VC'yi bul (CreateAIStoryVC veya StoryLoadingVC)
        // StoryReadVC'yi sunan StoryLoadingVC
        if let loadingPresenter = self.presentingViewController {
            // StoryLoadingVC'yi sunan CreateAIStoryVC (veya başka root)
            if let rootPresenter = loadingPresenter.presentingViewController {
                // Tüm modal'ları kapat, sonra root'tan yeni loading aç
                rootPresenter.dismiss(animated: true) {
                    rootPresenter.present(loadingVC, animated: true)
                }
            } else {
                // Tek modal katman varsa (favorilerden gelmiş olabilir)
                loadingPresenter.dismiss(animated: true) {
                    loadingPresenter.present(loadingVC, animated: true)
                }
            }
        }
    }
}

// MARK: - SpeechServiceDelegate

extension StoryReadViewController: SpeechServiceDelegate {
    func speechDidStart() {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = true
            self?.updateListenButton(speaking: true)
        }
    }

    func speechDidHighlight(characterRange: NSRange, sentenceRange: NSRange) {
        DispatchQueue.main.async { [weak self] in
            self?.highlightWord(characterRange: characterRange, sentenceRange: sentenceRange)
        }
    }

    func speechDidFinish() {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.updateListenButton(speaking: false)
            self?.resetHighlight()
        }
    }
}

// MARK: - Highlight

extension StoryReadViewController {

    /// Okunan kelimeyi ve cümleyi storyContentLabel üzerinde renklendirir
    private func highlightWord(characterRange: NSRange, sentenceRange: NSRange) {
        let labelText = displayedContent
        guard !labelText.isEmpty else { return }
        let labelLength = (labelText as NSString).length

        // speech range'lerini label text range'lerine dönüştür (offset çıkar)
        let wordLoc = characterRange.location - contentOffset
        let wordLen = characterRange.length
        let sentLoc = sentenceRange.location - contentOffset
        let sentLen = sentenceRange.length

        // Varsayılan stil
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let defaultFont = UIFont(name: "Nunito-Regular", size: 16) ?? .systemFont(ofSize: 16)

        let defaultAttrs: [NSAttributedString.Key: Any] = [
            .font: defaultFont,
            .foregroundColor: UIColor.white.withAlphaComponent(0.4),
            .paragraphStyle: paragraphStyle
        ]

        let attributed = NSMutableAttributedString(string: labelText, attributes: defaultAttrs)

        // Okunan cümleyi aydınlat
        let safeSentRange = NSRange(
            location: max(0, sentLoc),
            length: min(sentLen, labelLength - max(0, sentLoc))
        )
        if safeSentRange.location >= 0 && safeSentRange.length > 0 && safeSentRange.location + safeSentRange.length <= labelLength {
            attributed.addAttribute(.foregroundColor, value: UIColor.white.withAlphaComponent(0.85), range: safeSentRange)
        }

        // Okunan kelimeyi sarı/altın renge boya
        let safeWordRange = NSRange(
            location: max(0, wordLoc),
            length: min(wordLen, labelLength - max(0, wordLoc))
        )
        if safeWordRange.location >= 0 && safeWordRange.length > 0 && safeWordRange.location + safeWordRange.length <= labelLength {
            attributed.addAttributes([
                .foregroundColor: UIColor(red: 1.0, green: 0.85, blue: 0.35, alpha: 1.0),
                .font: UIFont(name: "Nunito-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
            ], range: safeWordRange)
        }

        storyContentLabel.attributedText = attributed

        // Okunan kelimeye otomatik scroll
        if let wordRect = storyContentLabel.boundingRect(forCharacterRange: safeWordRange) {
            let wordRectInScrollView = scrollView.convert(wordRect, from: storyContentLabel)
            let visibleRect = CGRect(
                x: wordRectInScrollView.origin.x,
                y: wordRectInScrollView.origin.y - 100,
                width: wordRectInScrollView.width,
                height: wordRectInScrollView.height + 200
            )
            scrollView.scrollRectToVisible(visibleRect, animated: true)
        }
    }

    /// Okuma bitince/durdurulunca orijinal stile döndür
    private func resetHighlight() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let attributed = NSAttributedString(
            string: displayedContent,
            attributes: [
                .font: UIFont(name: "Nunito-Regular", size: 16) ?? .systemFont(ofSize: 16),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85),
                .paragraphStyle: paragraphStyle
            ]
        )
        storyContentLabel.attributedText = attributed
    }
}
