//
//  colorExtensions.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 16.03.2026.
//

import UIKit

import UIKit

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

struct AppColors {
    static let background = UIColor(hex: "0f0e2a")
    static let softBlue = UIColor(hex: "a8d8ea")
    static let softPurple = UIColor(hex: "aa96da")
    static let mintGreen = UIColor(hex: "b2e5cf")
    static let warmYellow = UIColor(hex: "ffeaa7")
}
