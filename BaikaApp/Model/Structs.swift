//
//  Structs.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 15.03.2026.
//

import Foundation
import FirebaseFirestore

struct Deneme : Decodable {
    let name: String
    let price: Double
    
}
struct Story: Identifiable, Codable {
    @DocumentID var id: String?
     let time: String
     let title: String
     let description: String
     let imageURL: String
     let ageCategory: String
     let themeCategory: String
     let isFavorite: Bool
     
     init(id: String, dictionary: [String: Any]) {
         self.id = id
         self.time = dictionary["time"] as? String ?? ""
         self.title = dictionary["title"] as? String ?? ""
         self.description = dictionary["description"] as? String ?? ""
         self.imageURL = dictionary["imageURL"] as? String ?? ""
         self.ageCategory = dictionary["ageCategory"] as? String ?? ""
         self.themeCategory = dictionary["themeCategory"] as? String ?? ""
         self.isFavorite = dictionary["isFavorite"] as? Bool ?? false
     } // Örn: "Uyku", "Macera", "Arkadaslik"
}

struct FilterCategory {
    let title: String
    let iconName: String
    let id: String
}


