//
//  WebServices.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 15.03.2026.
//
import Foundation
import FirebaseFirestore

enum WebServiceError: Error {
    case serverError
    case parsinError
}


class WebServices {
    private let db = Firestore.firestore()
        
        func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void) {
            db.collection("stories").getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let stories = documents.map { doc in
                    Story(id: doc.documentID, dictionary: doc.data())
                }
                
                completion(.success(stories))
            }
        }
}

