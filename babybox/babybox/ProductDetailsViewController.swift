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
    
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var prodCondition: UILabel!
    @IBOutlet var imageuser: UIImageView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var month: UILabel!
    @IBOutlet weak var conditionType: UILabel!
    
    @IBOutlet var likeButtonMonth: UIButton!
    @IBOutlet var likeMonths: UILabel!
    
    @IBOutlet var monthTime: UILabel!
    @IBOutlet var buynow: UIButton!
    @IBOutlet weak var uiScrollView: UIScrollView!
    @IBOutlet var viewbtn: UIButton!
    var productModel: PostModel = PostModel()
    var myDate: NSDate = NSDate()
    var conversations: [ConversationVM] = []

    
    var likeFlag: Bool = false
    var id: Double!
    
    
    var productInfo: [PostCatModel] = []
    var noOfComments: Int = 0
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
    
    @IBAction func onClickb(sender: AnyObject) {
        
    }
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
        self.myDate = NSDate()
        self.conversations = []
        
        ApiControlller.apiController.getConversation()
        
        self.uiScrollView.pagingEnabled = true
        self.uiScrollView.contentSize = CGSizeMake(self.uiScrollView.bounds.width, 900)
        
        self.productTitle.text = productModel.title
        self.productPrice.text = "\(constants.currencySymbol) \(String(stringInterpolationSegment: Int(productModel.price)))"
        self.likeCountLabel.text = String(productModel.numLikes)
        self.likeMonths.text = String(productModel.numLikes)
        self.id = Double(productModel.id)
        
        self.conditionType.text = productModel.postType
        self.prodCondition.text = productModel.conditionType
        
        //need to put condition here to show relevant button as per owner status
        self.ownerName.text = productModel.ownerName
        
        print(self.productImageView.frame.width)
        if(productModel.isLiked == false){
            self.likeButton.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = false
        }else {
            self.likeButton.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = true
        }
        
        if (self.productModel.hasImage) {
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
    
    func handleConversation(conversation: [ConversationVM]) {
        self.conversations = conversation
        let time = (self.conversations.last?.lastMessageDate)! / 1000
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(time))
        self.monthTime.text = self.myDate.offsetFrom(date)
        self.month.text = self.myDate.offsetFrom(date)
    }

    override func viewDidLoad() {
        
        
        self.onClickCancel.layer.cornerRadius = 5.0
        self.onClickCancel.layer.masksToBounds = true
        self.imageuser.layer.cornerRadius = 20.0
        self.imageuser.layer.masksToBounds = true
        
        self.viewbtn.layer.cornerRadius = 5.0
        self.viewbtn.layer.masksToBounds = true
        self.viewbtn.layer.borderWidth = CGFloat(1)
        self.viewbtn.layer.borderColor = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF99B8).CGColor
            
        self.postCommentButton.layer.cornerRadius = 5.0
        self.postCommentButton.layer.masksToBounds = true
        self.postCommentButton.layer.borderWidth = CGFloat(1)
        self.postCommentButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.buynow.layer.cornerRadius = 5.0
        self.buynow.layer.masksToBounds = true
        self.commentTextField.delegate=self
        self.commentTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //self.productImageView.frame =
            //CGRectMake(
             //   self.productImageView.frame.origin.x,
             //   self.productImageView.frame.origin.x,
              //  self.productImageView.frame.width,
              //  300)
        
        //self.navigationController?.toolbar.hidden = true
        SwiftEventBus.onMainThread(self, name: "productDetailsReceivedSuccess") { result in
            // UI thread
            print("catch the event...............", terminator: "")
            let resultDto: [PostCatModel] = result.object as! [PostCatModel]
            print(resultDto, terminator: "")
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

       
        let backImg: UIButton = UIButton()
        backImg.addTarget(self, action: "onClickBackBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        backImg.frame = CGRectMake(0, 0, 35, 35)
        backImg.layer.cornerRadius = 18.0
        backImg.layer.masksToBounds = true
        backImg.setImage(UIImage(named: "back"), forState: UIControlState.Normal)
        
        let backBarBtn = UIBarButtonItem(customView: backImg)
        self.navigationItem.leftBarButtonItems = [backBarBtn]
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    func handleGetProductDetailsSuccess(result: [PostCatModel]) {
        print("handling success...", terminator: "")
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
    
    func onClickBackBtn(sender: AnyObject?) {
        if self.fromPage == "homeexplore" {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("initialSegmentViewController") as! InitialHomeSegmentedController
            secondViewController.activeSegment = 0
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }else if self.fromPage == "homefollowing" {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("initialSegmentViewController") as! InitialHomeSegmentedController
            secondViewController.activeSegment = 1
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }else if self.fromPage == "categorydetails" {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CategoryFeedViewController") as! CategoryFeedViewController
            secondViewController.categories = self.category!
            
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
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
