//
//  StoriesTableViewCell.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 19.03.2026.
//

import UIKit

class StoriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var innerView: UIView!
    
    
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var ageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.selectionStyle = .none
        
    }
    override func layoutSubviews() {
        ageView.layer.cornerRadius = 16
        ageView.clipsToBounds = true
        innerView.layer.cornerRadius = 24
        innerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(with story: Story) {
        ageLabel.text = story.ageCategory
    }
}
