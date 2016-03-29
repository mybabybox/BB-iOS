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
        case HOME = 0
        case SELLER
        case ACTIVITY
        case PROFILE
        
        init() {
            self = .HOME
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
            let firstViewController = navController.viewControllers[0]
            return firstViewController
        }
        return nil
    }
    
    static func selectHomeTab() -> HomeFeedViewController? {
        return selectTab(TabItem.HOME) as? HomeFeedViewController
    }

    static func selectSellerTab() -> SellerViewController? {
        return selectTab(TabItem.SELLER) as? SellerViewController
    }

    static func selectActivityTab() -> UserActivityViewController? {
        return selectTab(TabItem.ACTIVITY) as? UserActivityViewController
    }

    static func selectProfileTab() -> MyProfileFeedViewController? {
        return selectTab(TabItem.PROFILE) as? MyProfileFeedViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleFont : UIFont = UIFont.systemFontOfSize(12.0)
        
        self.tabBar.layer.backgroundColor = Color.MENU_BAR_BG.CGColor
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Color.BLACK, NSFontAttributeName: titleFont], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Color.PINK, NSFontAttributeName: titleFont], forState:.Selected)
        
        let image = UIImage(named: "mn_home")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selImage = UIImage(named: "mn_home_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![TabItem.HOME.rawValue].image = image
        self.tabBar.items![TabItem.HOME.rawValue].selectedImage = selImage
        
        let sellerImg = UIImage(named: "mn_seller")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selSellerImg = UIImage(named: "mn_seller_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![TabItem.SELLER.rawValue].image = sellerImg
        self.tabBar.items![TabItem.SELLER.rawValue].selectedImage = selSellerImg

        let activityImg = UIImage(named: "mn_notif")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selActivityImg = UIImage(named: "mn_notif_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![TabItem.ACTIVITY.rawValue].image = activityImg
        self.tabBar.items![TabItem.ACTIVITY.rawValue].selectedImage = selActivityImg
        
        let profileImg = UIImage(named: "mn_profile")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selProfileImg = UIImage(named: "mn_profile_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![TabItem.PROFILE.rawValue].image = profileImg
        self.tabBar.items![TabItem.PROFILE.rawValue].selectedImage = selProfileImg
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
