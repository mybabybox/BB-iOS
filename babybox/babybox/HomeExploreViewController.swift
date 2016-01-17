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
    
    @IBOutlet weak var floatingView: UIView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var apiController: ApiControlller = ApiControlller()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _controller = self.storyboard?.instantiateViewControllerWithIdentifier("abstractFeedController") as! AbstractFeedViewController
        _controller.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        _controller.isHeaderView = true
        _controller.setFeedtype(FeedFilter.FeedType.HOME_EXPLORE)
        _controller.activityLoading.startAnimating()
        self.view.addSubview((_controller.view)!)
        
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
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.floatingView.hidden = true
        self.topConstraint.constant = 0.0
    }
    
}

