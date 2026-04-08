//
//  AIStructs.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 6.04.2026.
//

import Foundation

// Masal oluşturmak için gereken parametreler
struct StoryParameters {
    let childName: String
    let character: String
    let place: String
    let theme: String
    let ageGroup: String
    
    // Firebase'in istediği Dictionary formatına dönüştürücü
    var toDictionary: [String: String] {
        return [
            "cocuk_adi": childName,
            "karakter": character,
            "yer": place,
            "tema": theme,
            "yas": ageGroup
        ]
    }
}
