//
//  StoryDetailsViewController.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 21.03.2026.
//

import UIKit

class StoryDetailsViewController: UIViewController {

    private let story: Story
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ageView: UIView!
    
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
        setupUI()
        // Do any additional setup after loading the view.
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
        
    }
    
    
    @IBAction func listenButtonTapped(_ sender: Any) {
        
    }
    
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        
    }
    
    
    
}
