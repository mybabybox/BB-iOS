//
//  ViewController.swift
//  
//
//  Created by Apple on 11/12/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit
import SwiftEventBus
import Kingfisher

class HomeExploreViewController: UIViewController {
    
    var apiController: ApiControlller = ApiControlller()
    var _controller: AbstractFeedViewController? = nil
    
    @IBOutlet weak var exploreTip: UIView!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the preferences for Explore Tip and if present hide the tip.
        _controller = self.storyboard?.instantiateViewControllerWithIdentifier("abstractFeedController") as? AbstractFeedViewController
        if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.HOME_EXPLORE_TIPS)) {
            self.exploreTip.hidden = false
            _controller!.view.frame = CGRectMake(0, exploreTip.frame.height, self.view.frame.width, self.view.frame.height)
            SharedPreferencesUtil.getInstance().setScreenViewed(SharedPreferencesUtil.Screen.HOME_EXPLORE_TIPS)
        } else {
            _controller!.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        }
        
        _controller!.isHeaderView = true
        _controller!.setFeedtype(FeedFilter.FeedType.HOME_EXPLORE)
        _controller!.activityLoading.startAnimating()
        self.view.addSubview((_controller!.view)!)
        
        apiController.getAllCategories();
        apiController.getHomeExploreFeeds(0);
        
        let cSelector : Selector = "gotoSecondSegmentTwo:"
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(leftSwipe)
    }
    
    @IBAction func gotoSecondSegmentTwo(sender: AnyObject) {
        let vController = self.view.superview?.superview!.nextResponder() as! InitialHomeSegmentedController
        vController.activeSegment = 1
        self.navigationController?.presentViewController(vController, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSellButton() -> UIBarButtonItem {
        let sellImage: UIImage = UIImage(named:"ic_info_bubble")!
        let frameimg: CGRect = CGRectMake(0, 0, 30, 30);
        let sellButton = UIButton(frame: frameimg)
        sellButton.setBackgroundImage(sellImage, forState: UIControlState.Normal)
        sellButton.showsTouchWhenHighlighted = true
        sellButton.addTarget(self, action: "sellButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        
        let sellBarButton = UIBarButtonItem()
        sellBarButton.customView = sellButton
        
        return sellBarButton
    }
    
    func sellButtonPressed() {
        NSLog("Sell button Pressed...")
        self.performSegueWithIdentifier("sellProductView", sender: nil)
        
    }
    
    @IBAction func onClicTipClose(sender: AnyObject) {
        self.exploreTip.hidden = true
        _controller!.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
    }
}

