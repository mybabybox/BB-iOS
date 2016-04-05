//
//  CustomTabBarController.swift
//  babybox
//
//  Created by Mac on 22/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    enum TabItem: Int {
        case Home = 0
        case Seller
        case Activity
        case Profile
        
        init() {
            self = .Home
        }
    }
    
    static func getCustomTabBarController() -> CustomTabBarController? {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let navController = app.window?.rootViewController as! UINavigationController
        var controllers = navController.viewControllers
        
        for i in 0...controllers.count-1 {
            if controllers[i].isKindOfClass(CustomTabBarController) {
                let tabBarController = controllers[i] as! CustomTabBarController
                return tabBarController
            }
        }
        return nil
    }
    
    static func selectTab(tabItem: TabItem) -> UIViewController? {
        if let tabBarController = getCustomTabBarController() {
            tabBarController.selectedIndex = tabItem.rawValue
            
            let navController = tabBarController.viewControllers![tabItem.rawValue] as! UINavigationController
            return navController.viewControllers[0]
        }
        return nil
    }
    
    static func getTab(tabItem: TabItem) -> UIViewController? {
        if let tabBarController = getCustomTabBarController() {
            let navController = tabBarController.viewControllers![tabItem.rawValue] as! UINavigationController
            return navController.viewControllers[0]
        }
        return nil
    }
    
    static func selectHomeTab() -> HomeFeedViewController? {
        return selectTab(TabItem.Home) as? HomeFeedViewController
    }

    static func selectSellerTab() -> SellerViewController? {
        return selectTab(TabItem.Seller) as? SellerViewController
    }

    static func selectActivityTab() -> UserActivityViewController? {
        return selectTab(TabItem.Activity) as? UserActivityViewController
    }

    static func selectProfileTab() -> MyProfileFeedViewController? {
        return selectTab(TabItem.Profile) as? MyProfileFeedViewController
    }

    static func getProfileTab() -> MyProfileFeedViewController? {
        return getTab(TabItem.Profile) as? MyProfileFeedViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.layer.backgroundColor = Color.MENU_BAR_BG.CGColor
        
        let image = UIImage(named: "mn_home")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selImage = UIImage(named: "mn_home_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![TabItem.Home.rawValue].image = image
        self.tabBar.items![TabItem.Home.rawValue].selectedImage = selImage
        
        let sellerImg = UIImage(named: "mn_seller")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selSellerImg = UIImage(named: "mn_seller_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![TabItem.Seller.rawValue].image = sellerImg
        self.tabBar.items![TabItem.Seller.rawValue].selectedImage = selSellerImg

        let activityImg = UIImage(named: "mn_notif")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selActivityImg = UIImage(named: "mn_notif_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![TabItem.Activity.rawValue].image = activityImg
        self.tabBar.items![TabItem.Activity.rawValue].selectedImage = selActivityImg
        
        let profileImg = UIImage(named: "mn_profile")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selProfileImg = UIImage(named: "mn_profile_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![TabItem.Profile.rawValue].image = profileImg
        self.tabBar.items![TabItem.Profile.rawValue].selectedImage = selProfileImg
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
