//
//  IndicatorView.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 21.03.2026.
//

import Foundation
import UIKit

public final class IndicatorView {

    static let shared = IndicatorView()

    private var loadingIndicator: UIActivityIndicatorView?
    private var loadingStartTime: Date?

    private init() { }

    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        }
    }

    public func showIndicator() {
        DispatchQueue.main.async {
            if let indicator = self.loadingIndicator, indicator.isAnimating {
                return
            }

            guard let window = self.getKeyWindow() else {
                print("⚠️ IndicatorView: keyWindow bulunamadı")
                return
            }

            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .white
            indicator.hidesWhenStopped = true
            indicator.center = window.center
            indicator.tag = 99999

            window.addSubview(indicator)
            window.bringSubviewToFront(indicator)
            indicator.startAnimating()

            self.loadingIndicator = indicator
            self.loadingStartTime = Date()

            print("✅ IndicatorView gösterildi")
        }
    }

    public func removeIndicator() {
        DispatchQueue.main.async {
            guard let startTime = self.loadingStartTime else {
                self.removeLoadingIndicator()
                return
            }
            let elapsedTime = Date().timeIntervalSince(startTime)
            let minDuration: TimeInterval = 0.5

            if elapsedTime >= minDuration {
                self.removeLoadingIndicator()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + (minDuration - elapsedTime)) {
                    self.removeLoadingIndicator()
                }
            }
        }
    }

    private func removeLoadingIndicator() {
        self.loadingIndicator?.stopAnimating()
        self.loadingIndicator?.removeFromSuperview()
        self.loadingIndicator = nil
        self.loadingStartTime = nil
    }
}
