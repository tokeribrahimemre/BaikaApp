// BaikaApp/DashBoardControllers/FavoritesViewController.swift

import UIKit

class FavoritesViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateImageView: UIImageView!
    @IBOutlet weak var emptyStateTitleLabel: UILabel!
    @IBOutlet weak var emptyStateSubtitleLabel: UILabel!
    @IBOutlet weak var emptyStateButton: UIButton!

    // MARK: - Properties
    private let viewModel = FavoritesViewModel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Kaydedilenler"
        setupHeader()
        setupSegmentedControl()
        setupTableView()
        bindViewModel()
        observeChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCurrentTab()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    /// Storyboard'daki header butonunu dekoratif kalp ikonu ile değiştirir
    private func setupHeader() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let heartImage = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)?
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        
        headerButton.configuration = nil
        headerButton.setTitle(nil, for: .normal)
        headerButton.setImage(heartImage, for: .normal)
        headerButton.setImage(heartImage, for: .disabled)
        headerButton.tintColor = .systemRed
        headerButton.adjustsImageWhenDisabled = false
        headerButton.isUserInteractionEnabled = false
        
        headerTitleLabel.text = "Kaydedilenler"
    }

    // Custom segment butonları
    private let segmentContainerView = UIView()
    private let favoritesButton = UIButton(type: .system)
    private let createdButton = UIButton(type: .system)
    private let selectionIndicator = UIView()

    private func setupSegmentedControl() {
        // Orijinal segmented control'ü gizle
        segmentedControl.isHidden = true

        // Container - koyu arka plan pill şekli
        segmentContainerView.backgroundColor = UIColor(hex: "1a1a3e")
        segmentContainerView.layer.cornerRadius = 16
        segmentContainerView.layer.borderWidth = 1
        segmentContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor
        segmentContainerView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.superview?.addSubview(segmentContainerView)

        // Container'ı segmented control ile aynı yere koy
        NSLayoutConstraint.activate([
            segmentContainerView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor, constant: 16),
            segmentContainerView.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor, constant: -16),
            segmentContainerView.topAnchor.constraint(equalTo: segmentedControl.topAnchor),
            segmentContainerView.heightAnchor.constraint(equalToConstant: 48)
        ])

        // Selection indicator - seçili segmentin arka planı (glow efektli)
        selectionIndicator.backgroundColor = UIColor(hex: "2a1a3e")
        selectionIndicator.layer.cornerRadius = 20
        selectionIndicator.layer.borderWidth = 1.2
        selectionIndicator.layer.borderColor = UIColor(hex: "b44aaf").withAlphaComponent(0.7).cgColor
        selectionIndicator.layer.shadowColor = UIColor(hex: "b44aaf").cgColor
        selectionIndicator.layer.shadowRadius = 8
        selectionIndicator.layer.shadowOpacity = 0.5
        selectionIndicator.layer.shadowOffset = .zero
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        segmentContainerView.addSubview(selectionIndicator)

        // Butonları oluştur
        favoritesButton.setTitle("❤️ Favoriler", for: .normal)
        favoritesButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        favoritesButton.setTitleColor(.white, for: .normal)
        favoritesButton.backgroundColor = .clear
        favoritesButton.tag = 0
        favoritesButton.addTarget(self, action: #selector(customSegmentTapped(_:)), for: .touchUpInside)
        favoritesButton.translatesAutoresizingMaskIntoConstraints = false

        createdButton.setTitle("✨ Oluşturulanlar", for: .normal)
        createdButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        createdButton.setTitleColor(UIColor.white.withAlphaComponent(0.45), for: .normal)
        createdButton.backgroundColor = .clear
        createdButton.tag = 1
        createdButton.addTarget(self, action: #selector(customSegmentTapped(_:)), for: .touchUpInside)
        createdButton.translatesAutoresizingMaskIntoConstraints = false

        segmentContainerView.addSubview(favoritesButton)
        segmentContainerView.addSubview(createdButton)

        // Butonları yan yana diz (aralarında 6pt boşluk)
        let spacing: CGFloat = 8
        NSLayoutConstraint.activate([
            favoritesButton.leadingAnchor.constraint(equalTo: segmentContainerView.leadingAnchor, constant: 4),
            favoritesButton.topAnchor.constraint(equalTo: segmentContainerView.topAnchor, constant: 4),
            favoritesButton.bottomAnchor.constraint(equalTo: segmentContainerView.bottomAnchor, constant: -4),

            createdButton.leadingAnchor.constraint(equalTo: favoritesButton.trailingAnchor, constant: spacing),
            createdButton.trailingAnchor.constraint(equalTo: segmentContainerView.trailingAnchor, constant: -4),
            createdButton.topAnchor.constraint(equalTo: segmentContainerView.topAnchor, constant: 4),
            createdButton.bottomAnchor.constraint(equalTo: segmentContainerView.bottomAnchor, constant: -4),
            createdButton.widthAnchor.constraint(equalTo: favoritesButton.widthAnchor),
        ])

        // İlk durumda indicator'ı sol tarafa yerleştir
        segmentContainerView.layoutIfNeeded()
        updateSelectionIndicator(selectedIndex: 0, animated: false)
    }

    private func updateSelectionIndicator(selectedIndex: Int, animated: Bool) {
        let targetButton = selectedIndex == 0 ? favoritesButton : createdButton

        // Yazı renklerini güncelle
        favoritesButton.setTitleColor(selectedIndex == 0 ? .white : UIColor.white.withAlphaComponent(0.45), for: .normal)
        favoritesButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: selectedIndex == 0 ? .semibold : .medium)
        createdButton.setTitleColor(selectedIndex == 1 ? .white : UIColor.white.withAlphaComponent(0.45), for: .normal)
        createdButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: selectedIndex == 1 ? .semibold : .medium)

        // Indicator'ın mevcut constraint'lerini kaldır
        selectionIndicator.constraints.forEach { selectionIndicator.removeConstraint($0) }
        selectionIndicator.superview?.constraints
            .filter { $0.firstItem === selectionIndicator || $0.secondItem === selectionIndicator }
            .forEach { $0.isActive = false }

        NSLayoutConstraint.activate([
            selectionIndicator.leadingAnchor.constraint(equalTo: targetButton.leadingAnchor),
            selectionIndicator.trailingAnchor.constraint(equalTo: targetButton.trailingAnchor),
            selectionIndicator.topAnchor.constraint(equalTo: targetButton.topAnchor),
            selectionIndicator.bottomAnchor.constraint(equalTo: targetButton.bottomAnchor),
        ])

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.segmentContainerView.layoutIfNeeded()
            }
        }
    }

    @objc private func customSegmentTapped(_ sender: UIButton) {
        let index = sender.tag
        updateSelectionIndicator(selectedIndex: index, animated: true)
        viewModel.currentTab = SavedTab(rawValue: index) ?? .favorites
        viewModel.loadCurrentTab()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            UINib(nibName: "FavoriteStoryCell", bundle: nil),
            forCellReuseIdentifier: "FavoriteStoryCell"
        )
    }

    private func bindViewModel() {
        viewModel.onStoriesUpdated = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.updateEmptyState()
        }
    }

    private func observeChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesDidChange),
            name: FavoriteManager.favoritesDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(createdStoriesDidChange),
            name: CreatedStoriesManager.storiesDidChangeNotification,
            object: nil
        )
    }

    // MARK: - Empty State

    private func updateEmptyState() {
        let isEmpty = viewModel.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty

        switch viewModel.currentTab {
        case .favorites:
            emptyStateTitleLabel.text = "Henüz favori hikaye yok"
            emptyStateSubtitleLabel.text = "Beğendiğin hikayeleri favorilere ekle!"
            emptyStateButton.setTitle("Hikayelere Git", for: .normal)
        case .created:
            emptyStateTitleLabel.text = "Henüz oluşturulmuş hikaye yok"
            emptyStateSubtitleLabel.text = "Yapay zeka ile kendi masalını oluştur!"
            emptyStateButton.setTitle("Hikaye Oluştur", for: .normal)
        }
    }

    // MARK: - Actions

    // segmentChanged artık customSegmentTapped ile değiştirildi

    @IBAction func emptyStateButtonTapped(_ sender: Any) {
        switch viewModel.currentTab {
        case .favorites:
            // Hikayeler tabına geç
            tabBarController?.selectedIndex = 1
        case .created:
            // Hikaye oluşturma sayfasına git
            let storyboard = UIStoryboard(name: "CreateAIStory", bundle: nil)
            if let createVC = storyboard.instantiateViewController(withIdentifier: "CreateAIStoryVC") as? CreateAIStoryViewController {
                navigationController?.pushViewController(createVC, animated: true)
            }
        }
    }

    @objc private func favoritesDidChange() {
        if isViewLoaded && view.window != nil && viewModel.currentTab == .favorites {
            viewModel.loadFavoriteStories()
        }
    }

    @objc private func createdStoriesDidChange() {
        if isViewLoaded && view.window != nil && viewModel.currentTab == .created {
            viewModel.loadCreatedStories()
        }
    }

    // MARK: - Cell Actions

    private func playStory(at index: Int) {
        switch viewModel.currentTab {
        case .favorites:
            guard index < viewModel.favoriteStories.count else { return }
            let story = viewModel.favoriteStories[index]
            let storyboard = UIStoryboard(name: "StoryDetails", bundle: nil)
            let detailVC = storyboard.instantiateViewController(
                identifier: "StoryDetail",
                creator: { coder in
                    StoryDetailsViewController(coder: coder, story: story)
                }
            )
            navigationController?.pushViewController(detailVC, animated: true)
        case .created:
            guard index < viewModel.createdStories.count else { return }
            let created = viewModel.createdStories[index]
            let generated = GeneratedStory(
                title: created.title,
                subtitle: "\(created.ageCategory) yaş grubu",
                emojis: "✨📖",
                content: created.content,
                childName: "",
                character: "",
                characterEmoji: created.imageURL,
                place: "",
                theme: "",
                ageGroup: created.ageCategory
            )
            let storyboard = UIStoryboard(name: "StoryRead", bundle: nil)
            if let readVC = storyboard.instantiateViewController(withIdentifier: "StoryReadVC") as? StoryReadViewController {
                readVC.story = generated
                readVC.modalPresentationStyle = .fullScreen
                navigationController?.pushViewController(readVC, animated: true)
            }
        }
    }

    private func deleteStory(at index: Int) {
        switch viewModel.currentTab {
        case .favorites:
            viewModel.removeFavorite(at: index)
        case .created:
            viewModel.removeCreatedStory(at: index)
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.itemCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoriteStoryCell",
            for: indexPath
        ) as? FavoriteStoryCell else {
            return UITableViewCell()
        }

        switch viewModel.currentTab {
        case .favorites:
            let story = viewModel.favoriteStories[indexPath.row]
            cell.configure(with: story)
        case .created:
            let created = viewModel.createdStories[indexPath.row]
            cell.configureCreated(with: created)
        }

        cell.selectionStyle = .none
        cell.onPlayTapped = { [weak self] in
            self?.playStory(at: indexPath.row)
        }
        cell.onDeleteTapped = { [weak self] in
            self?.deleteStory(at: indexPath.row)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
}
