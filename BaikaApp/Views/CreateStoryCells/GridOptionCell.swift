//
//  GridOptionCell.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 6.04.2026.
//

// MARK: - GridOptionCell (Tek bir grid seçenek hücresi)
import UIKit

class GridOptionCell: UICollectionViewCell {
    
    static let identifier = "GridOptionCell"
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Nunito-SemiBold", size: 13) ?? .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activeColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Cell kendisi şeffaf olmalı, köşe renk uyumsuzluğunu önler
        backgroundColor = .clear
        
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.clipsToBounds = true
        
        contentView.addSubview(emojiLabel)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func configure(emoji: String, title: String, isSelected: Bool) {
        emojiLabel.text = emoji
        titleLabel.text = title
        
        if isSelected {
            contentView.layer.borderColor = activeColor.cgColor
            contentView.backgroundColor = activeColor.withAlphaComponent(0.15)
        } else {
            contentView.layer.borderColor = UIColor.clear.cgColor
            contentView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        }
    }
}
