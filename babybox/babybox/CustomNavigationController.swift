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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onClickUserBtn(sender: AnyObject?) {
        self.tabBarController!.tabBar.hidden = true
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileController")
        self.navigationController?.pushViewController(vController!, animated: true)
    }
    
    func onClickSellBtn(sender: AnyObject?) {
        print("calling here...onClickSellBtn")
        self.tabBarController!.tabBar.hidden = true
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("sellProductsViewController")
        self.navigationController?.pushViewController(vController!, animated: true)
    }
    
    func onClickChatBtn(sender: AnyObject?) {
        self.tabBarController!.tabBar.hidden = true
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("ConversationsController")
        self.navigationController?.pushViewController(vController!, animated: true)
    }
    
    func onClickBadgebtn(sender: AnyObject?) {
        //let vController = self.storyboard?.instantiateViewControllerWithIdentifier("sellProductsViewController")
        //self.navigationController?.pushViewController(vController!, animated: true)
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
        userThumbnailImg.addTarget(self, action: "onClickUserBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        userThumbnailImg.frame = CGRectMake(0, 0, 35, 35)
        userThumbnailImg.layer.cornerRadius = 18.0
        userThumbnailImg.layer.masksToBounds = true
        let imagePath =  constants.imagesBaseURL + "/image/get-thumbnail-profile-image-by-id/" + String(constants.userInfo.id)
        let imageUrl  = NSURL(string: imagePath);
        let imageData = NSData(contentsOfURL: imageUrl!)
        if (imageData != nil) {
            userThumbnailImg.setImage(UIImage(data: imageData!), forState: UIControlState.Normal)
        }
        
        let userNameImg: UIButton = UIButton()
        userNameImg.setTitle(constants.userInfo.displayName, forState: UIControlState.Normal)
        userNameImg.addTarget(self, action: "onClickUserBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        userNameImg.frame = CGRectMake(0, 0, 60, 35)
        
        let sellBtn: UIButton = UIButton()
        sellBtn.setImage(UIImage(named: "new_post"), forState: UIControlState.Normal)
        sellBtn.addTarget(self, action: "onClickSellBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        sellBtn.frame = CGRectMake(0, 0, 35, 35)
        
        let chatBtn: UIButton = UIButton()
        chatBtn.setImage(UIImage(named: "ic_chat_s"), forState: UIControlState.Normal)
        chatBtn.addTarget(self, action: "onClickChatBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        chatBtn.frame = CGRectMake(0, 0, 35, 35)
        
        let gameBadgeBtn: UIButton = UIButton()
        gameBadgeBtn.setImage(UIImage(named: "game_badge"), forState: UIControlState.Normal)
        gameBadgeBtn.addTarget(self, action: "onClickBadgebtn:", forControlEvents: UIControlEvents.TouchUpInside)
        gameBadgeBtn.frame = CGRectMake(0, 0, 35, 35)
        
        let sellBarBtn = UIBarButtonItem(customView: sellBtn)
        let chatBarBtn = UIBarButtonItem(customView: chatBtn)
        let badgeBarBtn = UIBarButtonItem(customView: gameBadgeBtn)
        
        let userImgBarBtn = UIBarButtonItem(customView: userThumbnailImg)
        let userNameBarBtn = UIBarButtonItem(customView: userNameImg)
        
        //var image = UIImage(named: "game_badge_mascot")
        //image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        self.navigationItem.rightBarButtonItems = [sellBarBtn, chatBarBtn ]
        self.navigationItem.leftItemsSupplementBackButton = true;
        self.navigationItem.leftBarButtonItems = [userImgBarBtn, userNameBarBtn, badgeBarBtn]
        
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
        
    }

}
