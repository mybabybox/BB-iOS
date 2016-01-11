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
        print("Calling this .. ")
        apiController.getHomeEollowingFeeds(0)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //apiController.getHomeEollowingFeeds(0)
        
        let _controller = self.storyboard?.instantiateViewControllerWithIdentifier("abstractFeedController") as! AbstractFeedViewController
        _controller.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        _controller.isHeaderView = false
        _controller.contentType = "following"
        self.view.addSubview((_controller.view)!)
        
        let cSelector : Selector = "gotoSecondSegmentOne:"
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(rightSwipe)
        
    }
    
    @IBAction func gotoSecondSegmentOne(sender: AnyObject) {
        let vController = self.view.superview?.superview!.nextResponder() as! InitialHomeSegmentedController
        //let vController = self.storyboard?.instantiateViewControllerWithIdentifier("initialSegmentViewController") as! InitialHomeSegmentedController
        vController.activeSegment = 0
        self.navigationController?.presentViewController(vController, animated: false, completion: nil)
    }
   
}