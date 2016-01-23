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
        
        print("calling htis ")
        print(self.tabBar.items?.count)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], forState:.Normal)
        
        let image = UIImage(named: "mn_home_sel")
        image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![0].selectedImage = image
        self.tabBar.items![0].image = image
        
        
        let activityImg = UIImage(named: "ic_reply")
        activityImg?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![1].image = activityImg
        
        let profileImg = UIImage(named: "login_user")
        profileImg?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBar.items![2].image = profileImg
        
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
