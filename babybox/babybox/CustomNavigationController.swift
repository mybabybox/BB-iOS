//
//  CustomNavigationController.swift
//  babybox
//
//  Created by Mac on 07/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class CustomNavigationController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        /** Creating Custom Navigation Controller Component */
        
        initNavigationComponent()
        //initBottomStatusBarComponent()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func onClickSellBtn(sender: AnyObject?) {
        print("calling here...onClickSellBtn")
        self.storyboard?.instantiateViewControllerWithIdentifier("ViewController1")
    }
    
    public func onClickChatBtn(sender: AnyObject?) {
        print("calling here...onClickChatBtn")
        self.storyboard?.instantiateViewControllerWithIdentifier("ViewController1")
    }
    
    public func onClickBadgebtn(sender: AnyObject?) {
        print("calling here...onClickBadgebtn")
        self.storyboard?.instantiateViewControllerWithIdentifier("ViewController1")
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    /*
    // MARK: - Custom Component Implementation
    //
    */
    func initNavigationComponent() {
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        let userThumbnailImg: UIButton = UIButton()
        userThumbnailImg.setImage(UIImage(named: "game_badge_mascot"), forState: UIControlState.Normal)
        userThumbnailImg.addTarget(self, action: "onClickSellBtn", forControlEvents: UIControlEvents.TouchUpInside)
        userThumbnailImg.frame = CGRectMake(0, 0, 35, 35)
        
        let userNameImg: UIButton = UIButton()
        userNameImg.setTitle("Vinod", forState: UIControlState.Normal)
        //userNameImg.setImage(UIImage(named: "game_badge_mascot"), forState: UIControlState.Normal)
        userNameImg.addTarget(self, action: "onClickSellBtn", forControlEvents: UIControlEvents.TouchUpInside)
        userNameImg.frame = CGRectMake(0, 0, 10, 35)
        
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "game_badge_mascot"), forState: UIControlState.Normal)
        button.addTarget(self, action: "onClickSellBtn", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 35, 35)
        
        let button_1: UIButton = UIButton()
        button_1.setImage(UIImage(named: "game_badge_mascot"), forState: UIControlState.Normal)
        button_1.addTarget(self, action: "onClickChatBtn", forControlEvents: UIControlEvents.TouchUpInside)
        button_1.frame = CGRectMake(0, 0, 35, 35)
        
        let button_2: UIButton = UIButton()
        button_2.setImage(UIImage(named: "game_badge_mascot"), forState: UIControlState.Normal)
        button_2.addTarget(self, action: "onClickBadgebtn", forControlEvents: UIControlEvents.TouchUpInside)
        button_2.frame = CGRectMake(0, 0, 35, 35)
        
        let sellBarBtn = UIBarButtonItem(customView: button)
        let chatBarBtn = UIBarButtonItem(customView: button_1)
        let badgeBarBtn = UIBarButtonItem(customView: button_2)
        
        let userImgBarBtn = UIBarButtonItem(customView: userThumbnailImg)
        let userNameBarBtn : UIBarButtonItem = UIBarButtonItem(title: "Vinod", style: UIBarButtonItemStyle.Plain, target: self, action: "onClickSellBtn")
        
        //var image = UIImage(named: "game_badge_mascot")
        //image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        self.navigationItem.rightBarButtonItems = [badgeBarBtn, chatBarBtn, sellBarBtn]
        self.navigationItem.leftItemsSupplementBackButton = true;
        self.navigationItem.leftBarButtonItems = [userImgBarBtn, userNameBarBtn]
        
        let backbtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        backbtn.setBackgroundImage(UIImage(named: "game_badge_mascot"), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        self.navigationItem.backBarButtonItem = backbtn
    }
    
    func initBottomStatusBarComponent() {
        let tabBarController = UITabBarController()
        
        let destination1 = UIViewController()
        let destination2 = UIViewController()
        destination1.title = "view1"
        destination2.title = "view2"
        tabBarController.viewControllers = [destination1, destination2]
        self.hidesBottomBarWhenPushed = true
        //self.showViewController(tabBarController, sender: self)
    }

}
