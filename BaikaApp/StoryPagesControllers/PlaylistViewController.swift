// BaikaApp/StoryPagesControllers/PlaylistViewController.swift

import UIKit
import FirebaseFirestore

// MARK: - Birleşik Playlist Modeli

struct PlaylistItem {
    let title: String
    let subtitle: String
    let content: String
    let emoji: String          // Kapak emojisi
    let source: PlaylistSource
}

enum PlaylistSource {
    case firestore
    case created
}

// MARK: - PlaylistViewController

class PlaylistViewController: UIViewController {

    // MARK: - Properties

    private var firestoreStories: [Story] = []
    private var createdStories: [CreatedStory] = []
    private var playlistItems: [PlaylistItem] = []
    private var selectedIndices: Set<Int> = []
    private let db = Firestore.firestore()

    // MARK: - UI Elements

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Sesli Masallar"
        label.textColor = .white
        label.font = UIFont(name: "Nunito-Bold", size: 20) ?? .boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Dinlemek istediğin masalları seç"
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont(name: "Nunito-Regular", size: 13) ?? .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let selectAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tümünü Seç", for: .normal)
        button.setTitleColor(UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Nunito-SemiBold", size: 13) ?? .systemFont(ofSize: 13, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // Altta beliren oynat butonu
    private let playButtonContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 15/255, green: 14/255, blue: 42/255, alpha: 0.95)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        return button
    }()

    private let playButtonGradient = CAGradientLayer()

    private var playContainerBottom: NSLayoutConstraint!

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = .white
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchAllStories()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playButtonGradient.frame = playButton.bounds
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = UIColor(red: 15/255, green: 14/255, blue: 42/255, alpha: 1.0)
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(backButton)
        view.addSubview(headerLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(selectAllButton)
        view.addSubview(tableView)
        view.addSubview(playButtonContainer)
        playButtonContainer.addSubview(playButton)
        view.addSubview(activityIndicator)

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        selectAllButton.addTarget(self, action: #selector(selectAllTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaylistCell.self, forCellReuseIdentifier: PlaylistCell.identifier)

        // Play button gradient
        playButtonGradient.colors = [
            UIColor(red: 100/255, green: 60/255, blue: 200/255, alpha: 1).cgColor,
            UIColor(red: 150/255, green: 80/255, blue: 220/255, alpha: 1).cgColor
        ]
        playButtonGradient.startPoint = CGPoint(x: 0, y: 0.5)
        playButtonGradient.endPoint = CGPoint(x: 1, y: 0.5)
        playButtonGradient.cornerRadius = 25
        playButton.layer.insertSublayer(playButtonGradient, at: 0)
        updatePlayButton()

        // Play container başlangıçta gizli
        playContainerBottom = playButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 120)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            headerLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            headerLabel.topAnchor.constraint(equalTo: backButton.topAnchor, constant: -2),

            subtitleLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 2),

            selectAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectAllButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            tableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            playButtonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playButtonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playContainerBottom,
            playButtonContainer.heightAnchor.constraint(equalToConstant: 100),

            playButton.topAnchor.constraint(equalTo: playButtonContainer.topAnchor, constant: 12),
            playButton.leadingAnchor.constraint(equalTo: playButtonContainer.leadingAnchor, constant: 24),
            playButton.trailingAnchor.constraint(equalTo: playButtonContainer.trailingAnchor, constant: -24),
            playButton.heightAnchor.constraint(equalToConstant: 50),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Fetch Data

    private func fetchAllStories() {
        activityIndicator.startAnimating()

        let group = DispatchGroup()

        // 1) Firestore hikayeleri
        group.enter()
        db.collection("stories").getDocuments { [weak self] snapshot, error in
            defer { group.leave() }
            if let docs = snapshot?.documents {
                self?.firestoreStories = docs.map { Story(id: $0.documentID, dictionary: $0.data()) }
            }
        }

        // 2) Oluşturulan hikayeler
        group.enter()
        CreatedStoriesManager.shared.fetchCreatedStories(forceRefresh: true) { [weak self] in
            self?.createdStories = CreatedStoriesManager.shared.cachedStories
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            self?.buildPlaylist()
            self?.activityIndicator.stopAnimating()
            self?.tableView.reloadData()
        }
    }

    private func buildPlaylist() {
        playlistItems = []

        // Firestore hikayeleri
        for story in firestoreStories {
            playlistItems.append(PlaylistItem(
                title: story.title,
                subtitle: "\(story.ageCategory) • \(story.themeCategory)",
                content: story.description,
                emoji: EmojiImageHelper.emoji(for: story.themeCategory),
                source: .firestore
            ))
        }

        // Oluşturulan hikayeler
        for created in createdStories {
            let emoji = created.imageURL.unicodeScalars.first?.properties.isEmoji == true && !created.imageURL.hasPrefix("http")
                ? created.imageURL
                : "✨"
            playlistItems.append(PlaylistItem(
                title: created.title,
                subtitle: created.ageCategory,
                content: created.content,
                emoji: emoji,
                source: .created
            ))
        }
    }

    // MARK: - Play Button

    private func updatePlayButton() {
        let count = selectedIndices.count
        if count > 0 {
            playButton.setTitle("▶  \(count) Masal Oynat", for: .normal)
            playButton.setTitleColor(.white, for: .normal)
            playButton.titleLabel?.font = UIFont(name: "Nunito-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
            playButton.alpha = 1.0
            playButton.isEnabled = true
        } else {
            playButton.setTitle("Masal seçin", for: .normal)
            playButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .normal)
            playButton.titleLabel?.font = UIFont(name: "Nunito-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
            playButton.alpha = 0.5
            playButton.isEnabled = false
        }
    }

    private func showPlayButton() {
        guard playContainerBottom.constant != 0 else { return }
        playContainerBottom.constant = 0
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    private func hidePlayButton() {
        guard playContainerBottom.constant != 120 else { return }
        playContainerBottom.constant = 120
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func selectAllTapped() {
        if selectedIndices.count == playlistItems.count {
            // Tümünü kaldır
            selectedIndices.removeAll()
            selectAllButton.setTitle("Tümünü Seç", for: .normal)
            hidePlayButton()
        } else {
            // Tümünü seç
            selectedIndices = Set(0..<playlistItems.count)
            selectAllButton.setTitle("Seçimi Kaldır", for: .normal)
            showPlayButton()
        }
        updatePlayButton()
        tableView.reloadData()
    }

    @objc private func playTapped() {
        guard !selectedIndices.isEmpty else { return }

        let sortedIndices = selectedIndices.sorted()
        let selectedItems = sortedIndices.map { playlistItems[$0] }

        let playerVC = PlayerViewController()
        playerVC.playlist = selectedItems
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
}

// MARK: - UITableView DataSource & Delegate

extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlistItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistCell.identifier, for: indexPath) as! PlaylistCell
        let item = playlistItems[indexPath.row]
        let isSelected = selectedIndices.contains(indexPath.row)
        cell.configure(number: indexPath.row + 1, item: item, isSelected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if selectedIndices.contains(indexPath.row) {
            selectedIndices.remove(indexPath.row)
        } else {
            selectedIndices.insert(indexPath.row)
        }

        // Animasyonlu cell güncelleme
        if let cell = tableView.cellForRow(at: indexPath) as? PlaylistCell {
            let item = playlistItems[indexPath.row]
            let isSelected = selectedIndices.contains(indexPath.row)
            UIView.animate(withDuration: 0.2) {
                cell.configure(number: indexPath.row + 1, item: item, isSelected: isSelected)
            }
        }

        updatePlayButton()
        selectAllButton.setTitle(
            selectedIndices.count == playlistItems.count ? "Seçimi Kaldır" : "Tümünü Seç",
            for: .normal
        )

        if selectedIndices.isEmpty {
            hidePlayButton()
        } else {
            showPlayButton()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        72
    }
}

// MARK: - PlaylistCell

class PlaylistCell: UITableViewCell {

    static let identifier = "PlaylistCell"

    private let cardView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Nunito-Bold", size: 14) ?? .boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Nunito-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Nunito-Regular", size: 12) ?? .systemFont(ofSize: 12)
        label.textColor = UIColor.white.withAlphaComponent(0.4)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1.5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let checkImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold))
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView)
        cardView.addSubview(numberLabel)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(checkView)
        checkView.addSubview(checkImage)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            numberLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            numberLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            numberLabel.widthAnchor.constraint(equalToConstant: 24),

            emojiLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 8),
            emojiLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 36),

            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: checkView.leadingAnchor, constant: -10),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            checkView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            checkView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            checkView.widthAnchor.constraint(equalToConstant: 24),
            checkView.heightAnchor.constraint(equalToConstant: 24),

            checkImage.centerXAnchor.constraint(equalTo: checkView.centerXAnchor),
            checkImage.centerYAnchor.constraint(equalTo: checkView.centerYAnchor),
        ])
    }

    func configure(number: Int, item: PlaylistItem, isSelected: Bool) {
        let purpleColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1)

        numberLabel.text = "\(number)"
        emojiLabel.text = item.emoji
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle

        if isSelected {
            cardView.backgroundColor = purpleColor.withAlphaComponent(0.12)
            cardView.layer.borderWidth = 1
            cardView.layer.borderColor = purpleColor.withAlphaComponent(0.4).cgColor
            numberLabel.textColor = purpleColor
            checkView.backgroundColor = purpleColor
            checkView.layer.borderColor = purpleColor.cgColor
            checkImage.isHidden = false
        } else {
            cardView.backgroundColor = UIColor(red: 22/255, green: 21/255, blue: 50/255, alpha: 1)
            cardView.layer.borderWidth = 0.5
            cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor
            numberLabel.textColor = UIColor.white.withAlphaComponent(0.35)
            checkView.backgroundColor = .clear
            checkView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
            checkImage.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        numberLabel.text = nil
        emojiLabel.text = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
}
