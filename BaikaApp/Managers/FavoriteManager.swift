// BaikaApp/Managers/FavoriteManager.swift

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FavoriteManager {

    static let shared = FavoriteManager()

    // MARK: - Notifications
    static let favoritesDidChangeNotification = Notification.Name("favoritesDidChange")

    // MARK: - Properties
    private let db = Firestore.firestore()
    private var cachedFavoriteIDs: Set<String> = []
    private var pendingSync: Set<String>?
    private var debounceTimer: Timer?
    private let debounceInterval: TimeInterval = 2.0
    private var hasFetchedFromRemote = false

    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

    private var localCacheKey: String {
        guard let uid = userID else { return "favorites_guest" }
        return "favorites_\(uid)"
    }

    private init() {
        loadFromLocal()
    }

    // MARK: - Public API

    /// Uygulama ilk açılışta veya login sonrası çağır
    func fetchFavoritesIfNeeded(completion: (() -> Void)? = nil) {
        guard !hasFetchedFromRemote, let uid = userID else {
            completion?()
            return
        }

        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let data = snapshot?.data(),
               let ids = data["favoriteStoryIDs"] as? [String] {
                self.cachedFavoriteIDs = Set(ids)
                self.saveToLocal()
                self.hasFetchedFromRemote = true
                self.notifyChange()
            }
            completion?()
        }
    }

    func isFavorite(_ storyID: String) -> Bool {
        cachedFavoriteIDs.contains(storyID)
    }

    func toggleFavorite(_ storyID: String) {
        if cachedFavoriteIDs.contains(storyID) {
            cachedFavoriteIDs.remove(storyID)
        } else {
            cachedFavoriteIDs.insert(storyID)
        }
        saveToLocal()
        notifyChange()
        scheduleSyncToFirestore()
    }

    func getFavoriteIDs() -> Set<String> {
        cachedFavoriteIDs
    }

    /// Logout sırasında çağır
    func clearCache() {
        debounceTimer?.invalidate()
        syncToFirestoreNow()
        cachedFavoriteIDs.removeAll()
        hasFetchedFromRemote = false
        UserDefaults.standard.removeObject(forKey: localCacheKey)
    }

    /// App background'a geçerken çağır
    func flushIfNeeded() {
        debounceTimer?.invalidate()
        syncToFirestoreNow()
    }

    // MARK: - Local Cache

    private func saveToLocal() {
        let array = Array(cachedFavoriteIDs)
        UserDefaults.standard.set(array, forKey: localCacheKey)
    }

    private func loadFromLocal() {
        if let array = UserDefaults.standard.stringArray(forKey: localCacheKey) {
            cachedFavoriteIDs = Set(array)
        }
    }

    // MARK: - Debounced Firestore Sync

    private func scheduleSyncToFirestore() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(
            withTimeInterval: debounceInterval,
            repeats: false
        ) { [weak self] _ in
            self?.syncToFirestoreNow()
        }
    }

    private func syncToFirestoreNow() {
        guard let uid = userID else { return }
        let ids = Array(cachedFavoriteIDs)

        db.collection("users").document(uid).setData(
            ["favoriteStoryIDs": ids],
            merge: true
        ) { error in
            if let error = error {
                print("Favori senkronizasyon hatası: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Notification

    private func notifyChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: FavoriteManager.favoritesDidChangeNotification,
                object: nil
            )
        }
    }
}//
//  FavoriteManager.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 8.04.2026.
//

