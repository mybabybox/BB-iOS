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
        
        var imageInsets = UIEdgeInsetsMake(15, -50, 0, 50)
        self.tabBar.layer.backgroundColor = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFCFAF8).CGColor
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF76A4)], forState:.Selected)
        UITabBarItem.appearance().titlePositionAdjustment = UIOffsetMake(50.0, -15.0)
        
        let image = UIImage(named: "mn_home")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selImage = UIImage(named: "mn_home_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![0].image = image
        self.tabBar.items![0].selectedImage = selImage
        //self.tabBar.items![0].titlePositionAdjustment = UIOffsetMake(0.0, -5.0)
        self.tabBar.items![0].imageInsets = imageInsets
        
        let activityImg = UIImage(named: "mn_notif")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selActivityImg = UIImage(named: "mn_notif_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![1].image = activityImg
        self.tabBar.items![1].selectedImage = selActivityImg
        //self.tabBar.items![1].titlePositionAdjustment = UIOffsetMake(0.0, -5.0);
        self.tabBar.items![1].imageInsets = imageInsets
        
        let profileImg = UIImage(named: "mn_profile")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let selProfileImg = UIImage(named: "mn_profile_sel")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![2].image = profileImg
        self.tabBar.items![2].selectedImage = selProfileImg
        self.tabBar.items![2].titlePositionAdjustment = UIOffsetMake(30.0, -15.0);
        self.tabBar.items![2].imageInsets = UIEdgeInsetsMake(15, -40, 0, 40)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
