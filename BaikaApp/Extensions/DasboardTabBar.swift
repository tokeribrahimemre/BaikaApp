//
//  DasboardTabBar.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 15.03.2026.
//
import UIKit

class DashboardTabBar: UITabBarController {
    
    var mainNvg: UINavigationController = UINavigationController()
    var storiesNvg: UINavigationController = UINavigationController()
    var favoriteNvg: UINavigationController = UINavigationController()
    var settingsNvg: UINavigationController = UINavigationController()
    
    var refrenceVC: UIViewController?
    
    var mainTab: HomePageViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupViewControllers(){
        let storyBoardBundle = Bundle(for: HomePageViewController.self)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: storyBoardBundle)
        
        mainNvg = storyBoard.instantiateInitialViewController() as! UINavigationController
        mainTab = mainNvg.topViewController as? HomePageViewController
        
        let storyBoardBundle2 = Bundle(for: StoriesViewController.self)
        let storyBoard2: UIStoryboard = UIStoryboard(name: "Stories", bundle: storyBoardBundle2)
        
        storiesNvg = storyBoard2.instantiateInitialViewController() as! UINavigationController
        
        let storyBoardBundle3 = Bundle(for: FavoritesViewController.self)
        let storyBoard3: UIStoryboard = UIStoryboard(name: "Favorites", bundle: storyBoardBundle3)
        
        favoriteNvg = storyBoard3.instantiateInitialViewController() as! UINavigationController
        
        let storyBoardBundle4 = Bundle(for: SettingsViewController.self)
        let storyBoard4: UIStoryboard = UIStoryboard(name: "Settings", bundle: storyBoardBundle4)
        
        settingsNvg = storyBoard4.instantiateInitialViewController() as! UINavigationController
        
        let mainTabBar = UITabBarItem(title: "Ana Sayfa", image: .homePage.withRenderingMode(.alwaysOriginal), selectedImage: .selectedHomePage.withRenderingMode(.alwaysOriginal))
        mainTabBar.tag = 1
        mainNvg.tabBarItem = mainTabBar
        
        let storiesTabBar = UITabBarItem(title: "Hikayeler", image: .storires.withRenderingMode(.alwaysOriginal), selectedImage: .selectedStories.withRenderingMode(.alwaysOriginal))
        storiesTabBar.tag = 2
        storiesNvg.tabBarItem = storiesTabBar
        
        let favoriteTabBar = UITabBarItem(title: "Favoriler", image: .favorites.withRenderingMode(.alwaysOriginal), selectedImage: .selectedFavorites.withRenderingMode(.alwaysOriginal))
        favoriteTabBar.tag = 3
        favoriteNvg.tabBarItem = favoriteTabBar
        
        let settingsTabBar = UITabBarItem(title: "Ayarlar", image: .settings.withRenderingMode(.alwaysOriginal), selectedImage: .selectedSettings.withRenderingMode(.alwaysOriginal))
        settingsTabBar.tag = 4
        settingsNvg.tabBarItem = settingsTabBar
        
        self.viewControllers = [mainNvg, storiesNvg, favoriteNvg, settingsNvg]
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Arka plan rengi (koyu lacivert)
//        appearance.backgroundColor = UIColor(red: 0.09, green: 0.10, blue: 0.15, alpha: 1.0)
        
        // Seçili item rengi (beyaz)
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        // Seçilmemiş item rengi (gri)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 11, weight: .regular)
        ]
        
        // Ayırıcı çizgiyi kaldır
        appearance.shadowColor = .clear
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        // Tab bar yüksekliğini artır (isteğe bağlı)
        // var frame = tabBar.frame
        // frame.size.height = 80
        // tabBar.frame = frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // tabBar(_:didSelect:) metodunu tamamen kaldırın veya
    // sadece root'a dönmek istiyorsanız popToRootViewController kullanın:
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 1:
            mainNvg.popToRootViewController(animated: false)
        case 2:
            storiesNvg.popToRootViewController(animated: false)
        case 3:
            favoriteNvg.popToRootViewController(animated: false)
        case 4:
            settingsNvg.popToRootViewController(animated: false)
        default:
            print("Dont Know The Tab")
        }
    }
}
