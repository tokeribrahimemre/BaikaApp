//
//  StoriesTableViewCell.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 19.03.2026.
//

import UIKit

class StoriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var innerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        innerView.layer.cornerRadius = 24  // 50 çok büyük olabilir, hücre yüksekliğine göre ayarlayın
            innerView.clipsToBounds = true
            
            self.backgroundColor = .clear
            contentView.backgroundColor = .clear
            self.selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
