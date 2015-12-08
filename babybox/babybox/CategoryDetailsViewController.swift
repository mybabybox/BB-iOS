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
    
    @IBOutlet var typesButtonGroup: [UIButton]!
   
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    var categories : CategoryModel = CategoryModel()
    @IBAction func touchMyButton(sender: AnyObject) {
        print(typesButtonGroup, terminator: "")
        //for (index, element) in enumerate(list) {
        let counter = typesButtonGroup.count
        for index in 1...counter {
            let myButton = typesButtonGroup[index]
            if(myButton == sender as! NSObject){
                //sender.titleLabel?.textColor  = UIColor.redColor()
                self.typesButtonGroup[index].titleLabel?.textColor = UIColor.blueColor()
            }else{
                self.typesButtonGroup[index].titleLabel?.textColor = UIColor.grayColor()
            }
        }
        
        /*for (index, myButton) in typesButtonGroup.enumerate() {
            if(myButton == sender as! NSObject){
                //sender.titleLabel?.textColor  = UIColor.redColor()
                self.typesButtonGroup[index].titleLabel?.textColor = UIColor.blueColor()
            }else{
                self.typesButtonGroup[index].titleLabel?.textColor = UIColor.grayColor()
            }
        }*/
        print(sender, terminator: "")
    }
    
    override func viewDidAppear(animated: Bool) {
       
        print("Show the detail of selected product view.... ", terminator: "");
        
        self.categoryName.text = self.categories.name
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let categoryVM = self.categories
            let imagePath =  constants.imagesBaseURL + categoryVM.icon;
            let imageUrl  = NSURL(string: imagePath);
            let imageData = NSData(contentsOfURL: imageUrl!)
            print(imageUrl, terminator: "")
            dispatch_async(dispatch_get_main_queue(), {
                if (imageData != nil) {
                    self.categoryImageView.image = UIImage(data: imageData!)
                }
            });
            
        })
    }
    
    override func viewDidLoad() {
        print("view loaded", terminator: "");
        
    }
    
    func handleGetProductDetailsSuccess(result: [PostCatModel]) {
        print("handling success...", terminator: "")
        print(result, terminator: "")
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
        print("view disappeared", terminator: "")
    }
}