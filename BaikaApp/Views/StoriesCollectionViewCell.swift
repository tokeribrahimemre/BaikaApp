//
//  StoriesCollectionViewCell.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 18.03.2026.
//

import UIKit

class StoriesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emojiImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 16
        
    }
    
    func configureCell(with ageCategory: String) {
        titleLabel.text = ageCategory
        emojiImageView.setThemeEmoji(ageCategory)
    }
}
