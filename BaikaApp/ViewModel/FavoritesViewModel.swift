// BaikaApp/DashBoardControllers/FavoritesViewModel.swift

import Foundation
import FirebaseFirestore

enum SavedTab: Int {
    case favorites = 0
    case created = 1
}

final class FavoritesViewModel {

    // MARK: - Properties
    private let db = Firestore.firestore()
    private(set) var favoriteStories: [Story] = []
    private(set) var createdStories: [CreatedStory] = []
    var currentTab: SavedTab = .favorites

    var onStoriesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Computed

    var isEmpty: Bool {
        switch currentTab {
        case .favorites: return favoriteStories.isEmpty
        case .created: return createdStories.isEmpty
        }
    }

    var itemCount: Int {
        switch currentTab {
        case .favorites: return favoriteStories.count
        case .created: return createdStories.count
        }
    }

    // MARK: - Load

    func loadCurrentTab() {
        switch currentTab {
        case .favorites:
            loadFavoriteStories()
        case .created:
            loadCreatedStories()
        }
    }

    func loadFavoriteStories() {
        let ids = Array(FavoriteManager.shared.getFavoriteIDs())

        guard !ids.isEmpty else {
            favoriteStories = []
            onStoriesUpdated?()
            return
        }

        let chunks = ids.chunked(into: 10)
        var allStories: [Story] = []
        let group = DispatchGroup()

        for chunk in chunks {
            group.enter()
            db.collection("stories")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments(completion: { snapshot, error in
                    defer { group.leave() }
                    if let docs = snapshot?.documents {
                        let stories = docs.compactMap { doc -> Story? in
                            return Story(id: doc.documentID, dictionary: doc.data())
                        }
                        allStories.append(contentsOf: stories)
                    }
                })
        }

        group.notify(queue: .main) { [weak self] in
            let currentFavIDs = FavoriteManager.shared.getFavoriteIDs()
            self?.favoriteStories = allStories.filter { currentFavIDs.contains($0.id ?? "") }
            self?.onStoriesUpdated?()
        }
    }

    func loadCreatedStories() {
        CreatedStoriesManager.shared.fetchCreatedStories { [weak self] in
            self?.createdStories = CreatedStoriesManager.shared.cachedStories
            self?.onStoriesUpdated?()
        }
    }

    // MARK: - Remove

    func removeFavorite(at index: Int) {
        guard index < favoriteStories.count,
              let storyID = favoriteStories[index].id else { return }
        FavoriteManager.shared.toggleFavorite(storyID)
        favoriteStories.remove(at: index)
        onStoriesUpdated?()
    }

    func removeCreatedStory(at index: Int) {
        guard index < createdStories.count,
              let storyID = createdStories[index].id else { return }
        CreatedStoriesManager.shared.deleteCreatedStory(id: storyID) { [weak self] success in
            if success {
                self?.createdStories.remove(at: index)
                DispatchQueue.main.async {
                    self?.onStoriesUpdated?()
                }
            }
        }
    }
}
