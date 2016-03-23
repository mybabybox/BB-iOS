//
//  CustomTabViewController.swift
//  babybox
//
//  Created by Mac on 22/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class CustomTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleFont : UIFont = UIFont.systemFontOfSize(12.0)
        
        self.tabBar.layer.backgroundColor = Color.MENU_BAR_BG.CGColor
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Color.BLACK, NSFontAttributeName: titleFont], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Color.PINK, NSFontAttributeName: titleFont], forState:.Selected)
        
        let image = UIImage(named: "mn_home")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selImage = UIImage(named: "mn_home_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![0].image = image
        self.tabBar.items![0].selectedImage = selImage
        
        let activityImg = UIImage(named: "mn_notif")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selActivityImg = UIImage(named: "mn_notif_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![2].image = activityImg
        self.tabBar.items![2].selectedImage = selActivityImg
        
        let profileImg = UIImage(named: "mn_profile")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selProfileImg = UIImage(named: "mn_profile_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![3].image = profileImg
        self.tabBar.items![3].selectedImage = selProfileImg
        
        let sellerImg = UIImage(named: "mn_seller")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selSellerImg = UIImage(named: "mn_seller_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![1].image = sellerImg
        self.tabBar.items![1].selectedImage = selSellerImg
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
