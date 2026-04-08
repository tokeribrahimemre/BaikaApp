// BaikaApp/Managers/CreatedStoriesManager.swift

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class CreatedStoriesManager {

    static let shared = CreatedStoriesManager()
    static let storiesDidChangeNotification = Notification.Name("createdStoriesDidChange")

    private let db = Firestore.firestore()
    private(set) var cachedStories: [CreatedStory] = []
    private var hasFetchedFromRemote = false

    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

    private init() {}

    // MARK: - Fetch

    func fetchCreatedStories(forceRefresh: Bool = false, completion: (() -> Void)? = nil) {
        guard let uid = userID else {
            completion?()
            return
        }

        if !forceRefresh && hasFetchedFromRemote && !cachedStories.isEmpty {
            completion?()
            return
        }

        db.collection("users").document(uid).collection("createdStories")
            .order(by: "createdAt", descending: true)
            .getDocuments(completion: { [weak self] snapshot, error in
                guard let self = self else { return }
                if let docs = snapshot?.documents {
                    self.cachedStories = docs.compactMap { doc -> CreatedStory? in
                        let data = doc.data()
                        return CreatedStory(
                            id: doc.documentID,
                            title: data["title"] as? String ?? "",
                            content: data["content"] as? String ?? "",
                            ageCategory: data["ageCategory"] as? String ?? "",
                            imageURL: data["imageURL"] as? String ?? "",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                        )
                    }
                    self.hasFetchedFromRemote = true
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: CreatedStoriesManager.storiesDidChangeNotification,
                            object: nil
                        )
                        completion?()
                    }
                } else {
                    completion?()
                }
            })
    }

    // MARK: - Save

    func saveCreatedStory(_ story: CreatedStory, completion: ((Bool) -> Void)? = nil) {
        guard let uid = userID else {
            completion?(false)
            return
        }

        let data: [String: Any] = [
            "title": story.title,
            "content": story.content,
            "ageCategory": story.ageCategory,
            "imageURL": story.imageURL,
            "createdAt": Timestamp(date: story.createdAt)
        ]

        db.collection("users").document(uid).collection("createdStories")
            .addDocument(data: data) { [weak self] error in
                if error == nil {
                    self?.fetchCreatedStories(forceRefresh: true)
                }
                completion?(error == nil)
            }
    }

    // MARK: - Delete

    func deleteCreatedStory(id: String, completion: ((Bool) -> Void)? = nil) {
        guard let uid = userID else {
            completion?(false)
            return
        }

        db.collection("users").document(uid).collection("createdStories")
            .document(id).delete { [weak self] error in
                if error == nil {
                    self?.cachedStories.removeAll { $0.id == id }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: CreatedStoriesManager.storiesDidChangeNotification,
                            object: nil
                        )
                    }
                }
                completion?(error == nil)
            }
    }

    // MARK: - Clear

    func clearCache() {
        cachedStories.removeAll()
        hasFetchedFromRemote = false
    }
}
