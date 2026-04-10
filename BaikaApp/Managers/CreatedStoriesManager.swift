// BaikaApp/Managers/CreatedStoriesManager.swift

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

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
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                            audioStoragePath: data["audioStoragePath"] as? String
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

        var data: [String: Any] = [
            "title": story.title,
            "content": story.content,
            "ageCategory": story.ageCategory,
            "imageURL": story.imageURL,
            "createdAt": Timestamp(date: story.createdAt)
        ]

        if let audioPath = story.audioStoragePath {
            data["audioStoragePath"] = audioPath
        }

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

        // Silinecek hikayenin audioStoragePath'ini bul
        let audioPath = cachedStories.first(where: { $0.id == id })?.audioStoragePath

        db.collection("users").document(uid).collection("createdStories")
            .document(id).delete { [weak self] error in
                if error == nil {
                    self?.cachedStories.removeAll { $0.id == id }
                    
                    // Firebase Storage'dan ses dosyasını sil
                    if let audioPath = audioPath, !audioPath.isEmpty {
                        Storage.storage().reference().child(audioPath).delete { storageError in
                            if let storageError = storageError {
                                print("Storage ses silme hatası: \(storageError.localizedDescription)")
                            } else {
                                print("🗑️ Storage'dan ses dosyası silindi: \(audioPath)")
                            }
                        }
                    }
                    
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
