//
//  CustomNavigationController.swift
//  babybox
//
//  Created by Mac on 07/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import AMScrollingNavbar

class CustomNavigationController: ScrollingNavigationViewController, ScrollingNavigationControllerDelegate {
    
    var isProfileView = false
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Creating Custom Navigation Controller Component */
        initNavigationComponent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onClickSellBtn(sender: AnyObject?) {
        //self.tabBarController!.tabBar.hidden = true
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("NewProductViewController")
        vController?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vController!, animated: true)
    }
    
    func onClickChatBtn(sender: AnyObject?) {
        //self.tabBarController!.tabBar.hidden = true
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("ConversationsController")
        vController?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vController!, animated: true)
    }
    
    func onClickBadgebtn(sender: AnyObject?) {
        //let vController = self.storyboard?.instantiateViewControllerWithIdentifier("NewProductViewController")
        //self.navigationController?.pushViewController(vController!, animated: true)
    }
    
    func scrollingNavigationController(controller: ScrollingNavigationController, didChangeState state: NavigationBarState) {
        switch state {
        case .Collapsed:
            print("navbar collapsed")
        case .Expanded:
            print("navbar expanded")
        case .Scrolling:
            print("navbar is moving")
        }
    }
    
    /*
    // MARK: - Custom Component Implementation
    //
    */
    func initNavigationComponent() {
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        let sellBtn: UIButton = UIButton()
        sellBtn.setImage(UIImage(named: "btn_sell"), forState: UIControlState.Normal)
        sellBtn.addTarget(self, action: "onClickSellBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        sellBtn.frame = CGRectMake(0, 0, 35, 35)
        
        let chatBtn: UIButton = UIButton()
        chatBtn.setImage(UIImage(named: "ic_chat"), forState: UIControlState.Normal)
        chatBtn.addTarget(self, action: "onClickChatBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        chatBtn.frame = CGRectMake(0, 0, 35, 35)
        
        let gameBadgeBtn: UIButton = UIButton()
        gameBadgeBtn.setImage(UIImage(named: "game_badge"), forState: UIControlState.Normal)
        gameBadgeBtn.addTarget(self, action: "onClickBadgebtn:", forControlEvents: UIControlEvents.TouchUpInside)
        gameBadgeBtn.frame = CGRectMake(0, 0, 35, 35)
        
        let sellBarBtn = UIBarButtonItem(customView: sellBtn)
        let chatBarBtn = ENMBadgedBarButtonItem(customView: chatBtn, value: "")
        let badgeBarBtn = UIBarButtonItem(customView: gameBadgeBtn)
        
        self.navigationItem.rightBarButtonItems = [sellBarBtn, chatBarBtn ]
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItems = [badgeBarBtn]
        
        let backbtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        backbtn.setBackgroundImage(UIImage(named: "game_badge_mascot"), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        self.navigationItem.backBarButtonItem = backbtn
    }
}
