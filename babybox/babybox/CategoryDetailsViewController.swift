//
//  CategoryDetailsViewController.swift
//  Baby Box
//
//  Created by Mac on 20/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus
import Kingfisher

class CategoryDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    
    var categories : CategoryModel = CategoryModel()
    
    override func viewDidAppear(animated: Bool) {
    
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let _controller = self.storyboard?.instantiateViewControllerWithIdentifier("abstractFeedController") as! AbstractFeedViewController
        _controller.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        _controller.setFeedtype(FeedFilter.FeedType.CATEGORY_POPULAR)
        self.view.addSubview((_controller.view)!)

        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        ApiControlller.apiController.getCategoriesFilterByPopularity(Int(categories.id), offSet: 0)

    }
    
    override func viewWillDisappear(animated: Bool) {
        print("view disappeared", terminator: "")
    }
    
}