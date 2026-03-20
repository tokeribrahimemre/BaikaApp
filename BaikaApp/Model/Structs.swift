//
//  Structs.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 15.03.2026.
//

import Foundation

struct Deneme : Decodable {
    let name: String
    let price: Double
    
}
struct Story {
     let id: String
     let title: String
     let description: String
     let imageUrl: String
     let ageCategory: String
     let themeCategory: String
     let isFavorite: Bool
     
     init(id: String, dictionary: [String: Any]) {
         self.id = id
         self.title = dictionary["title"] as? String ?? ""
         self.description = dictionary["description"] as? String ?? ""
         self.imageUrl = dictionary["imageUrl"] as? String ?? ""
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
