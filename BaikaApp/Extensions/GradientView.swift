//
//  GradientView.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 16.03.2026.
//

import UIKit

class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    var colors: [UIColor] = [] {
        didSet {
            gradientLayer.colors = colors.map { $0.cgColor }
        }
    }
    
    var startPoint: CGPoint = CGPoint(x: 0, y: 0) {
        didSet { gradientLayer.startPoint = startPoint }
    }
    
    var endPoint: CGPoint = CGPoint(x: 1, y: 1) {
        didSet { gradientLayer.endPoint = endPoint }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.cornerRadius = layer.cornerRadius
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }
}
