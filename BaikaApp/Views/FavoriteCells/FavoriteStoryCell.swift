// BaikaApp/Views/FavoriteCells/FavoriteStoryCell.swift

import UIKit

class FavoriteStoryCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Callbacks
    var onDeleteTapped: (() -> Void)?
    var onPlayTapped: (() -> Void)?

    // Emoji overlay label (URL yerine emoji göstermek için)
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
        setupEmojiLabel()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        storyImageView.image = nil
        storyImageView.backgroundColor = .clear
        emojiLabel.text = nil
        emojiLabel.isHidden = true
        titleLabel.text = nil
        ageLabel.text = nil
        onDeleteTapped = nil
        onPlayTapped = nil
    }

    // MARK: - Setup

    private func setupAppearance() {
        // Cell arka planı şeffaf
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card container - koyu arka plan, yuvarlak köşe, ince border
        cardContainerView.backgroundColor = UIColor(hex: "1a192a")
        cardContainerView.layer.cornerRadius = 16
        cardContainerView.layer.borderWidth = 0.8
        cardContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        cardContainerView.clipsToBounds = false

        // İnce glow efekti
        cardContainerView.layer.shadowColor = UIColor(hex: "b44aaf").cgColor
        cardContainerView.layer.shadowRadius = 4
        cardContainerView.layer.shadowOpacity = 0.15
        cardContainerView.layer.shadowOffset = .zero

        // Görsel - yuvarlak köşe
        storyImageView.layer.cornerRadius = 14
        storyImageView.clipsToBounds = true
        storyImageView.contentMode = .scaleAspectFill

        // Başlık
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        // Alt bilgi
        ageLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        ageLabel.textColor = UIColor.white.withAlphaComponent(0.45)

        // Play butonu
        let playConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: playConfig), for: .normal)
        playButton.tintColor = UIColor(hex: "ad4aaf")
        playButton.setTitle("", for: .normal)

        // Delete butonu
        let deleteConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        deleteButton.setImage(UIImage(systemName: "trash", withConfiguration: deleteConfig), for: .normal)
        deleteButton.tintColor = UIColor.white.withAlphaComponent(0.35)
        deleteButton.setTitle("", for: .normal)
    }

    private func setupEmojiLabel() {
        storyImageView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: storyImageView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: storyImageView.centerYAnchor),
        ])
    }

    // MARK: - Configure

    /// Firestore'dan çekilen favoriler için
    func configure(with story: Story) {
        titleLabel.text = story.title
        ageLabel.text = story.ageCategory
        emojiLabel.isHidden = true
        storyImageView.backgroundColor = .clear
        storyImageView.loadImage(from: story.imageURL)
    }

    /// Yapay zeka ile oluşturulan hikayeler için
    func configureCreated(with story: CreatedStory) {
        titleLabel.text = story.title

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let dateStr = formatter.string(from: story.createdAt)
        ageLabel.text = "\(story.ageCategory) · \(dateStr)"

        // imageURL emoji ise emoji göster, URL ise URL'den yükle
        if story.imageURL.isEmpty {
            storyImageView.image = nil
            emojiLabel.text = "📖"
            emojiLabel.isHidden = false
            storyImageView.backgroundColor = UIColor(hex: "2a2a4a")
        } else if story.imageURL.unicodeScalars.first?.properties.isEmoji == true && !story.imageURL.hasPrefix("http") {
            storyImageView.image = nil
            emojiLabel.text = story.imageURL
            emojiLabel.isHidden = false
            storyImageView.backgroundColor = UIColor(hex: "2a2a4a")
        } else {
            emojiLabel.isHidden = true
            storyImageView.backgroundColor = .clear
            storyImageView.loadImage(from: story.imageURL)
        }
    }

    // MARK: - Actions

    @IBAction func deleteButtonTapped(_ sender: Any) {
        onDeleteTapped?()
    }

    @IBAction func playButtonTapped(_ sender: Any) {
        onPlayTapped?()
    }
}
