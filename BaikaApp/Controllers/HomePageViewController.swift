//
//  ViewController.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 14.03.2026.
//

import UIKit

class HomePageViewController: UIViewController {
    
    
    @IBOutlet weak var starIconImageView: UIImageView!
    
    
    @IBOutlet weak var readStoriesCard: CustomStoryCardControl!
    @IBOutlet weak var createNewStoryCard: CustomStoryCardControl!
    @IBOutlet weak var voiceStoryCard: CustomStoryCardControl!
    
    private var didStartAnimations = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Eğer animasyonlar henüz başlamadıysa başlat
        if !didStartAnimations {
            
            // Ufak bir gecikme ekliyoruz ki arayüz nefes alsın, geçişler pürüzsüz olsun
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.animateStarIcon()
                self.createTwinklingStars(count: 50)
            }
            
            // Bayrağı true yapıyoruz ki bu fonksiyon tekrar çağrılırsa animasyonlar baştan başlamasın
            didStartAnimations = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupCards()
       
    }
    
    private func animateStarIcon() {
        // 1. GÜVENLİK KONTROLÜ: IBOutlet gerçekten bağlı mı?
        guard starIconImageView != nil else {
            print("🔴 HATA: starImageView bağlantısı kopmuş! Storyboard'dan tekrar bağlamalısın.")
            return
        }
        
        
        // Varsa eski animasyonları temizle (çakışmayı önler)
        starIconImageView.layer.removeAllAnimations()
        
        // 2. EKSEN BELİRTME: Sadece 'transform.rotation' yerine Z eksenini (ekran yüzeyini) net belirtiyoruz
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        
        // Açılar (-15 ile +15 derece arası)
        animation.fromValue = -CGFloat.pi / 12
        animation.toValue = CGFloat.pi / 12
        
        animation.duration = 1.2
        animation.autoreverses = true
        
        // 3. GARANTİ TEKRAR: .infinity bazen sorun yaratır, onun yerine en büyük sayıyı veriyoruz
        animation.repeatCount = .greatestFiniteMagnitude
        
        // 4. ARKA PLAN KORUMASI: Başka ekrana gidip gelince veya uygulamayı alta alınca animasyonun donmasını engeller
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        // Yumuşak geçiş
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Animasyonu başlat
        starIconImageView.layer.add(animation, forKey: "swingingStarAnimation")
        
        print("🟢 BAŞARILI: Yıldız animasyonu tetiklendi!")
    }
    
    private func createTwinklingStars(count: Int = 20) {
        let screenWidth = self.view.bounds.width
            // Sadece üst kısımda çıkması için
            let topSectionHeight = self.view.bounds.height / 2.5
            
            for i in 0..<count {
                // 1. Rastgele boyut ve pozisyon
                let size = CGFloat.random(in: 2...4)
                let randomX = CGFloat.random(in: 0...screenWidth)
                let randomY = CGFloat.random(in: 0...topSectionHeight)
                
                let dot = UIView(frame: CGRect(x: randomX, y: randomY, width: size, height: size))
                dot.backgroundColor = UIColor(named: "warmYellow") ?? .white
                dot.layer.cornerRadius = size / 2
                dot.alpha = 0.0 // Başlangıçta görünmez
                
                self.view.addSubview(dot)
                self.view.sendSubviewToBack(dot)
                
                // 2. ÇÖZÜM: CABasicAnimation ile Opaklık (Alpha) Animasyonu
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.fromValue = 0.0 // Görünmezden başla
                animation.toValue = CGFloat.random(in: 0.4...1.0) // Rastgele bir parlaklığa çık
                
                animation.duration = TimeInterval.random(in: 1.0...3.0)
                animation.autoreverses = true // Geri sön
                
                // 3. ASLA DURMAMASI İÇİN GEREKEN AYARLAR
                animation.repeatCount = .greatestFiniteMagnitude
                animation.isRemovedOnCompletion = false
                animation.fillMode = .forwards
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                
                // 4. Gecikme (Delay) Ayarı
                // CoreAnimation'da gecikme vermek için sistemin o anki saatine ekleme yapmalıyız
                let randomDelay = TimeInterval.random(in: 0.0...2.0)
                animation.beginTime = CACurrentMediaTime() + randomDelay
                
                // Animasyonu noktaya ekliyoruz. Her noktanın farklı bir anahtarı (key) olması için 'i' kullanıyoruz.
                dot.layer.add(animation, forKey: "twinkleAnimation_\(i)")
            }
    }
    
    private func setupBackground() {
            view.backgroundColor = AppColors.background
        }
    
    private func setupCards(){
        readStoriesCard.configure(type: .readStories)
        createNewStoryCard.configure(type: .createStory)
        voiceStoryCard.configure(type: .audioStory)
                                
    }
    
    @IBAction func readStoriesTapped(_ sender: Any) {
        print("Stories card tapped")
        tabBarController?.selectedIndex = 1
    }
    
    @IBAction func createNewStoryTapped(_ sender: Any) {
        print("Create New Story tapped")
        tabBarController?.selectedIndex = 2
    }
    
    @IBAction func voiceStoryTapped(_ sender: Any) {
        print("Voice Story tapped")
        tabBarController?.selectedIndex = 1
        
    }
    
    

}

