//
//  StoriesViewModel.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 20.03.2026.
//

import Foundation
import FirebaseFirestore

class StoriesViewModel {
    
    private let webService: WebServices
    
    // Tüm hikayeler (ham veri)
    private var allStories: [Story] = []
    
    // Filtrelenmiş hikayeler (View'ın göreceği)
    private(set) var displayedStories: [Story] = []
    
    // Seçili filtreler
    var selectedAge: String? = nil
    var selectedTheme: String? = nil
    
    // Filtre verileri
    let ageFilters: [FilterCategory] = [
        FilterCategory(title: "0-2 Yaş", iconName: "baby_icon", id: "0-2 Yaş"),
        FilterCategory(title: "3-4 Yaş", iconName: "kid_icon", id: "3-4 Yaş"),
        FilterCategory(title: "5-6 Yaş", iconName: "child_icon", id: "5-6 Yaş")
    ]
    
    let themeFilters: [FilterCategory] = [
        FilterCategory(title: "Arkadaşlık", iconName: "heart_icon", id: "Arkadaşlık"),
        FilterCategory(title: "Uyku", iconName: "moon_icon", id: "Uyku"),
        FilterCategory(title: "Macera", iconName: "map_icon", id: "Macera"),
        FilterCategory(title: "Iyilik", iconName: "heart_icon", id: "Iyilik")
    ]
    
    // View'ı bilgilendirmek için closure'lar
    var onStoriesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    var isEmpty: Bool {
        return displayedStories.isEmpty
    }
    
    init(webService: WebServices = WebServices()) {
        self.webService = webService
    }
    
    // MARK: - Fetch
    
    func fetchStories() {
        webService.fetchStories { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let stories):
                    self.allStories = stories
                    self.applyFilters()
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Filtering
    
    func toggleAgeFilter(at index: Int) {
        let clickedAge = ageFilters[index].id
        selectedAge = (selectedAge == clickedAge) ? nil : clickedAge
        applyFilters()
    }
    
    func toggleThemeFilter(at index: Int) {
        let clickedTheme = themeFilters[index].id
        selectedTheme = (selectedTheme == clickedTheme) ? nil : clickedTheme
        applyFilters()
    }
    
    func isAgeSelected(at index: Int) -> Bool {
        return ageFilters[index].id == selectedAge
    }
    
    func isThemeSelected(at index: Int) -> Bool {
        return themeFilters[index].id == selectedTheme
    }
    
    private func applyFilters() {
        displayedStories = allStories.filter { story in
            let ageMatch = (selectedAge == nil) || (story.ageCategory == selectedAge)
            let themeMatch = (selectedTheme == nil) || (story.themeCategory == selectedTheme)
            return ageMatch && themeMatch
        }
        onStoriesUpdated?()
    }
    
    // MARK: - Data Access
    
    func story(at index: Int) -> Story {
        return displayedStories[index]
    }
    
    var numberOfStories: Int {
        return displayedStories.count
    }
}
    
     
    
    
