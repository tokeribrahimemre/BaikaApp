//
//  CustomStoryCardControl.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 15.03.2026.
//

import UIKit

class CustomStoryCardControl: UIControl {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var decorationView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
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
        
//        self.layer.cornerRadius = 24
        self.clipsToBounds = true
        
        iconContainerView.layer.cornerRadius = 16
        iconContainerView.backgroundColor = .white.withAlphaComponent(0.15)
        decorationView.backgroundColor = .white.withAlphaComponent(0.05)
        contentView.isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        decorationView.layer.cornerRadius = decorationView.bounds.height / 2
    }
    
    func configure(title: String, subTitle: String, icon: UIImage, backgroundColor: UIColor) {
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.iconImageView.image = icon
        self.backgroundColor = backgroundColor
        
        self.contentView.backgroundColor = .clear
    }
    
  
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
