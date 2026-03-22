//
//  ImageViewExtensions.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 21.03.2026.
//
import UIKit

extension UIImageView {
    /// Belirtilen URL'den asenkron olarak görsel yükler
    /// - Parameter url: Görselin URL adresi (String)
    func loadImage(from url: String) {
        
        IndicatorView.shared.showIndicator()
        guard let imageURL = URL(string: url) else {
            print("Geçersiz URL") // URL hatalıysa konsola hata yazdır
            return
        }
        
        // URLSession kullanarak asenkron veri isteği gönder
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let error = error {
                print("Görsel yüklenirken hata oluştu: \(error)")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                // Ana iş parçacığında UI güncellemesi yap
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume() // İstek başlatılır
        IndicatorView.shared.removeIndicator()
    }
    
    func setThemeEmoji(_ theme: String) {
        self.image = EmojiImageHelper.emojiImage(for: theme, size: bounds.size)
    }
    
}
