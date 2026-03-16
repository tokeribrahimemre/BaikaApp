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
        // Do any additional setup after loading the view.
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
        
        
        //        let adviceVC = adviceNvg.topViewController as! AdviceViewController
        
        
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
        
        
        self.viewControllers = [mainNvg,storiesNvg,favoriteNvg,settingsNvg]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("tab bar viewDidAppear#####3")
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 1:
            mainNvg.popViewController(animated: false)
            if let tabBar = self.tabBarController {
                tabBar.selectedIndex = 0
            }
        case 2:
            storiesNvg.popViewController(animated: false)
        case 3:
            favoriteNvg.popViewController(animated: false)
        case 4:
            settingsNvg.popViewController(animated: false)
            default :
            print("Dont Know The Tab")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
