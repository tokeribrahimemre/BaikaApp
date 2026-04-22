//
//  ViewController.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 14.03.2026.
//

import UIKit
import FirebaseAuth

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
        setupTipCard()
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
    
    // MARK: - Tip Card
    
    private func setupTipCard() {
        // voiceStoryCard'ın parent'ları üzerinden ana stackView'a ulaş
        // Yapı: mainStackView > cardsStackView > wrapperView > voiceStoryCard
        guard let cardsStack = voiceStoryCard.superview?.superview,
              let mainStack = cardsStack.superview as? UIStackView else { return }
        
        // Wrapper view (padding için)
        let wrapperView = UIView()
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.backgroundColor = .clear
        
        // Tip container
        let tipContainer = UIView()
        tipContainer.translatesAutoresizingMaskIntoConstraints = false
        tipContainer.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        tipContainer.layer.cornerRadius = 16
        tipContainer.layer.borderWidth = 1
        tipContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        
        // Horizontal stack: icon + text
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.alignment = .top
        hStack.spacing = 10
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Lightbulb emoji
        let iconLabel = UILabel()
        iconLabel.text = "💡"
        iconLabel.font = .systemFont(ofSize: 20)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.setContentHuggingPriority(.required, for: .horizontal)
        iconLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Tip text with attributed string
        let tipLabel = UILabel()
        tipLabel.numberOfLines = 0
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let fullText = "İpucu: Her masal o an sadece size özel olarak sıfırdan yazılır ve özenle seslendirilir. Bu büyülü hazırlık birkaç saniye sürebilir, beklediğinize kesinlikle değecek!"
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont(name: "Nunito-Regular", size: 13) ?? .systemFont(ofSize: 13),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
        )
        // "İpucu:" kısmını bold yap
        if let range = fullText.range(of: "İpucu:") {
            let nsRange = NSRange(range, in: fullText)
            attributed.addAttributes([
                .font: UIFont(name: "Nunito-Bold", size: 13) ?? .boldSystemFont(ofSize: 13),
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ], range: nsRange)
        }
        tipLabel.attributedText = attributed
        
        // Assemble
        hStack.addArrangedSubview(iconLabel)
        hStack.addArrangedSubview(tipLabel)
        
        tipContainer.addSubview(hStack)
        wrapperView.addSubview(tipContainer)
        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: tipContainer.topAnchor, constant: 14),
            hStack.leadingAnchor.constraint(equalTo: tipContainer.leadingAnchor, constant: 14),
            hStack.trailingAnchor.constraint(equalTo: tipContainer.trailingAnchor, constant: -14),
            hStack.bottomAnchor.constraint(equalTo: tipContainer.bottomAnchor, constant: -14),
            
            tipContainer.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            tipContainer.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            tipContainer.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -16),
            tipContainer.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor)
        ])
        
        mainStack.addArrangedSubview(wrapperView)
        
        // Add a flexible spacer to prevent wrapperView (and tipContainer) from stretching vertically
        let spacer = UIView()
        spacer.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        spacer.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
        spacer.backgroundColor = .clear
        mainStack.addArrangedSubview(spacer)
    }
    
   // HomePageViewController.swift içinde
   
   
    @IBAction func readStoriesCardTapped(_ sender: Any) {
        tabBarController?.selectedIndex = 1
        
    }
    
    @IBAction func createNewStoryTapped(_ sender: Any) {
        print("Create New Story tapped")
        
//        if Auth.auth().currentUser?.isAnonymous == true {
//            showLoginPrompt(message: "Kendi hikayenizi oluşturmak için giriş yapmalısınız.")
//            return
//        }
        
        let storyboard = UIStoryboard(name: "CreateAIStory", bundle: nil)
        if let createVC = storyboard.instantiateViewController(withIdentifier: "CreateAIStoryVC") as? CreateAIStoryViewController {
            navigationController?.pushViewController(createVC, animated: true)
        }
    }
    
    @IBAction func voiceStoryTapped(_ sender: Any) {
//        if Auth.auth().currentUser?.isAnonymous == true {
//            showLoginPrompt(message: "Kendi sesli masalınızı dinlemek için giriş yapmalısınız.")
//            return
//        }
        let playlistVC = PlaylistViewController()
        playlistVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(playlistVC, animated: true)
    }

    private func showLoginPrompt(message: String) {
        let alert = UIAlertController(title: "Giriş Gerekli", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Giriş Yap", style: .default) { [weak self] _ in
            self?.navigateToLogin()
        })
        present(alert, animated: true)
    }

    private func navigateToLogin() {
        do {
            try Auth.auth().signOut()
            FavoriteManager.shared.clearCache()
            CreatedStoriesManager.shared.clearCache()

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }

            let loginVC = LoginViewController()
            window.rootViewController = loginVC
            UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
        } catch {
            print("Çıkış yaparken hata: \(error.localizedDescription)")
        }
    }
    

}
