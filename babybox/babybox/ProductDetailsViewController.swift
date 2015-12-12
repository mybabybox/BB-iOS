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
    
    var productModel: PostModel = PostModel()
   
    
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
    
    var likeFlag: Bool!
    var id: Double!
    
    var productInfo: [PostCatModel] = []
    
    var items: [String] = [] //comment items
    
    
    @IBAction func onClickLikeOrUnlikeButton(sender: AnyObject) {
        print("sender..............\(sender)", terminator: "")
        
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
                dispatch_async(dispatch_get_main_queue(), {
                    if (imageData != nil) {
                        self.productImageView.image = UIImage(data: imageData!)
                    }
                });
            }
        })
        
    }
    
    override func viewDidLoad() {
        print("view loaded", terminator: "");
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
        print("view disappeared", terminator: "")
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
        print("You selected cell #\(indexPath.row)!", terminator: "")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        print("return key is pressed", terminator: "")
        self.submitComment()
        return true;
    }
    
}