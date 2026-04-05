//
//  GridSelectionStepCell.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 6.04.2026.
//

// MARK: - GridSelectionStepCell (Adım 2 & 3: Karakter / Yer - 3x2 Grid)

import UIKit

class GridSelectionStepCell: UICollectionViewCell {
    
    static let identifier = "GridSelectionStepCell"
    
    var onOptionSelected: ((Int) -> Void)?
    private var options: [StepOption] = []
    private var selectedIndex: Int? = nil
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Nunito-Bold", size: 22) ?? .boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont(name: "Nunito-Regular", size: 14) ?? .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var gridCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(GridOptionCell.self, forCellWithReuseIdentifier: GridOptionCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = false
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(gridCollectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            gridCollectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            gridCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            gridCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            gridCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with step: Step) {
        titleLabel.text = step.title
        subtitleLabel.text = step.subtitle
        options = step.options
        selectedIndex = step.options.firstIndex(where: { $0.isSelected })
        gridCollectionView.reloadData()
    }
}

extension GridSelectionStepCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridOptionCell.identifier, for: indexPath) as! GridOptionCell
        let option = options[indexPath.item]
        cell.configure(emoji: option.emoji, title: option.title, isSelected: indexPath.item == selectedIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 12
        let totalWidth = collectionView.bounds.width - (spacing * 2)
        let itemWidth = totalWidth / 3
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        onOptionSelected?(indexPath.item)
        collectionView.reloadData()
    }
}
