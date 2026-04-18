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

    /// Ebeveyn Kapısı (Parental Gate) - Dış bağlantılar veya yetişkin eylemleri öncesi matematik sorusu sorar.
    func showParentalGate(completion: @escaping () -> Void) {
        let num1 = Int.random(in: 3...9)
        let num2 = Int.random(in: 3...9)
        let answer = num1 * num2
        
        let alert = UIAlertController(
            title: "Ebeveyn Kapısı",
            message: "Devam etmek için lütfen aşağıdaki işlemi çözün:\n\n\(num1) x \(num2) = ?",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "Cevap"
            textField.textAlignment = .center
        }
        
        let confirmAction = UIAlertAction(title: "Doğrula", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text, let userAns = Int(text), userAns == answer else {
                let errorAlert = UIAlertController(title: "Hata", message: "Yanlış cevap verdiniz.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Tamam", style: .default))
                self?.present(errorAlert, animated: true)
                return
            }
            completion()
        }
        
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel)
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true)
    }
}
