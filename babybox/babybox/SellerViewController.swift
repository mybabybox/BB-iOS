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
    var shapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // select home segment
        self.segController.selectedSegmentIndex = 0
        self.segController.selectedSegmentIndex = self.activeSegment
        self.segAction(self.segController)
    }
    
    override func viewWillAppear(animated: Bool) {
        NotificationCounter.refresh(onSuccessRefreshNotifications, failureCallback: onFailureRefreshNotifications)
    }

    override func viewDidAppear(animated: Bool) {
        let y = CGFloat(self.segController.frame.height)
        let start: CGPoint = CGPoint(x: 0, y: y)
        let end: CGPoint = CGPoint(x: self.segController.frame.size.width / 2, y: y)
        if self.segController.selectedSegmentIndex == 0 {
            self.drawLineFromPoint(start, toPoint: end, ofColor: Color.PINK, inView: self.segController)
        }
    }
    
    @IBAction func segAction(sender: AnyObject) {
        if (self.segController.selectedSegmentIndex == 0) {
            // init HomeFeedViewController
            if self.sellerRecommendationController == nil {
                self.sellerRecommendationController = self.storyboard!.instantiateViewControllerWithIdentifier("RecommendedSeller") as! RecommendedSellerViewController
            }
            
            let y = CGFloat(self.segController.frame.size.height)
            let start: CGPoint = CGPoint(x: 0, y: y)
            let end: CGPoint = CGPoint(x: self.segController.frame.size.width / 2, y: y)
            self.drawLineFromPoint(start, toPoint: end, ofColor: Color.PINK, inView: self.segController)
            
            self.followingController?.willMoveToParentViewController(nil)
            self.followingController?.view.removeFromSuperview()
            self.followingController?.removeFromParentViewController()
            
            addChildViewController(self.sellerRecommendationController!)
            self.sellerRecommendationController!.view.frame = self.uiContainerView.bounds
            self.uiContainerView.addSubview((self.sellerRecommendationController?.view)!)
            self.sellerRecommendationController?.didMoveToParentViewController(self)
        } else if(self.segController.selectedSegmentIndex == 1) {
            // init FollowingFeedViewController
            if self.followingController == nil {
                self.followingController = self.storyboard!.instantiateViewControllerWithIdentifier("FollowingFeedViewController") as! FollowingFeedViewController
            }
            
            let y = CGFloat(self.segController.frame.size.height)
            let start: CGPoint = CGPoint(x: self.segController.frame.size.width / 2 , y: y)
            let end: CGPoint = CGPoint(x: self.segController.frame.size.width, y: y)
            self.drawLineFromPoint(start, toPoint: end, ofColor: Color.PINK, inView: self.segController)
            
            self.sellerRecommendationController?.willMoveToParentViewController(nil)
            self.sellerRecommendationController?.view.removeFromSuperview()
            self.sellerRecommendationController?.removeFromParentViewController()
            
            addChildViewController(self.followingController!)
            self.followingController!.view.frame = self.uiContainerView.bounds
            self.uiContainerView.addSubview((self.followingController?.view)!)
            self.followingController?.didMoveToParentViewController(self)
        }
    }
    
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {
        //design the path
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addLineToPoint(end)
        path.lineJoinStyle = CGLineJoin.Round
        path.lineCapStyle = CGLineCap.Square
        path.miterLimit = CGFloat(0.0)
        //design path in layer
        shapeLayer.fillColor = Color.WHITE.CGColor
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = lineColor.CGColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.allowsEdgeAntialiasing = false
        shapeLayer.allowsGroupOpacity = false
        shapeLayer.autoreverses = false
        self.view.layer.addSublayer(shapeLayer)
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
