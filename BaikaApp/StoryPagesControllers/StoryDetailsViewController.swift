//
//  StoryDetailsViewController.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 21.03.2026.
//

import UIKit
import AVFoundation

class StoryDetailsViewController: UIViewController{
    
    private let story: Story
    
    
    let speechSynthesizer = AVSpeechSynthesizer()
    var fullStoryText: String = ""
    
    
//    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ageView: UIView!
    
    
    @IBOutlet weak var playStackView: UIStackView!
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var playLabel: UILabel!
    
    @IBOutlet weak var favoriteStackView: UIStackView!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var heartLabel: UILabel!
    
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var themImageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    
    // 2. Storyboard'dan çağrılırken çalışacak olan Profesyonel Başlatıcı (Init)
    init?(coder: NSCoder, story: Story) {
        self.story = story
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("HATA: StoryDetailViewController bir hikaye modeli olmadan başlatılamaz!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Açılan Hikaye: \(story.title)")
        
        speechSynthesizer.delegate = self
        
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if speechSynthesizer.isSpeaking || speechSynthesizer.isPaused {
              speechSynthesizer.stopSpeaking(at: .immediate)
              descriptionLabel.text = fullStoryText
              playImage.image = UIImage(systemName: "play.fill")
              playLabel.text = "Dinle"
          }
          
          // Audio session'ı serbest bırak
          try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ageView.layer.cornerRadius = ageView.bounds.height / 2
        ageView.clipsToBounds = true
    }
    
    
    private func setupUI() {
        
        storyImage.loadImage(from: story.imageURL)
        storyTitleLabel.text = story.title
        ageLabel.text = story.ageCategory
        timeLabel.text = story.time
        themImageView.setThemeEmoji(story.themeCategory)
        themeLabel.text = story.themeCategory
        ageLabel.text = story.ageCategory
        descriptionLabel.text = story.description
        
        fullStoryText = story.description
        descriptionLabel.text = fullStoryText
        
        playStackView.isUserInteractionEnabled = true
        favoriteStackView.isUserInteractionEnabled = true
        
        let playGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(listenButtonTapped))
        playStackView.addGestureRecognizer(playGestureRecognizer)
        
        
    }
    
    
    @objc func listenButtonTapped(_ sender: UIButton) {
        if speechSynthesizer.isSpeaking {
            // Eğer şu an konuşuyorsa...
            if speechSynthesizer.isPaused {
                // Duraklatılmışsa devam et
                speechSynthesizer.continueSpeaking()
                
                playImage.image = UIImage(systemName: "pause.fill")
                playLabel.text = "Durdur"
                
            } else {
                // Konuşuyorsa duraklat (kelime bitiminde durur)
                speechSynthesizer.pauseSpeaking(at: .word)
                
                playImage.image = UIImage(systemName: "play.fill")
                playLabel.text = "Dinle"
               
            }
        } else {
            // Hiç başlamadıysa baştan başlat
            startSpeaking()
            playImage.image = UIImage(systemName: "pause.fill")
            playLabel.text = "Durdur"
            
        }
    }
    
    
    @objc func favoriteButtonTapped(_ sender: Any) {
        
    }
    
    private func startSpeaking() {
        // Ses çıkışını aktif et
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession hatası: \(error.localizedDescription)")
        }
        IndicatorView.shared.showIndicator()
        let utterance = AVSpeechUtterance(string: fullStoryText)
        utterance.voice = getBestTurkishVoice()
        utterance.rate = 0.50 // Okuma hızı (0.5 normaldir, masal için 0.45 iyi olabilir)
        utterance.pitchMultiplier = 1// Sesin inceliği (Çocuk masalı için biraz ince)
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.0
        utterance.postUtteranceDelay = 0.0
        
        speechSynthesizer.speak(utterance)
    }
    
    private func getBestTurkishVoice() -> AVSpeechSynthesisVoice? {
        // Cihazdaki (veya indirilebilir) tüm sesleri al
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // Sadece Türkçe olanları filtrele
        let turkishVoices = allVoices.filter { $0.language == "tr-TR" }
        
        // 1. Şans: En yüksek kaliteyi (Premium) ara
        if let premiumVoice = turkishVoices.first(where: { $0.quality == .premium }) {
            print("Harika! Premium ses bulundu: \(premiumVoice.name)")
            return premiumVoice
        }
        
        // 2. Şans: Gelişmiş kaliteyi (Enhanced) ara
        if let enhancedVoice = turkishVoices.first(where: { $0.quality == .enhanced }) {
            print("Gelişmiş ses bulundu: \(enhancedVoice.name)")
            return enhancedVoice
        }
        
        // 3. Şans: Hiçbiri yoksa varsayılan standart Türkçe sesi ver
        print("Standart Türkçe ses kullanılıyor.")
        return AVSpeechSynthesisVoice(language: "tr-TR")
    }
    
}

extension StoryDetailsViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        IndicatorView.shared.removeIndicator()
    }
    // Motor her kelime değiştirdiğinde bu fonksiyon tetiklenir
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        
        // 1. Fontun ve normal rengin bozulmaması için temel ayarlar
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: descriptionLabel.font ?? UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        
        // 2. Metnimizi bu temel ayarlarla oluşturuyoruz
        let attributedString = NSMutableAttributedString(string: fullStoryText, attributes: defaultAttributes)
        
        // 3. Mevcut kelimenin hangi cümleye ait olduğunu bul (nokta/soru/ünlem bazında)
        let nsText = fullStoryText as NSString
        
        // 4. characterRange'in konumundan geriye ve ileriye doğru cümle sınırlarını ara
        let text = fullStoryText
        let startIndex = text.index(text.startIndex, offsetBy: characterRange.location)
        
        // Cümle başını bul (geriye doğru . ? ! ara)
        var sentenceStart = text.startIndex
        if startIndex > text.startIndex {
            var idx = text.index(before: startIndex)
            while idx > text.startIndex {
                let c = text[idx]
                if c == "." || c == "?" || c == "!" {
                    sentenceStart = text.index(after: idx)
                    // Boşlukları atla
                    while sentenceStart < startIndex && text[sentenceStart] == " " {
                        sentenceStart = text.index(after: sentenceStart)
                    }
                    break
                }
                idx = text.index(before: idx)
            }
        }
        
        // Cümle sonunu bul (ileriye doğru . ? ! ara)
        var sentenceEnd = text.endIndex
        var idx = startIndex
        while idx < text.endIndex {
            let c = text[idx]
            if c == "." || c == "?" || c == "!" {
                sentenceEnd = text.index(after: idx)
                break
            }
            idx = text.index(after: idx)
        }
        
        let finalStart = text.distance(from: text.startIndex, to: sentenceStart)
        let finalLength = text.distance(from: sentenceStart, to: sentenceEnd)
        let finalRange = NSRange(location: finalStart, length: min(finalLength, nsText.length - finalStart))
        
        // 5. Bulunan cümlenin tamamını SARI yapıyoruz
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "warmYellow") ?? UIColor.systemYellow, range: finalRange)
        
        // 6. Ekrana basıyoruz
        descriptionLabel.attributedText = attributedString
        
        if let wordRectInLabel = descriptionLabel.boundingRect(forCharacterRange: characterRange) {
                    
                    // B. Bu koordinatları ScrollView'un koordinatlarına çeviriyoruz
                    // (Çünkü Label'ın içi ayrı, ekranın geneli ayrı bir dünyadır)
                    let wordRectInScrollView = scrollView.convert(wordRectInLabel, from: descriptionLabel)
                    
                    // C. Kullanıcının göz hizasını ayarlıyoruz
                    // Kelime tam ekranın en altına yapışmasın, rahat okunsun diye üstten ve alttan hayali bir pay (padding) bırakıyoruz.
                    let visibleRect = CGRect(x: wordRectInScrollView.origin.x,
                                             y: wordRectInScrollView.origin.y - 100, // Üstten 100 piksel rahatlama payı
                                             width: wordRectInScrollView.width,
                                             height: wordRectInScrollView.height + 200) // Alttan rahatlama payı
                    
                    // D. ScrollView'a "Bu hesapladığımız alanı ekranda görünecek şekilde kaydır" diyoruz
                    scrollView.scrollRectToVisible(visibleRect, animated: true)
                }
    }
    
    // Hikaye tamamen bittiğinde çalışır
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        // Metni tamamen eski haline (beyaza) çevir
        descriptionLabel.text = fullStoryText
        
        playImage.image = UIImage(systemName: "play.fill")
        playLabel.text = "Dinle"
    }
}
