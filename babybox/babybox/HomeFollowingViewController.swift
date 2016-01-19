//
//  HomeFollowingViewController.swift
//  Baby Box
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import UIKit
import SwiftEventBus
import Kingfisher

class HomeFollowingViewController: UIViewController {
    
    var currentSelProduct: Int = 0
    var apiController: ApiControlller = ApiControlller()
    var _controller: AbstractFeedViewController? = nil
    
    @IBOutlet weak var followingTips: UIView!
    override func viewDidAppear(animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        apiController.getHomeEollowingFeeds(0)
        
        //Get the preferences for Explore Tip and if present hide the tip.
        _controller = self.storyboard?.instantiateViewControllerWithIdentifier("abstractFeedController") as? AbstractFeedViewController
        if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.HOME_FOLLOWING_TIPS)) {
            self.followingTips.hidden = false
            _controller!.view.frame = CGRectMake(0, followingTips.frame.height + 20, self.view.frame.width, self.view.frame.height)
            SharedPreferencesUtil.getInstance().setScreenViewed(SharedPreferencesUtil.Screen.HOME_FOLLOWING_TIPS)
        } else {
            _controller!.view.frame = CGRectMake(0, 5, self.view.frame.width, self.view.frame.height)
        }
        
        _controller!.isHeaderView = false
        _controller!.setFeedtype(FeedFilter.FeedType.HOME_FOLLOWING)
        self.view.addSubview((_controller!.view)!)
        
        let cSelector : Selector = "gotoSecondSegmentOne:"
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(rightSwipe)
        
    }
    
    @IBAction func gotoSecondSegmentOne(sender: AnyObject) {
        let vController = self.view.superview?.superview!.nextResponder() as! InitialHomeSegmentedController
        vController.activeSegment = 0
        self.navigationController?.presentViewController(vController, animated: false, completion: nil)
    }
   
    @IBAction func onCloseTips(sender: AnyObject) {
        self.followingTips.hidden = true
        _controller!.view.frame = CGRectMake(0, 5, self.view.frame.width, self.view.frame.height)
    }
}