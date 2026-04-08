//
//  StoryReadViewController.swift
//  BaikaApp
//

import UIKit

class StoryReadViewController: UIViewController {

    var story: GeneratedStory!

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
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 35/255, alpha: 1.0)
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Header
        view.addSubview(backButton)
        view.addSubview(headerTitleLabel)
        view.addSubview(headerSubtitleLabel)
        view.addSubview(sparkleButton)

        // ScrollView
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
            // Back button
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            // Header title
            headerTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            headerTitleLabel.topAnchor.constraint(equalTo: backButton.topAnchor, constant: -2),

            headerSubtitleLabel.leadingAnchor.constraint(equalTo: headerTitleLabel.leadingAnchor),
            headerSubtitleLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 2),

            // Sparkle
            sparkleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sparkleButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            // ScrollView
            scrollView.topAnchor.constraint(equalTo: headerSubtitleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Story Title Card
            storyTitleCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            storyTitleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            storyTitleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            storyTitleLabel.topAnchor.constraint(equalTo: storyTitleCard.topAnchor, constant: 16),
            storyTitleLabel.leadingAnchor.constraint(equalTo: storyTitleCard.leadingAnchor, constant: 16),
            storyTitleLabel.trailingAnchor.constraint(equalTo: storyTitleCard.trailingAnchor, constant: -16),

            emojisLabel.topAnchor.constraint(equalTo: storyTitleLabel.bottomAnchor, constant: 8),
            emojisLabel.leadingAnchor.constraint(equalTo: storyTitleCard.leadingAnchor, constant: 16),
            emojisLabel.bottomAnchor.constraint(equalTo: storyTitleCard.bottomAnchor, constant: -16),

            // Story Content
            storyContentLabel.topAnchor.constraint(equalTo: storyTitleCard.bottomAnchor, constant: 20),
            storyContentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            storyContentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Buttons
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

        // İlk satırı başlık olarak ayır
        let lines = story.content.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        if let firstLine = lines.first {
            storyTitleLabel.text = firstLine
            let remainingContent = lines.dropFirst().joined(separator: "\n\n")
            storyContentLabel.text = remainingContent

            // Satır aralığı
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
            storyContentLabel.text = story.content
        }

        emojisLabel.text = story.emojis
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popToRootViewController(animated: true)
    }

    @objc private func listenTapped() {
        // TODO: Text-to-speech
        print("Dinle tapped")
    }

    @objc private func saveTapped() {
        // TODO: Hikayeyi kaydet
        print("Kaydet tapped")
    }

    @objc private func regenerateTapped() {
        // Yükleme ekranına geri dön ve yeniden oluştur
        let loadingVC = StoryLoadingViewController()
        loadingVC.storyParameters = StoryParameters(
            childName: story.childName,
            character: story.character,
            place: story.place,
            theme: story.theme,
            ageGroup: story.ageGroup
        )
        navigationController?.setViewControllers(
            [navigationController!.viewControllers.first!, loadingVC],
            animated: true
        )
    }
}
