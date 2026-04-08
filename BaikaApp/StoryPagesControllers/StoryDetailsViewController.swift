//
//  StoryDetailsViewController.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 21.03.2026.
//

import UIKit

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
        
    }
    
    private func updateFavoriteButton() {
        let isFav = FavoriteManager.shared.isFavorite(viewModel.storyID)
        heartImage.image = UIImage(systemName: isFav ? "heart.fill" : "heart")
        heartImage.tintColor = isFav ? .systemRed : .white
        heartLabel.text = isFav ? "Favorilerde" : "Favorile"
    }

    @objc private func favoriteButtonTapped(_ sender: Any) {
        FavoriteManager.shared.toggleFavorite(viewModel.storyID)
        updateFavoriteButton()

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
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
            playImage.image = UIImage(systemName: "pause.fill")
            playLabel.text = "Durdur"
        case .playing:
            IndicatorView.shared.removeIndicator()
            playImage.image = UIImage(systemName: "pause.fill")
            playLabel.text = "Durdur"
        case .paused:
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

    // MARK: - Actions

    @objc private func listenButtonTapped() {
        viewModel.togglePlayback()
    }
}
