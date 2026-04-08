//
//  EmojiHelpers.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 22.03.2026.
//

import UIKit

final class EmojiImageHelper {
    
    // Karakter → Emoji eşleştirmesi
    private static let characterEmojiMap: [String: String] = [
        "ayı": "🐻",
        "tavşan": "🐰",
        "kedi": "🐱",
        "köpek": "🐶",
        "tilki": "🦊",
        "balık": "🐟",
    ]

    // MARK: - Karaktere göre emoji string döndür
    static func characterEmoji(for character: String) -> String {
        return characterEmojiMap[character.lowercased()] ?? "🐻"
    }

    // Tema → Emoji eşleştirmesi
    private static let themeEmojiMap: [String: String] = [
        "macera": "⚔️",
        "adventure": "⚔️",
        "aşk": "❤️",
        "love": "❤️",
        "romantik": "❤️",
        "korku": "👻",
        "horror": "👻",
        "bilim kurgu": "🚀",
        "sci-fi": "🚀",
        "fantastik": "🧙‍♂️",
        "fantasy": "🧙‍♂️",
        "komedi": "😂",
        "comedy": "😂",
        "doğa": "🌿",
        "nature": "🌿",
        "hayvanlar": "🐾",
        "animals": "🐾",
        "uzay": "🌌",
        "space": "🌌",
        "deniz": "🌊",
        "sea": "🌊",
        "prenses": "👸",
        "princess": "👸",
        "ejderha": "🐉",
        "dragon": "🐉",
        "arkadaşlık": "🤝",
        "friendship": "🤝",
        "müzik": "🎵",
        "music": "🎵",
        "uyku": "😴",
        "sleep": "😴",
        "iyilik": "💛",
        "kindness": "💛",
        "0-2 yaş": "👶",
        "0-2 years": "👶",
        "3-4 yaş": "🧒",
        "3-4 years": "🧒",
        "5-6 yaş": "👦",
        "5-6 years": "👦"
    ]
    
    static let defaultEmoji = "📖"
    
    // MARK: - Temaya göre emoji string döndür
    static func emoji(for theme: String) -> String {
        return themeEmojiMap[theme.lowercased()] ?? defaultEmoji
    }
    
    // MARK: - Emoji'yi UIImage'a çevir
    static func emojiImage(for theme: String, size: CGSize = CGSize(width: 40, height: 40)) -> UIImage? {
        let emoji = emoji(for: theme)
        let outputSize = size == .zero ? CGSize(width: 40, height: 40) : size
        let renderer = UIGraphicsImageRenderer(size: outputSize)
        return renderer.image { _ in
            let font = UIFont.systemFont(ofSize: outputSize.height * 0.8)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let textSize = emoji.size(withAttributes: attributes)
            let origin = CGPoint(
                x: (outputSize.width - textSize.width) / 2,
                y: (outputSize.height - textSize.height) / 2
            )
            emoji.draw(at: origin, withAttributes: attributes)
        }
    }
}
