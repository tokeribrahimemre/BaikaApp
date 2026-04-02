//
//  UILabelExtensions.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 3.04.2026.
//
import UIKit
// MARK: - Kelime Koordinatı Bulucu Eklentisi
extension UILabel {
    // Verilen karakter aralığının (kelimenin) Label içindeki fiziksel çerçevesini (CGRect) hesaplar
    func boundingRect(forCharacterRange range: NSRange) -> CGRect? {
        guard let attributedText = attributedText else { return nil }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        var glyphRange = NSRange()
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    }
}
