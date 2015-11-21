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

class CategoryDetailsViewController: UIViewController {
    
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    var categories : CategoryModel = CategoryModel()
    
    override func viewDidAppear(animated: Bool) {
        print("Show the detail of selected product view.... ");
        
        self.categoryName.text = self.categories.name
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let categoryVM = self.categories
            let imagePath =  constants.imagesBaseURL + categoryVM.icon;
            let imageUrl  = NSURL(string: imagePath);
            let imageData = NSData(contentsOfURL: imageUrl!)
            print(imageUrl)
            dispatch_async(dispatch_get_main_queue(), {
                if (imageData != nil) {
                    self.categoryImageView.image = UIImage(data: imageData!)
                }
            });
            
        })
        
        
    }
    
    override func viewDidLoad() {
        print("view loaded");
        
    }
    
    func handleGetProductDetailsSuccess(result: [PostCatModel]) {
        print("handling success...")
        print(result)
        //self.productInfo.appendContentsOf(result)
        
//        for comment in self.productInfo[0].latestComments {
//            self.items.append(comment.body)
//        }
//        self.commentTable.reloadData()
//        
//        self.productDescriptionLabel.text = self.productInfo[0].body
//        self.ownerNumProducts.text = String(self.productInfo[0].ownerNumProducts)
//        self.ownerNumFollowers.text = String(self.productInfo[0].ownerNumFollowers)
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("view disappeared")
    }
}