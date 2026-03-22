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
    private var overlayView: UIView?

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

            // Overlay — tüm ekranı kaplar ve dokunmaları engeller
            let overlay = UIView(frame: window.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            overlay.isUserInteractionEnabled = true
            overlay.tag = 99998
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(overlay)

            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .white
            indicator.hidesWhenStopped = true
            indicator.center = overlay.center
            indicator.tag = 99999

            overlay.addSubview(indicator)
            indicator.startAnimating()

            self.overlayView = overlay
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
        self.overlayView?.removeFromSuperview()
        self.overlayView = nil
        self.loadingStartTime = nil
    }
}
