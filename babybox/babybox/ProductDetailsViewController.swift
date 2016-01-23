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

class ProductDetailsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var chatbtn: UIButton!
    @IBOutlet weak var timeLikeCount: UIButton!
    @IBOutlet weak var likeCountValue: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var prodCondition: UILabel!
    @IBOutlet var imageuser: UIImageView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var month: UILabel!
    @IBOutlet weak var conditionType: UILabel!
    
    @IBOutlet var likeMonths: UILabel!
    
    @IBOutlet var monthTime: UILabel!
    @IBOutlet var buynow: UIButton!
    @IBOutlet weak var uiScrollView: UIScrollView!
    @IBOutlet var viewbtn: UIButton!
    @IBOutlet weak var postCommentButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField! = nil
    @IBOutlet weak var ownerNumFollowers: UILabel!
    @IBOutlet weak var ownerNumProducts: UILabel!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    @IBOutlet weak var commentTable: UITableView!
    
    var productModel: PostModel = PostModel()
    var myDate: NSDate = NSDate()
    var conversations: [ConversationVM] = []
    
    var likeFlag: Bool = false
    var id: Double!
    
    var productInfo: [PostCatModel] = []
    var noOfComments: Int = 0
    var items: [String] = [] //comment items
    var category: CategoryModel?
    
    @IBAction func onClickOk(sender: AnyObject) {
    }
    
    @IBAction func onClickb(sender: AnyObject) {
        
    }
    @IBAction func onClickLikeOrUnlikeButton(sender: AnyObject) {
        
        let count = Int((self.likeCountLabel.text!))
        if(self.likeFlag == false) {
            self.likeButton.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = true
            ApiControlller().likePost(String(Int(self.id)))
            if (count == nil) {
                self.likeCountLabel.text = String(1)
            } else {
                self.likeCountLabel.text = String(count! + 1)
            }
            
        } else {
            self.likeButton.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = false
            ApiControlller().unlikePost(String(Int(self.id)))
            self.likeCountLabel.text = String(count! - 1)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.myDate = NSDate()
        self.conversations = []
        
        ApiControlller.apiController.getConversation()
        
        self.uiScrollView.pagingEnabled = true
        self.uiScrollView.contentSize = CGSizeMake(self.uiScrollView.bounds.width, 900)
        
        self.productTitle.text = productModel.title
        self.productPrice.text = "\(constants.currencySymbol)\(String(stringInterpolationSegment: Int(productModel.price)))"
        
        if (productModel.numLikes == 0) {
            self.likeCountLabel.text = "Like"
            self.likeCountLabel.hidden = false
            self.likeCountValue.hidden = true
        } else {
            self.likeCountValue.text = String(productModel.numLikes)
            self.likeCountValue.hidden = false
            self.likeCountLabel.hidden = true
        }
        
        self.likeMonths.text = String(productModel.numLikes)
        self.id = Double(productModel.id)
        
        self.conditionType.text = productModel.postType
        self.prodCondition.text = productModel.conditionType
        
        //need to put condition here to show relevant button as per owner status
        self.ownerName.text = productModel.ownerName
        
        if(productModel.isLiked == false){
            self.likeButton.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = false
        }else {
            self.likeButton.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = true
        }
    
        if (self.productModel.hasImage) {
            self.heightConstraint.constant = self.view.bounds.width
            let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(self.productModel.images[0])
            let imageUrl  = NSURL(string: imagePath);
            let imageData = NSData(contentsOfURL: imageUrl!)
            dispatch_async(dispatch_get_main_queue(), {
                if (imageData != nil) {
                    self.productImageView.image = UIImage(data: imageData!)
                }
            });
        }
    }
    
    override func viewDidLoad() {
        
        BabyboxUtils.babyBoxUtils.setCircularImgStyle(imageuser)
        BabyboxUtils.babyBoxUtils.setButtonRoundBorder(self.viewbtn)
        BabyboxUtils.babyBoxUtils.setButtonRoundBorder(self.buynow)
        BabyboxUtils.babyBoxUtils.setButtonRoundBorder(self.chatbtn)
        BabyboxUtils.babyBoxUtils.setButtonRoundBorder(self.postCommentButton)
        
        self.viewbtn.layer.borderWidth = CGFloat(1)
        self.viewbtn.layer.borderColor = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF76A4).CGColor
        self.timeLikeCount.layer.borderColor = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF76A4).CGColor
        
        self.postCommentButton.layer.borderWidth = CGFloat(1)
        self.postCommentButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        self.commentTextField.delegate=self
        self.commentTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        SwiftEventBus.onMainThread(self, name: "productDetailsReceivedSuccess") { result in
            // UI thread
            let resultDto: [PostCatModel] = result.object as! [PostCatModel]
            self.handleGetProductDetailsSuccess(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "conversationsSuccess") { result in
            // UI thread
            if result != nil {
                let resultDto: [ConversationVM] = result.object as! [ConversationVM]
                self.handleConversation(resultDto)
            } else {
                print("null value")
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "conversationsFailed") { result in
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    
    func handleConversation(conversation: [ConversationVM]) {
        self.conversations = conversation
        let time = (self.conversations.last?.lastMessageDate)! / 1000
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(time))
        self.monthTime.text = self.myDate.offsetFrom(date)
        self.month.text = self.myDate.offsetFrom(date)
    }
    
    func handleGetProductDetailsSuccess(result: [PostCatModel]) {
        if (result.count > 0) {
            self.productInfo.append(result[0])
            
            for comment in self.productInfo[0].latestComments {
                self.items.append(comment.body)
            }
            self.noOfComments = self.items.count
            self.updateCommentTxt()
            self.commentTable.reloadData()
            self.productDescriptionLabel.text = self.productInfo[0].body
            self.ownerNumProducts.text = String(self.productInfo[0].ownerNumProducts)
            self.ownerNumFollowers.text = String(self.productInfo[0].ownerNumFollowers)
            
            if (self.productModel.ownerId != -1) {
                let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(self.productInfo[0].ownerId)
                
                let imageUrl  = NSURL(string: imagePath);
                let imageData = NSData(contentsOfURL: imageUrl!)
                dispatch_async(dispatch_get_main_queue(), {
                    if (imageData != nil) {
                        self.imageuser.image = UIImage(data: imageData!)
                    }
                });
            }
        }
    }
    
    @IBAction func postComment(sender: AnyObject) {
        self.items.append(self.commentTextField.text!)
        self.commentTable.reloadData()
        
        ApiControlller().postComment(String(Int(self.id)), comment: self.commentTextField.text!)
        self.noOfComments++
        self.updateCommentTxt()
        self.commentTextField.text = ""
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.commentTable.dequeueReusableCellWithIdentifier("cell")! 
        
        cell.textLabel?.font = UIFont.systemFontOfSize(12.0)
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
    
    func updateCommentTxt() {
        //self.calculateTableViewHeight()
        self.commentsCount.text = String(noOfComments) + " Comments"
    }
    
    func calculateTableViewHeight() {
        let height = self.commentTable.contentSize.height
        UIView.animateWithDuration(0.2, animations: {
            //self.tableViewHeightConstraint.constant = height;
            
            self.commentTable.frame = CGRectMake(self.commentTable.frame.origin.x, self.commentTable.frame.origin.y, self.commentTable.frame.width, height)
            self.view.setNeedsUpdateConstraints()
            self.view.needsUpdateConstraints()
        })
    }
    
}

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
        print("in nsdaate......")
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date)) years ago"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date)) months ago"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date)) weeks ago"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date)) days ago"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date)) hours ago"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date)) minutes ago" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date)) seconds ago" }
        return ""
    }
}
