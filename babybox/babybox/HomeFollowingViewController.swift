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
    
    override func viewDidAppear(animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        apiController.getHomeEollowingFeeds(0)
        
        let _controller = self.storyboard?.instantiateViewControllerWithIdentifier("abstractFeedController") as! AbstractFeedViewController
        
        //put condition here to check if the tips section is visible or not and accordingly set x,y coordinates for 
        //CollectionView
        
        _controller.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        _controller.isHeaderView = false
        _controller.setFeedtype(FeedFilter.FeedType.HOME_FOLLOWING)
        self.view.addSubview((_controller.view)!)
        
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

   
}