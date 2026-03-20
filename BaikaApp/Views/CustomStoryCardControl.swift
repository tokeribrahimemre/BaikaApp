//
//  CustomStoryCardControl.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 15.03.2026.
//

import UIKit
enum StoryCardType {
    case readStories
    case createStory
    case audioStory
}

class CustomStoryCardControl: UIControl {
    
    
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var decorationView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    private let gradientLayer = CAGradientLayer()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            Bundle.main.loadNibNamed("CustomStoryCardControl", owner: self, options: nil)
            
            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.clipsToBounds = true
            self.layer.cornerRadius = 24
            self.backgroundColor = UIColor(hex: "0F0E2A")
            
            // Gradient layer'ı en alta ekle
            gradientLayer.cornerRadius = 24
            self.layer.insertSublayer(gradientLayer, at: 0)
            
            iconContainerView.layer.cornerRadius = 16
            contentView.isUserInteractionEnabled = false
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            gradientLayer.frame = self.bounds
            decorationView.layer.cornerRadius = decorationView.bounds.height / 2
        }
        
        func configure(type: StoryCardType) {
            contentView.backgroundColor = .clear
            
            let title: String
            let subTitle: String
            let icon: UIImage?
            let gradientColors: [CGColor]
            let iconBgColor: UIColor
            let iconTintColor: UIColor
            let decorationColor: UIColor
            
            switch type {
            case .readStories:
                title = "Hikayeleri Oku"
                subTitle = "Hazır masalları keşfet"
                icon = UIImage(systemName: "book.fill")
                gradientColors = [
                    UIColor(hex: "1a3a5c").cgColor,
                    UIColor(hex: "1e2d50").cgColor
                ]
                iconBgColor = UIColor(hex: "a8d8ea").withAlphaComponent(0.2)
                iconTintColor = UIColor(hex: "a8d8ea")
                decorationColor = UIColor(hex: "a8d8ea").withAlphaComponent(0.1)
                
            case .createStory:
                title = "Yeni Hikaye Oluştur"
                subTitle = "Yapay zeka ile masal yarat"
                icon = UIImage(systemName: "sparkles")
                gradientColors = [
                    UIColor(hex: "2d1b4e").cgColor,
                    UIColor(hex: "3a2066").cgColor
                ]
                iconBgColor = UIColor(hex: "aa96da").withAlphaComponent(0.2)
                iconTintColor = UIColor(hex: "aa96da")
                decorationColor = UIColor(hex: "aa96da").withAlphaComponent(0.1)
                
            case .audioStory:
                title = "Sesli Masal"
                subTitle = "Dinleyerek uyuyun"
                icon = UIImage(systemName: "headphones")
                gradientColors = [
                    UIColor(hex: "1a3a2e").cgColor,
                    UIColor(hex: "1e4a3a").cgColor
                ]
                iconBgColor = UIColor(hex: "b2e5cf").withAlphaComponent(0.2)
                iconTintColor = UIColor(hex: "b2e5cf")
                decorationColor = UIColor(hex: "b2e5cf").withAlphaComponent(0.1)
            }
            
            // Değerleri uygula
            titleLabel.text = title
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "Nunito-Bold", size: 18)
            
            subTitleLabel.text = subTitle
            subTitleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
            subTitleLabel.font = UIFont(name: "Nunito-Regular", size: 13)
            
            iconImageView.image = icon
            iconImageView.tintColor = iconTintColor
            
            iconContainerView.backgroundColor = iconBgColor
            decorationView.backgroundColor = decorationColor
            
            // Gradient ayarla
            gradientLayer.colors = gradientColors
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        }
  
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
