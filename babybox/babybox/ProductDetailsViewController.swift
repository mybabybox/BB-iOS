//
//  ProductDetailsViewController.swift
//  Baby Box
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus

class ProductDetailsViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var uiScrollView: UIScrollView!
    var productModel: PostModel = PostModel()
    
    
    var likeFlag: Bool = false
    var id: Double!
    
    var productInfo: [PostCatModel] = []
    
    var fromPage: String = ""
    var items: [String] = [] //comment items
    var category: CategoryModel?
    //handling back button from 3 different
   
    //@IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var postCommentButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField! = nil
    @IBOutlet weak var ownerNumFollowers: UILabel!
    @IBOutlet weak var ownerNumProducts: UILabel!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var onClickCancel: UIButton!
    @IBAction func onClickOk(sender: AnyObject) {
    }
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    @IBOutlet weak var commentTable: UITableView!
    
    @IBAction func onClickLikeOrUnlikeButton(sender: AnyObject) {
        
         let count = Int((self.likeCountLabel.text!))
        if(self.likeFlag == false){
            self.likeButton.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = true
            ApiControlller().likePost(String(Int(self.id)))
            self.likeCountLabel.text = String(count! + 1)
            
        }else{
            self.likeButton.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = false
            ApiControlller().unlikePost(String(Int(self.id)))
            self.likeCountLabel.text = String(count! - 1)
        }
    }

    
    override func viewDidAppear(animated: Bool) {
        print("Show the detail of selected product view.... ", terminator: "");
        print(productModel, terminator: "")
        self.uiScrollView.pagingEnabled = true
        self.uiScrollView.contentSize = CGSizeMake(self.uiScrollView.bounds.width, 900)
        self.productTitle.text = productModel.title
        self.productPrice.text = "\(constants.currencySymbol) \(String(stringInterpolationSegment: productModel.price))"
        self.likeCountLabel.text = String(productModel.numLikes)
        self.id = Double(productModel.id)
        self.ownerName.text = productModel.ownerName
        
        if(productModel.isLiked == false){
            self.likeButton.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = false
        }else {
            self.likeButton.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = true
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if (self.productModel.hasImage) {
                let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(self.productModel.images[0])
                let imageUrl  = NSURL(string: imagePath);
                let imageData = NSData(contentsOfURL: imageUrl!)
                print(imageUrl, terminator: "")
                
                print(self.productImageView.bounds.width)
                print(self.productImageView.bounds.height)
                
                dispatch_async(dispatch_get_main_queue(), {
                    if (imageData != nil) {
                        self.productImageView.image = UIImage(data: imageData!)
                        print("after")
                        print(self.productImageView.bounds.width)
                        print(self.productImageView.bounds.height)
                        
                    }
                });
            }
        })
        
    }
    
    /*override func viewDidLayoutSubviews() {
        self.uiScrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 2000)
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentTextField.delegate=self
        self.commentTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        SwiftEventBus.onMainThread(self, name: "productDetailsReceivedSuccess") { result in
            // UI thread
            print("catch the event...............", terminator: "")
            let resultDto: [PostCatModel] = result.object as! [PostCatModel]
            print(resultDto, terminator: "")
            self.handleGetProductDetailsSuccess(resultDto)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    func handleGetProductDetailsSuccess(result: [PostCatModel]) {
        print("handling success...", terminator: "")
        for value in result {
            self.productInfo.append(value)
        }
        
        for comment in self.productInfo[0].latestComments {
                self.items.append(comment.body)
        }
        self.commentTable.reloadData()
        
        self.productDescriptionLabel.text = self.productInfo[0].body
        self.ownerNumProducts.text = String(self.productInfo[0].ownerNumProducts)
        self.ownerNumFollowers.text = String(self.productInfo[0].ownerNumFollowers)
    }
    
    @IBAction func postComment(sender: AnyObject) {
        print("comment is....", terminator: "")
        print(self.commentTextField.text, terminator: "")
        self.submitComment()
    }
    
    func submitComment() {
        self.items.append(self.commentTextField.text!)
        //print(self.items)
        
        self.commentTable.reloadData()
        
        ApiControlller().postComment(String(Int(self.id)), comment: self.commentTextField.text!)
        self.commentTextField.text = ""
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.commentTable.dequeueReusableCellWithIdentifier("cell")! 
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!" , terminator: "")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    @IBAction func onClickBack(sender: AnyObject) {
        /*var btn = sender as! UIButton
        
        if self.fromPage == "homeexplore" {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("initialSegmentViewController") as! InitialHomeSegmentedController
            secondViewController.activeSegment = 0
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }else if self.fromPage == "homefollowing" {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("initialSegmentViewController") as! InitialHomeSegmentedController
            secondViewController.activeSegment = 1
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }else if self.fromPage == "categorydetails" {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("myCategoryDetailView") as! CategoryDetailsViewController
            secondViewController.categories = self.category!
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }*/
    }
}