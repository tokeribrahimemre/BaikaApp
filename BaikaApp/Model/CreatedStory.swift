//
//  Untitled.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 8.04.2026.
//

// BaikaApp/Models/CreatedStory.swift

import Foundation

struct CreatedStory {
    var id: String?
    var title: String
    var content: String
    var ageCategory: String
    var imageURL: String
    var createdAt: Date

    init(id: String? = nil, title: String, content: String, ageCategory: String, imageURL: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.ageCategory = ageCategory
        self.imageURL = imageURL
        self.createdAt = createdAt
    }
}
