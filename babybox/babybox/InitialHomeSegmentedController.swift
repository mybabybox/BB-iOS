//
//  InitialHomeSegmentedControllerViewController.swift
//  babybox
//
//  Created by Mac on 12/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import FBSDKLoginKit

class InitialHomeSegmentedController: CustomNavigationController {

    @IBOutlet weak var containerView: UIView!
    static var instance: InitialHomeSegmentedController? = nil
    var bottomLayer: CALayer? = nil
    var exploreController : UIViewController? = nil
    var followingController : UIViewController? = nil
    var activeSegment: Int = 0
    var shapeLayer = CAShapeLayer()
    var notificationCounterVM: NotificationCounterVM? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitialHomeSegmentedController.instance = self
        SwiftEventBus.onMainThread(self, name: "loadNotificationSuccess") { result in
            self.notificationCounterVM = result.object as? NotificationCounterVM
            self.refreshNotifications()
        }
        SwiftEventBus.onMainThread(self, name: "loadNotificationFailure") { result in
            NSLog("Error Getting Notification Counter!")
        }
        
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.grayColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(12.0)
        ]
        
        let activeTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(12.0)
        ]
        
        UISegmentedControl.appearance().setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        UISegmentedControl.appearance().setTitleTextAttributes(activeTextAttributes, forState: .Selected)
        
        if self.exploreController == nil {
            self.exploreController = self.storyboard!.instantiateViewControllerWithIdentifier("HomeFeedViewController") as! HomeFeedViewController
        }
        addChildViewController(self.exploreController!)
        self.exploreController!.view.frame = self.containerView.bounds
        self.containerView.addSubview((self.exploreController?.view)!)
        self.exploreController?.didMoveToParentViewController(self)
        
        NotificationCounter.mInstance.refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    func refreshNotifications() {
        let tabBarItem = (self.tabBarController?.tabBar.items![2])! as UITabBarItem
        if (self.notificationCounterVM?.activitiesCount > 0) {
            let aCount = (self.notificationCounterVM?.activitiesCount)! as Int
            tabBarItem.badgeValue = String(aCount)
        } else {
            tabBarItem.badgeValue = nil
        }
        let chatNavItem = self.navigationItem.rightBarButtonItems?[1] as? ENMBadgedBarButtonItem
        
        if (self.notificationCounterVM?.conversationsCount > 0) {
            let cCount = (self.notificationCounterVM?.conversationsCount)! as Int
            chatNavItem?.badgeValue = String(cCount)
        } else {
            chatNavItem?.badgeValue = ""
        }
    }
    
    /**this method should have been in NotificationCounter class but since this didnt worked as NSTimer selector was not getting resolved within NotificationCounter class so specified the method here.*/
    func refresh() {
        NotificationCounter.mInstance.refresh()
    }

    
}
