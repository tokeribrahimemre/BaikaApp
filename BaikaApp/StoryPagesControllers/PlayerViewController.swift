// BaikaApp/StoryPagesControllers/PlayerViewController.swift

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    // MARK: - Properties

    var playlist: [PlaylistItem] = []
    private var currentIndex = 0
    private let speechService = SpeechService()
    private var isPlaying = false
    private var isPaused = false

    // MARK: - Colors

    private let bgColor = UIColor(red: 15/255, green: 14/255, blue: 42/255, alpha: 1.0)
    private let purpleColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
    private let cardColor = UIColor(red: 22/255, green: 21/255, blue: 50/255, alpha: 1.0)

    // MARK: - UI Elements

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Şimdi Çalınıyor"
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont(name: "Nunito-SemiBold", size: 13) ?? .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let playlistCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.35)
        label.font = UIFont(name: "Nunito-Regular", size: 12) ?? .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Kapak alanı
    private let coverContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 30/255, green: 25/255, blue: 60/255, alpha: 1.0)
        v.layer.cornerRadius = 32
        v.layer.shadowColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1).cgColor
        v.layer.shadowRadius = 20
        v.layer.shadowOpacity = 0.3
        v.layer.shadowOffset = .zero
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 72)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Bilgi
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Nunito-Bold", size: 22) ?? .boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.45)
        label.font = UIFont(name: "Nunito-Regular", size: 14) ?? .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Metin gösterim alanı (highlight)
    private let textScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont(name: "Nunito-Regular", size: 15) ?? .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Kontroller
    private let prevButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        button.setImage(UIImage(systemName: "backward.end.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        button.setImage(UIImage(systemName: "forward.end.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        speechService.delegate = self
        loadCurrentTrack()
        startPlaying()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        speechService.stop()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = bgColor

        view.addSubview(closeButton)
        view.addSubview(headerLabel)
        view.addSubview(playlistCountLabel)
        view.addSubview(coverContainer)
        coverContainer.addSubview(emojiLabel)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(textScrollView)
        textScrollView.addSubview(contentLabel)

        let controlsStack = UIStackView(arrangedSubviews: [prevButton, playPauseButton, nextButton])
        controlsStack.axis = .horizontal
        controlsStack.alignment = .center
        controlsStack.distribution = .equalSpacing
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsStack)

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)

        updatePlayPauseIcon(playing: false)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),

            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),

            playlistCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playlistCountLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 2),

            coverContainer.topAnchor.constraint(equalTo: playlistCountLabel.bottomAnchor, constant: 24),
            coverContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coverContainer.widthAnchor.constraint(equalToConstant: 180),
            coverContainer.heightAnchor.constraint(equalToConstant: 180),

            emojiLabel.centerXAnchor.constraint(equalTo: coverContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: coverContainer.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: coverContainer.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            textScrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            textScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            textScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            textScrollView.bottomAnchor.constraint(equalTo: controlsStack.topAnchor, constant: -16),

            contentLabel.topAnchor.constraint(equalTo: textScrollView.topAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: textScrollView.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: textScrollView.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: textScrollView.bottomAnchor),
            contentLabel.widthAnchor.constraint(equalTo: textScrollView.widthAnchor),

            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            controlsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            controlsStack.heightAnchor.constraint(equalToConstant: 64),

            playPauseButton.widthAnchor.constraint(equalToConstant: 64),
            playPauseButton.heightAnchor.constraint(equalToConstant: 64),
        ])
    }

    // MARK: - Track Loading

    private func loadCurrentTrack() {
        guard currentIndex < playlist.count else { return }
        let item = playlist[currentIndex]

        emojiLabel.text = item.emoji
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        playlistCountLabel.text = "\(currentIndex + 1) / \(playlist.count)"

        // İçerik metnini ayarla
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        contentLabel.attributedText = NSAttributedString(
            string: item.content,
            attributes: [
                .font: UIFont(name: "Nunito-Regular", size: 15) ?? .systemFont(ofSize: 15),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5),
                .paragraphStyle: paragraphStyle
            ]
        )
        textScrollView.setContentOffset(.zero, animated: false)

        // Önceki/sonraki butonlarını güncelle
        prevButton.isEnabled = currentIndex > 0
        prevButton.tintColor = currentIndex > 0 ? .white : UIColor.white.withAlphaComponent(0.2)
        nextButton.isEnabled = currentIndex < playlist.count - 1
        nextButton.tintColor = currentIndex < playlist.count - 1 ? .white : UIColor.white.withAlphaComponent(0.2)

        // Cover animasyonu
        coverContainer.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.coverContainer.transform = .identity
        }
    }

    private func startPlaying() {
        guard currentIndex < playlist.count else { return }
        let item = playlist[currentIndex]
        isPaused = false
        isPlaying = true
        updatePlayPauseIcon(playing: true)
        speechService.startSpeaking(text: item.content)
    }

    // MARK: - Play/Pause Icon

    private func updatePlayPauseIcon(playing: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .medium)
        let name = playing ? "pause.circle.fill" : "play.circle.fill"
        playPauseButton.setImage(UIImage(systemName: name, withConfiguration: config), for: .normal)
        playPauseButton.tintColor = purpleColor
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        speechService.stop()
        dismiss(animated: true)
    }

    @objc private func playPauseTapped() {
        if isPaused {
            // Duraklatılmış → devam et
            speechService.resume()
            isPaused = false
            isPlaying = true
            updatePlayPauseIcon(playing: true)
        } else if isPlaying {
            // Oynatılıyor → duraklat
            speechService.pause()
            isPaused = true
            isPlaying = false
            updatePlayPauseIcon(playing: false)
        } else {
            // Hiçbiri → baştan başlat
            startPlaying()
        }
    }

    @objc private func prevTapped() {
        guard currentIndex > 0 else { return }
        speechService.stop()
        currentIndex -= 1
        loadCurrentTrack()
        startPlaying()
    }

    @objc private func nextTapped() {
        guard currentIndex < playlist.count - 1 else { return }
        speechService.stop()
        currentIndex += 1
        loadCurrentTrack()
        startPlaying()
    }

    // MARK: - Highlight

    private func highlightWord(characterRange: NSRange, sentenceRange: NSRange) {
        guard currentIndex < playlist.count else { return }
        let text = playlist[currentIndex].content
        let length = (text as NSString).length

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let defaultFont = UIFont(name: "Nunito-Regular", size: 15) ?? .systemFont(ofSize: 15)

        let attributed = NSMutableAttributedString(string: text, attributes: [
            .font: defaultFont,
            .foregroundColor: UIColor.white.withAlphaComponent(0.3),
            .paragraphStyle: paragraphStyle
        ])

        // Okunan cümleyi aydınlat
        let safeSentRange = NSRange(
            location: max(0, sentenceRange.location),
            length: min(sentenceRange.length, length - max(0, sentenceRange.location))
        )
        if safeSentRange.length > 0 && safeSentRange.location + safeSentRange.length <= length {
            attributed.addAttribute(.foregroundColor, value: UIColor.white.withAlphaComponent(0.75), range: safeSentRange)
        }

        // Okunan kelimeyi altın sarısına boya
        let safeWordRange = NSRange(
            location: max(0, characterRange.location),
            length: min(characterRange.length, length - max(0, characterRange.location))
        )
        if safeWordRange.length > 0 && safeWordRange.location + safeWordRange.length <= length {
            attributed.addAttributes([
                .foregroundColor: UIColor(red: 1.0, green: 0.85, blue: 0.35, alpha: 1.0),
                .font: UIFont(name: "Nunito-Bold", size: 15) ?? .boldSystemFont(ofSize: 15)
            ], range: safeWordRange)
        }

        contentLabel.attributedText = attributed

        // Okunan kelimeye scroll
        if let wordRect = contentLabel.boundingRect(forCharacterRange: safeWordRange) {
            let wordInScrollView = textScrollView.convert(wordRect, from: contentLabel)
            let targetRect = CGRect(
                x: wordInScrollView.origin.x,
                y: wordInScrollView.origin.y - 60,
                width: wordInScrollView.width,
                height: wordInScrollView.height + 120
            )
            textScrollView.scrollRectToVisible(targetRect, animated: true)
        }
    }

    private func resetHighlight() {
        guard currentIndex < playlist.count else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        contentLabel.attributedText = NSAttributedString(
            string: playlist[currentIndex].content,
            attributes: [
                .font: UIFont(name: "Nunito-Regular", size: 15) ?? .systemFont(ofSize: 15),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5),
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}

// MARK: - SpeechServiceDelegate

extension PlayerViewController: SpeechServiceDelegate {

    func speechDidStart() {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = true
            self?.updatePlayPauseIcon(playing: true)
        }
    }

    func speechDidHighlight(characterRange: NSRange, sentenceRange: NSRange) {
        DispatchQueue.main.async { [weak self] in
            self?.highlightWord(characterRange: characterRange, sentenceRange: sentenceRange)
        }
    }

    func speechDidFinish() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.isPlaying = false
            self.isPaused = false
            self.updatePlayPauseIcon(playing: false)
            self.resetHighlight()

            // Otomatik sonraki masala geç (doğal bitişte)
            if self.currentIndex < self.playlist.count - 1 {
                self.currentIndex += 1
                self.loadCurrentTrack()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startPlaying()
                }
            }
        }
    }
}
