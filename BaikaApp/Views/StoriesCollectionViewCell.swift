//
//  StoriesCollectionViewCell.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 18.03.2026.
//

import UIKit

class StoriesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 16
        
    }

    
    
}
