//
//  ViewControllerExtensions.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 21.03.2026.
//

import UIKit

extension UIViewController {
    func showCustomAlert(message: String, completion: (() -> Void)? = nil) {
        guard let window = view.window
                ?? UIApplication.shared.connectedScenes
                    .compactMap({ ($0 as? UIWindowScene)?.windows.first })
                    .first
        else { return }

        let alertView = CustomAlertView(frame: window.bounds)
        alertView.show(on: window, withMessage: message, completion: completion)
    }
}
