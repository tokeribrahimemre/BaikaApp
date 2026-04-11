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
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var emojiImageView: UIImageView!
    @IBOutlet weak var themeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.selectionStyle = .none
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        storyImageView.image = nil
        emojiImageView.image = nil
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
        storyImageView.loadImage(from: story.imageURL)
        titleLabel.text = story.title
        ageLabel.text = story.ageCategory
        timeLabel.text = story.time
        emojiImageView.setThemeEmoji(story.themeCategory, size: CGSize(width: 12, height: 12))
        themeLabel.text = story.themeCategory
    }
}
