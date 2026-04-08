//
//  CreateStoryViewModel.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 6.04.2026.
//

import Foundation

// Ekranın o anki durumlarını temsil eden Enum
enum StoryViewState {
    case idle
    case loading
    case success(String) // İçinde masal metnini taşır
    case error(String)   // İçinde hata mesajını taşır
}

class StoryViewModel {
    
    private let service: StoryServiceProtocol
    
    // View'ın (ViewController) dinleyeceği closure
    var onStateChange: ((StoryViewState) -> Void)?
    
    // Durum her değiştiğinde UI'ı otomatik tetikler
    private var state: StoryViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    // Dependency Injection (Service dışarıdan alınır)
    init(service: StoryServiceProtocol = StoryService()) {
        self.service = service
    }
    
    func fetchStory(childName: String, character: String, setting: String, theme: String, ageGroup: String) {
        // Durumu yükleniyor yap
        state = .loading
        
        let parameters = StoryParameters(
            childName: childName,
            character: character,
            place: setting,
            theme: theme,
            ageGroup: ageGroup
        )
        
        Task {
            do {
                let storyText = try await service.generateStory(parameters: parameters)
                // UI güncellemeleri ana thread'de olmalı
                await MainActor.run {
                    self.state = .success(storyText)
                }
            } catch {
                await MainActor.run {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }
}
