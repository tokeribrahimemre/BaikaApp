//
//  AppChechProvider.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 18.04.2026.
//

import FirebaseCore
import FirebaseAppCheck

class BaikaAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        // Sadece gerçek cihaz kullanıldığı için doğrudan App Attest dönüyoruz
        if #available(iOS 14.0, *) {
            return AppAttestProvider(app: app)
        } else {
            return DeviceCheckProvider(app: app) // iOS 14 altı için yedek güvenlik
        }
    }
}
