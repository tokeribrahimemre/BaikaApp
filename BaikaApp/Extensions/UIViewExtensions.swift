//
//  UIViewExtensions.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 22.03.2026.
//
import UIKit

class BaikaUIView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                layer.masksToBounds = true
            }
        }
}
