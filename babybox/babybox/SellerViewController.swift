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
    
    var pageMenu : CAPSPageMenu?

    var sellerRecommendationController : RecommendedSellerViewController? = nil
    var followingController : FollowingFeedViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.grayColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(12.0)
        ]
        
        let activeTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(12.0)
        ]
        // PageMenu
        
        var controllerArray : [UIViewController] = []
        
        self.sellerRecommendationController = self.storyboard!.instantiateViewControllerWithIdentifier("RecommendedSeller") as? RecommendedSellerViewController
        self.sellerRecommendationController?.title = "Recommended Sellers"
        self.sellerRecommendationController?.parentNavigationController = self.navigationController
        controllerArray.append(self.sellerRecommendationController!)
        
        self.followingController = self.storyboard!.instantiateViewControllerWithIdentifier("FollowingFeedViewController") as? FollowingFeedViewController
        self.followingController?.title = "Following"
        self.followingController?.parentNavigationController = self.navigationController
        controllerArray.append(self.followingController!)

        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .MenuItemSeparatorWidth(0),
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .ViewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .BottomMenuHairlineColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1)),
            .SelectionIndicatorColor(ImageUtil.getPinkColor()),
            .MenuMargin(0.0),
            .MenuHeight(40.0),
            .SelectedMenuItemLabelColor(ImageUtil.getPinkColor()),
            .UnselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
            .MenuItemFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorRoundEdges(true),
            .SelectionIndicatorHeight(2.0),
            .MenuItemSeparatorPercentageHeight(0.1)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
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

}
