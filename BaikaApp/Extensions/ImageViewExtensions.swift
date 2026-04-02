//
//  ImageViewExtensions.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 21.03.2026.
//
//
//  ImageViewExtensions.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 21.03.2026.
//
import UIKit
import ObjectiveC

private var taskKey: UInt8 = 0
private var urlKey: UInt8 = 0

// Basit bellek önbelleği
final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

extension UIImageView {
    
    // Mevcut URLSessionDataTask'ı saklayıp iptal edebilmek için
    private var currentTask: URLSessionDataTask? {
        get { objc_getAssociatedObject(self, &taskKey) as? URLSessionDataTask }
        set { objc_setAssociatedObject(self, &taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var currentURL: String? {
        get { objc_getAssociatedObject(self, &urlKey) as? String }
        set { objc_setAssociatedObject(self, &urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Belirtilen URL'den asenkron olarak görsel yükler
    /// - Parameter url: Görselin URL adresi (String)
    func loadImage(from url: String) {
        // Önceki isteği iptal et
        currentTask?.cancel()
        currentTask = nil
        
        // Mevcut görseli temizle (eski görsel görünmesin)
        self.image = nil
        
        // Geçerli URL'yi sakla
        currentURL = url
        
        guard let imageURL = URL(string: url) else {
            print("Geçersiz URL")
            return
        }
        
        // Önbellekte varsa doğrudan kullan
        if let cachedImage = ImageCache.shared.image(forKey: url) {
            self.image = cachedImage
            return
        }
        
        IndicatorView.shared.showIndicator()
        
        let task = URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
            DispatchQueue.main.async {
                IndicatorView.shared.removeIndicator()
            }
            
            if let error = error as? URLError, error.code == .cancelled {
                return // İptal edildiyse sessizce çık
            }
            
            if let error = error {
                print("Görsel yüklenirken hata oluştu: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                // Önbelleğe kaydet
                ImageCache.shared.setImage(image, forKey: url)
                
                DispatchQueue.main.async {
                    // URL hâlâ aynı mı kontrol et (cell reuse koruması)
                    guard self?.currentURL == url else { return }
                    self?.image = image
                }
            }
        }
        
        currentTask = task
        task.resume()
    }
    
    func setThemeEmoji(_ theme: String, size: CGSize = CGSize(width: 40, height: 40)) {
            self.image = EmojiImageHelper.emojiImage(for: theme, size: size)
    }
}
