//
//  SceneDelegate.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 14.03.2026.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // Firebase Auth durumuna göre başlangıç ekranını belirle
        if Auth.auth().currentUser != nil {
            // Kullanıcı zaten giriş yapmış → Ana uygulamayı göster
            window.rootViewController = DashboardTabBar()
        } else {
            // Kullanıcı giriş yapmamış → Login ekranını göster
            let loginVC = LoginViewController()
            window.rootViewController = loginVC
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
    
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        FavoriteManager.shared.flushIfNeeded()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        FavoriteManager.shared.fetchFavoritesIfNeeded()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    


}

