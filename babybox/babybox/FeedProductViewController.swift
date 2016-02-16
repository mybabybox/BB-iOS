//
//  FeedProductViewController.swift
//  GallerySwiftApp
//
//  Created by Apple on 14/12/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit
import SwiftEventBus

class FeedProductViewController: UIViewController {

    @IBOutlet weak var likeImgBtn: UIButton!
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyNowBtn: UIButton!
    @IBOutlet weak var chatNowBtn: UIButton!
    @IBOutlet weak var likeCountTxt: UIButton!
    @IBOutlet weak var detailTableView: UITableView!
    
    var productModel: PostModel = PostModel()
    var myDate: NSDate = NSDate()
    var conversations: [ConversationVM] = []
    
    var likeFlag: Bool = false
    
    var productInfo: [PostCatModel] = []
    var noOfComments: Int = 0
    var items: [CommentModel] = [] //comment items
    var category: CategoryModel?
    var customDate: NSDate = NSDate()
    //var comments : [String]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSizesForFilterButtons()
        self.detailTableView.separatorColor = UIColor.whiteColor()
        self.detailTableView.estimatedRowHeight = 300.0
        self.detailTableView.rowHeight = UITableViewAutomaticDimension
        self.detailTableView.reloadData()
        
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
    
    override func viewDidAppear(animated: Bool) {
        self.myDate = NSDate()
        self.conversations = []
        
        ApiControlller.apiController.getConversation()
        
        if (productModel.numLikes == 0) {
            self.likeCountTxt.setTitle("Like", forState: UIControlState.Normal)
        } else {
            self.likeCountTxt.setTitle(String(self.productModel.numLikes), forState: UIControlState.Normal)
        }
        
        if(productModel.isLiked == false){
            self.likeImgBtn.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = false
        }else {
            self.likeImgBtn.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UITableViewDelegate

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch section {
        case 0:
            rows = 1
        case 1:
            rows = 1
        case 2:
            rows = 1
        case 3:
            rows = (items.count)+1
        default:
            rows = 1
        }
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var reuseidentifier = "cell1"
        
        switch indexPath.section {
        case 0:
            reuseidentifier = "cell1"
        case 1:
            reuseidentifier = "cell2"
        case 2:
            reuseidentifier = "cell3"
        case 3:
            reuseidentifier = ""
            if indexPath.row != items.count{
                reuseidentifier = "mCell1"
            }else{
                reuseidentifier = "mCell2"
            }
        default:
            reuseidentifier = ""
        }
        
        if indexPath.section == 3 {
            let cell:MessageTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseidentifier, forIndexPath: indexPath) as!  MessageTableViewCell
            if indexPath.row == (items.count) {
                cell.btnPostComments.tag = indexPath.row
                cell.btnPostComments.addTarget(self, action: "PostComments:", forControlEvents: UIControlEvents.TouchUpInside)
                ImageUtil.displayButtonRoundBorder(cell.btnPostComments)
                //cell.btnPostComments.layer.borderWidth = CGFloat(1)
                cell.btnPostComments.layer.borderColor = UIColor.lightGrayColor().CGColor
                
                cell.commentTxt.layer.cornerRadius = 15.0
                cell.commentTxt.layer.masksToBounds = true
                //cell.commentTxt.borderStyle = UITextBorderStyle.None
                
            }else{
                let comment:CommentModel = self.items[indexPath.row] 
                cell.lblComments.text = comment.body
                cell.postedUserName.text = comment.ownerName
                cell.btnDeleteComments.tag = indexPath.row
                cell.postedTime.text = self.myDate.offsetFrom(NSDate(timeIntervalSinceNow: NSTimeInterval(comment.createdDate)))
                if (comment.ownerId == -1 && comment.ownerId != constants.userInfo.id) {
                    cell.btnDeleteComments.hidden = true
                } else {
                    cell.btnDeleteComments.hidden = false
                }
                ImageUtil.displayThumbnailProfileImage(self.items[indexPath.row].ownerId, imageView: cell.postedUserImg)
                cell.btnDeleteComments.addTarget(self, action: "DeleteComments:", forControlEvents: UIControlEvents.TouchUpInside)
                
                let time = comment.createdDate
                cell.postedTime.text = self.myDate.offsetFrom(NSDate(timeIntervalSinceNow: NSTimeInterval(time)))
                
            }
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseidentifier, forIndexPath: indexPath)
                as!  DetailsTableViewCell
            
            switch indexPath.section {
            case 0:
                if (self.productModel.hasImage) {
                    ImageUtil.displayOriginalPostImage(self.productModel.images[0], imageView: cell.productImage)
                    cell.imageHt.constant = ViewUtil.getScreenWidth(self.view) //calculate the screen width...
                }
                cell.soldImage.hidden = !self.productModel.sold
                
            case 1:
                if (self.productInfo.count > 0) {
                    cell.productDesc.text = self.productInfo[0].body
                }
                cell.productTitle.text = productModel.title
                cell.prodCondition.text = ViewUtil.parsePostConditionTypeFromType(self.productModel.conditionType)
                
                if (productModel.originalPrice != 0 && productModel.originalPrice != -1 && productModel.originalPrice != Int(productModel.price)) {
                    let attrString = NSAttributedString(string: "\(constants.currencySymbol) \(String(stringInterpolationSegment:Int(productModel.originalPrice)))", attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
                    cell.prodOriginalPrice.attributedText = attrString
                } else {
                    cell.prodOriginalPrice.attributedText = NSAttributedString(string: "")
                }
                
                cell.prodPrice.text = "\(constants.currencySymbol)\(String(stringInterpolationSegment: Int(productModel.price)))"
                
                if (self.productInfo.count > 0) {
                    cell.prodCategory.text = self.productInfo[0].categoryName
                    //cell.prodTimerCount.text = String(self.productInfo[0].numComments)
                    cell.categoryBtn.hidden = false
                    cell.prodTimerCount.text = customDate.offsetFrom(NSDate(timeIntervalSinceNow: NSTimeInterval(self.productInfo[0].createdDate)))
                } else {
                    cell.categoryBtn.hidden = true
                }
                
            case 2:
                if (self.productInfo.count > 0) {
                    cell.followersCount.text = String(self.productInfo[0].ownerNumFollowers)
                    cell.noOfProducts.text = String(self.productInfo[0].ownerNumProducts)
                    
                    cell.postTime.text = ""
                    cell.postTitle.text = self.productModel.ownerName
                    cell.postedUserImg.image = UIImage(named: "")
                    
                    if (self.productInfo[0].ownerId != -1) {
                        /*let imagePath =  constants.imagesBaseURL + "/image/get-original-post-image-by-id/" + String(self.productInfo[0].ownerId)
                        
                        let imageUrl  = NSURL(string: imagePath);
                        let imageData = NSData(contentsOfURL: imageUrl!)
                        
                        if (imageData != nil) {
                            cell.postedUserImg.image = UIImage(data: imageData!)
                            ImageUtil.displayCircleImage(<#T##url: String##String#>, view: <#T##UIImageView#>)
                            ImageUtil.imageUtil.setCircularImgStyle(cell.postedUserImg)
                        }*/
                        //ImageUtil.displayThumbnailProfileImage(self.productInfo[0].ownerId, imageView: cell.postedUserImg)
                        ImageUtil.displayThumbnailProfileImage(self.productInfo[0].ownerId, imageView: cell.postedUserImg)
                        cell.postedUserImg.layer.cornerRadius = cell.postedUserImg.frame.height/2
                        cell.postedUserImg.layer.masksToBounds = true
                    }
                }
                
                cell.viewBtnIns.layer.borderWidth = CGFloat(1)
                cell.viewBtnIns.layer.borderColor = ImageUtil.imageUtil.UIColorFromRGB(0xFF76A4).CGColor
                ImageUtil.displayButtonRoundBorder(cell.viewBtnIns)
            default:
                reuseidentifier = ""
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return nil
        }else{
            let returnedView = UIView(frame: CGRectMake(0, 0, self.detailTableView.bounds.width, 15.0))
            returnedView.backgroundColor = UIColor.darkGrayColor()
            return returnedView
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.0
        }else{
            return 0.0
        }
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 1:
            return CGFloat(220.0)
        case 2:
            return CGFloat(95.0)
        case 3:
            return CGFloat(50.0)
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //on click of User section show the User profile screen.
        if (indexPath.section == 2) {
            //if (self.productInfo[0].isOwner) {
            //    let vController = self.storyboard?.instantiateViewControllerWithIdentifier("MyProfileFeedViewController") as! MyProfileFeedViewController
                //vController.userId = constants.userInfo.id
            //    self.navigationController?.pushViewController(vController, animated: true)
            //} else {
                let vController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
                vController.userId = self.productInfo[0].ownerId
                //ApiControlller.apiController.getUser(self.productInfo[0].ownerId)
                self.navigationController?.pushViewController(vController, animated: true)
            //}
        }
    }
    
    //MARK: Button Press Events
    func DeleteComments(button: UIButton){
        ApiControlller.apiController.deleteComment(self.items[button.tag].id)
        items.removeAtIndex(button.tag)
        self.detailTableView.reloadData()
        detailTableView.contentInset =  UIEdgeInsetsZero
        
        self.noOfComments--
        self.detailTableView.reloadData()
        self.view.makeToast(message: "Comment Deleted Successfully", duration: 0.5, position: "bottom")
    }
    
    func PostComments(button: UIButton){
        let cell: MessageTableViewCell = button.superview!.superview as! MessageTableViewCell
        let _nComment = CommentModel()
        _nComment.ownerId = constants.userInfo.id
        _nComment.body = cell.commentTxt.text!
        _nComment.ownerName = constants.userInfo.displayName
        _nComment.deviceType = "iOS"
        _nComment.createdDate = Int(NSDate().timeIntervalSince1970)
        _nComment.id = -1
        ApiControlller().postComment(String(Int(productModel.id)), comment: cell.commentTxt.text!)
        
        self.items.append(_nComment)
        self.detailTableView.reloadData()
        cell.txtEnterComments.text = ""
        detailTableView.contentInset =  UIEdgeInsetsZero
        cell.commentTxt.text = ""
        
        
        self.noOfComments++
    }
    
    //MARK: UITextfield Delegate
    func textFieldDidBeginEditing(textField: UITextField!){
        detailTableView.contentInset =  UIEdgeInsetsMake(0, 0, 250, 0);
        detailTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: (self.items.count), inSection:2), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
    }
    
    @IBAction func onClickBuyNow(sender: AnyObject) {
    }
    
    @IBAction func onClickChatNow(sender: AnyObject) {
    }
    
    func setSizesForFilterButtons() {
        let availableWidthForButtons:CGFloat = self.view.bounds.width - 50
        let buttonWidth :CGFloat = availableWidthForButtons / 2
        self.btnWidthConstraint.constant = buttonWidth
        
        self.buyNowBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.buyNowBtn.layer.borderWidth = 1.0
        self.chatNowBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.chatNowBtn.layer.borderWidth = 1.0
        
    }
    
    
    @IBAction func onClickLikeOrUnlikeButton(sender: AnyObject) {
        
        if(self.productModel.isLiked) {
            self.productModel.numLikes--
            self.productModel.isLiked = false
            self.likeImgBtn.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            ApiControlller().likePost(String(Int(productModel.id)))
            self.likeCountTxt.setTitle(String(self.productModel.numLikes), forState: UIControlState.Normal)
            
        } else {
            self.productModel.numLikes++
            self.productModel.isLiked = true
            self.likeImgBtn.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            ApiControlller().unlikePost(String(Int(productModel.id)))
            self.likeCountTxt.setTitle(String(self.productModel.numLikes), forState: UIControlState.Normal)
            
        }
    }
    
    func handleConversation(conversation: [ConversationVM]) {
        self.conversations = conversation
        //let time = (self.conversations.last?.lastMessageDate)! / 1000
        //let date = NSDate(timeIntervalSinceNow: NSTimeInterval(time))
    }
    
    func handleGetProductDetailsSuccess(result: [PostCatModel]) {
        if (result.count > 0) {
            self.productInfo.append(result[0])
            
            for comment in self.productInfo[0].latestComments {
                self.items.append(comment)
            }
            self.noOfComments = self.items.count
        }
        self.detailTableView.reloadData()
    }
    
    @IBAction func onSelectCategory(sender: AnyObject) {
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("CategoryFeedViewController") as! CategoryFeedViewController
        
        vController.selCategory = CategoryCache.getCategoryById(self.productInfo[0].categoryId)
        self.tabBarController!.tabBar.hidden = true
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController, animated: true)
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
