//
//  VoiceOption.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 9.04.2026.
//

import Foundation

struct VoiceOption {
    let name: String          // Gemini TTS voice name (ör: "Kore", "Achernar")
    let modelName: String     // Gemini model adı (ör: "gemini-2.5-flash-tts")
    let displayName: String   // Kullanıcıya gösterilecek isim
    let gender: String        // "Kadın" veya "Erkek"
    let description: String   // Kısa açıklama
    let emoji: String         // Görsel ikon
    
    /// Cache key — model + voice birleşimi
    var cacheKey: String { "\(modelName)::\(name)" }
    
    /// Tüm kullanılabilir ses seçenekleri (Gemini TTS)
    static let allVoices: [VoiceOption] = [
        VoiceOption(
            name: "Kore",
            modelName: "gemini-2.5-flash-tts",
            displayName: "Kore",
            gender: "Kadın",
            description: "Sıcak ve doğal kadın sesi",
            emoji: "🧚‍♀️"
        ),
        VoiceOption(
            name: "Achernar",
            modelName: "gemini-2.5-flash-tts",
            displayName: "Achernar",
            gender: "Erkek",
            description: "Derin ve tok erkek sesi",
            emoji: "🧙‍♂️"
        ),
        VoiceOption(
            name: "Leda",
            modelName: "gemini-2.5-flash-tts",
            displayName: "Leda",
            gender: "Kadın",
            description: "Yumuşak ve melodik kadın sesi",
            emoji: "🌙"
        ),
        VoiceOption(
            name: "Orus",
            modelName: "gemini-2.5-flash-tts",
            displayName: "Orus",
            gender: "Erkek",
            description: "Sakin ve güven veren erkek sesi",
            emoji: "⭐"
        ),
        VoiceOption(
            name: "Zephyr",
            modelName: "gemini-2.5-flash-tts",
            displayName: "Zephyr",
            gender: "Kadın",
            description: "Enerjik ve neşeli kadın sesi",
            emoji: "✨"
        )
    ]
    
    /// Varsayılan ses
    static let defaultVoice = allVoices[0]
    
    /// Kayıtlı ses tercihini UserDefaults'tan al
    static var selectedVoice: VoiceOption {
        get {
            let savedName = UserDefaults.standard.string(forKey: "selectedVoiceName") ?? defaultVoice.name
            return allVoices.first { $0.name == savedName } ?? defaultVoice
        }
        set {
            UserDefaults.standard.set(newValue.name, forKey: "selectedVoiceName")
        }
    }
}
