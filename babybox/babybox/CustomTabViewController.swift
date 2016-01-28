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
        
        self.tabBar.layer.backgroundColor = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFCFAF8).CGColor
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: titleFont], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF76A4), NSFontAttributeName: titleFont], forState:.Selected)
        
        let image = UIImage(named: "mn_home")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selImage = UIImage(named: "mn_home_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![0].image = image
        self.tabBar.items![0].selectedImage = selImage
        
        let activityImg = UIImage(named: "mn_notif")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selActivityImg = UIImage(named: "mn_notif_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![1].image = activityImg
        self.tabBar.items![1].selectedImage = selActivityImg
        
        let profileImg = UIImage(named: "mn_profile")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selProfileImg = UIImage(named: "mn_profile_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![2].image = profileImg
        self.tabBar.items![2].selectedImage = selProfileImg
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
