//
//  StoryDetailsViewController.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 21.03.2026.
//

import UIKit
import FirebaseAuth
import Network

class StoryDetailsViewController: UIViewController {

    // MARK: - ViewModel

    private let viewModel: StoryDetailsViewModel

    // MARK: - Outlets

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var playStackView: UIStackView!
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var favoriteStackView: UIStackView!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var themImageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!

    private let reportButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn.setImage(UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.6)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    init?(coder: NSCoder, story: Story) {
        self.viewModel = StoryDetailsViewModel(story: story)
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("HATA: StoryDetailViewController bir hikaye modeli olmadan başlatılamaz!")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopPlayback()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ageView.layer.cornerRadius = ageView.bounds.height / 2
        ageView.clipsToBounds = true
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.onSpeechStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.updatePlayButton(for: state)
            }
        }

        viewModel.onHighlight = { [weak self] fullText, sentenceRange, characterRange in
            DispatchQueue.main.async {
                self?.highlightSentence(fullText: fullText, sentenceRange: sentenceRange, characterRange: characterRange)
            }
        }

        viewModel.onResetText = { [weak self] text in
            DispatchQueue.main.async {
                self?.descriptionLabel.text = text
            }
        }
    }

    // MARK: - Setup

    private func setupUI() {
        storyImage.loadImage(from: viewModel.imageURL)
        storyTitleLabel.text = viewModel.title
        ageLabel.text = viewModel.ageCategory
        timeLabel.text = viewModel.time
        themImageView.setThemeEmoji(viewModel.themeCategory)
        themeLabel.text = viewModel.themeCategory
        descriptionLabel.text = viewModel.descriptionText

        playStackView.isUserInteractionEnabled = true
        favoriteStackView.isUserInteractionEnabled = true

        let playGesture = UITapGestureRecognizer(target: self, action: #selector(listenButtonTapped))
        playStackView.addGestureRecognizer(playGesture)
        
        let favoriteGesture = UITapGestureRecognizer(target: self, action: #selector(favoriteButtonTapped(_:)))
            favoriteStackView.addGestureRecognizer(favoriteGesture)

            updateFavoriteButton()
        
        setupReportButton()
    }
    
    private func setupReportButton() {
        view.addSubview(reportButton)
        NSLayoutConstraint.activate([
            reportButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            reportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            reportButton.widthAnchor.constraint(equalToConstant: 44),
            reportButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
    
    private func updateFavoriteButton() {
        let isFav = FavoriteManager.shared.isFavorite(viewModel.storyID)
        heartImage.image = UIImage(systemName: isFav ? "heart.fill" : "heart")
        heartImage.tintColor = isFav ? .systemRed : .white
        heartLabel.text = isFav ? "Favorilerde" : "Favorile"
    }

    @objc private func favoriteButtonTapped(_ sender: Any) {
        if Auth.auth().currentUser?.isAnonymous == true {
            showLoginPrompt(message: "Favorilere eklemek için giriş yapmalısınız.")
            return
        }

        FavoriteManager.shared.toggleFavorite(viewModel.storyID)
        updateFavoriteButton()

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    @objc private func reportButtonTapped() {
        let alert = UIAlertController(
            title: "İçeriği Şikayet Et",
            message: "Bu hikayede uygunsuz veya rahatsız edici bir içerik olduğunu düşünüyorsanız lütfen bize bildirin. Şikayetiniz en kısa sürede incelenecektir.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Şiddet / Korkutucu İçerik", style: .destructive, handler: { [weak self] _ in
            self?.submitReport(reason: "Şiddet / Korkutucu İçerik")
        }))
        alert.addAction(UIAlertAction(title: "Uygunsuz Dil", style: .destructive, handler: { [weak self] _ in
            self?.submitReport(reason: "Uygunsuz Dil")
        }))
        alert.addAction(UIAlertAction(title: "Diğer", style: .destructive, handler: { [weak self] _ in
            self?.submitReport(reason: "Diğer")
        }))
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = reportButton
            popoverController.sourceRect = reportButton.bounds
        }
        
        present(alert, animated: true)
    }

    private func submitReport(reason: String) {
        // Normalde burada Firebase Firestore veya bir API'ye şikayet gönderilir
        let alert = UIAlertController(
            title: "Şikayet Alındı",
            message: "Bildiriminiz incelenmek üzere ekibimize ulaşmıştır. Geri bildiriminiz için teşekkür ederiz.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func listenButtonTapped() {
//        if Auth.auth().currentUser?.isAnonymous == true {
//            showLoginPrompt(message: "Hikayeyi dinlemek için giriş yapmalısınız.")
//            return
//        }

        if viewModel.speechState == .playing || viewModel.speechState == .paused || viewModel.speechState == .loading {
            viewModel.togglePlayback()
            return
        }
        
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        var isNetworkHandled = false
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard !isNetworkHandled else { return }
            isNetworkHandled = true
            
            DispatchQueue.main.async {
                monitor.cancel()
                if path.status == .satisfied {
                    self?.viewModel.togglePlayback()
                } else {
                    let alert = UIAlertController(title: "Bağlantı Hatası", message: "Lütfen internet bağlantınızı kontrol edip tekrar deneyin.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
        monitor.start(queue: queue)
    }

    private func showLoginPrompt(message: String) {
        let alert = UIAlertController(title: "Giriş Gerekli", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Giriş Yap", style: .default) { [weak self] _ in
            self?.navigateToLogin()
        })
        present(alert, animated: true)
    }

    private func navigateToLogin() {
        do {
            try Auth.auth().signOut()
            FavoriteManager.shared.clearCache()
            CreatedStoriesManager.shared.clearCache()

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }

            let loginVC = LoginViewController()
            window.rootViewController = loginVC
            UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
        } catch {
            print("Çıkış yaparken hata: \(error.localizedDescription)")
        }
    }

    // MARK: - UI Updates

    private func updatePlayButton(for state: SpeechState) {
        switch state {
        case .idle:
            IndicatorView.shared.removeIndicator()
            playImage.image = UIImage(systemName: "play.fill")
            playLabel.text = "Dinle"
        case .loading:
            IndicatorView.shared.showIndicator()
            playImage.image = UIImage(systemName: "stop.fill")
            playLabel.text = "Durdur"
        case .playing:
            IndicatorView.shared.removeIndicator()
            playImage.image = UIImage(systemName: "pause.fill")
            playLabel.text = "Durdur"
        case .paused:
            IndicatorView.shared.removeIndicator()
            playImage.image = UIImage(systemName: "play.fill")
            playLabel.text = "Dinle"
        }
    }

    private func highlightSentence(fullText: String, sentenceRange: NSRange, characterRange: NSRange) {
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: descriptionLabel.font ?? UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]

        let attributedString = NSMutableAttributedString(string: fullText, attributes: defaultAttributes)
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor(named: "warmYellow") ?? UIColor.systemYellow,
            range: sentenceRange
        )
        descriptionLabel.attributedText = attributedString

        if let wordRect = descriptionLabel.boundingRect(forCharacterRange: characterRange) {
            let wordRectInScrollView = scrollView.convert(wordRect, from: descriptionLabel)
            let visibleRect = CGRect(
                x: wordRectInScrollView.origin.x,
                y: wordRectInScrollView.origin.y - 100,
                width: wordRectInScrollView.width,
                height: wordRectInScrollView.height + 200
            )
            scrollView.scrollRectToVisible(visibleRect, animated: true)
        }
    }
}
