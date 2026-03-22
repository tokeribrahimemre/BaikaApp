//
//  BackButton.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 22.03.2026.
//

//
//  BackButton.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 22.03.2026.
//

import UIKit

@IBDesignable
class BackButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    private func setupButton() {
        setTitle(nil, for: .normal)
        setImage(.backButton, for: .normal)
        layer.masksToBounds = true
        
        // iOS 15+ button configuration varsa title'ı temizle
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = .backButton
            config.title = nil
            self.configuration = config
        }
        
        isUserInteractionEnabled = true
        addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    @objc private func backButtonTapped() {
        print("backbuttontapped")
        findNavigationController()?.popViewController(animated: true)
    }

    private func findNavigationController() -> UINavigationController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let navController = nextResponder as? UINavigationController {
                return navController
            }
            if let viewController = nextResponder as? UIViewController {
                return viewController.navigationController
            }
            responder = nextResponder
        }
        return nil
    }
}
