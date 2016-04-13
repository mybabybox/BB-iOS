//
//  SellerViewController.swift
//  babybox
//
//  Created by Mac on 29/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class SellerViewController: CustomNavigationController {
    
    @IBOutlet weak var uiContainerView: UIView!
    @IBOutlet weak var segController: UISegmentedControl!
    
    var bottomLayer: CALayer? = nil
    var sellerRecommendationController : UIViewController? = nil
    var followingController : UIViewController? = nil
    var activeSegment: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        NotificationCounter.refresh(onSuccessRefreshNotifications, failureCallback: onFailureRefreshNotifications)
    }

    override func viewDidAppear(animated: Bool) {
        self.segController.selectedSegmentIndex = 0
        self.segController.selectedSegmentIndex = self.activeSegment
        self.segAction(self.segController)
    }
    
    @IBAction func segAction(sender: AnyObject) {
        if (self.segController.selectedSegmentIndex == 0) {
            if self.sellerRecommendationController == nil {
                self.sellerRecommendationController = self.storyboard!.instantiateViewControllerWithIdentifier("RecommendedSeller") as! RecommendedSellerViewController
            }
            
            self.followingController?.willMoveToParentViewController(nil)
            self.followingController?.view.removeFromSuperview()
            self.followingController?.removeFromParentViewController()
            
            addChildViewController(self.sellerRecommendationController!)
            self.sellerRecommendationController!.view.frame = self.uiContainerView.bounds
            self.uiContainerView.addSubview((self.sellerRecommendationController?.view)!)
            self.sellerRecommendationController?.didMoveToParentViewController(self)
        } else if(self.segController.selectedSegmentIndex == 1) {
            if self.followingController == nil {
                self.followingController = self.storyboard!.instantiateViewControllerWithIdentifier("FollowingFeedViewController") as! FollowingFeedViewController
            }
            
            self.sellerRecommendationController?.willMoveToParentViewController(nil)
            self.sellerRecommendationController?.view.removeFromSuperview()
            self.sellerRecommendationController?.removeFromParentViewController()
            
            addChildViewController(self.followingController!)
            self.followingController!.view.frame = self.uiContainerView.bounds
            self.uiContainerView.addSubview((self.followingController?.view)!)
            self.followingController?.didMoveToParentViewController(self)
        }
        
        ViewUtil.selectSegmentControl(self.segController, view: self.view)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    func onSuccessRefreshNotifications(notifcationCounter: NotificationCounterVM) {
        ViewUtil.refreshNotifications((self.tabBarController?.tabBar)!, navigationItem: self.navigationItem)
    }
    
    func onFailureRefreshNotifications(message: String) {
        NSLog(message)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
