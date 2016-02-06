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
        
        self.detailTableView.estimatedRowHeight = 300.0
        self.detailTableView.rowHeight = UITableViewAutomaticDimension
        self.detailTableView.reloadData()
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
                BabyboxUtils.babyBoxUtils.setButtonRoundBorder(cell.btnPostComments)
                cell.btnPostComments.layer.borderWidth = CGFloat(1)
                cell.btnPostComments.layer.borderColor = UIColor.lightGrayColor().CGColor
                
                cell.commentTxt.layer.cornerRadius = 15.0
                cell.commentTxt.layer.masksToBounds = true
                //cell.commentTxt.borderStyle = UITextBorderStyle.None
                
            }else{
                let comment:CommentModel = self.items[indexPath.row] 
                cell.lblComments.text = comment.body
                cell.postedUserName.text = comment.ownerName
                cell.btnDeleteComments.tag = indexPath.row
                
                if (comment.ownerId == -1) {
                    cell.btnDeleteComments.hidden = true
                } else {
                    cell.btnDeleteComments.hidden = false
                }
                let imagePath =  constants.imagesBaseURL + "/image/get-thumbnail-profile-image-by-id/" + String(self.items[indexPath.row].ownerId)
                let imageUrl  = NSURL(string: imagePath);
                let imageData = NSData(contentsOfURL: imageUrl!)
                if (imageData != nil) {
                    //BabyboxUtils.babyBoxUtils.setCircularImgStyle((cell.userImage)!)
                    cell.postedUserImg.layer.cornerRadius = 18.0
                    cell.postedUserImg.layer.masksToBounds = true
                    cell.postedUserImg.image = UIImage(data: imageData!)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                }
                
                cell.btnDeleteComments.addTarget(self, action: "DeleteComments:", forControlEvents: UIControlEvents.TouchUpInside)
                BabyboxUtils.babyBoxUtils.setButtonRoundBorder(cell.postedUserImg)
                
                let time = comment.createdDate
                cell.postedTime.text = self.myDate.offsetFrom(NSDate(timeIntervalSinceNow: NSTimeInterval(time)))
                
            }
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseidentifier, forIndexPath: indexPath)
                as!  DetailsTableViewCell
            
            switch indexPath.section {
            case 0:
                if (self.productModel.hasImage) {
                    let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(self.productModel.images[0])
                    let imageUrl  = NSURL(string: imagePath);
                    let imageData = NSData(contentsOfURL: imageUrl!)
                    
                    if (imageData != nil) {
                        cell.productImage.image = UIImage(data: imageData!)
                    }
                }
                
            case 1:
                if (self.productInfo.count > 0) {
                    cell.productDesc.text = self.productInfo[0].body
                }
                cell.productTitle.text = productModel.title
                cell.prodCondition.text = self.productModel.conditionType
                
                if (productModel.originalPrice != 0 && productModel.originalPrice != -1 && productModel.originalPrice != Int(productModel.price)) {
                    let attrString = NSAttributedString(string: "\(constants.currencySymbol) \(String(stringInterpolationSegment:Int(productModel.originalPrice)))", attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
                    cell.prodOriginalPrice.attributedText = attrString
                } else {
                    cell.prodOriginalPrice.attributedText = NSAttributedString(string: "")
                }
                
                cell.prodPrice.text = "\(constants.currencySymbol)\(String(stringInterpolationSegment: Int(productModel.price)))"
                cell.prodCategory.text = ""
                cell.prodTimer.image = UIImage(named: "")
                cell.prodTimerCount.text = ""
                
            case 2:
                if (self.productInfo.count > 0) {
                    cell.followersCount.text = String(self.productInfo[0].ownerNumFollowers)
                    cell.noOfProducts.text = String(self.productInfo[0].ownerNumProducts)
                    
                    cell.postTime.text = ""
                    cell.postTitle.text = self.productModel.ownerName
                    cell.postedUserImg.image = UIImage(named: "")
                    
                    if (self.productInfo[0].ownerId != -1) {
                        let imagePath =  constants.imagesBaseURL + "/image/get-original-post-image-by-id/" + String(self.productInfo[0].ownerId)
                        
                        let imageUrl  = NSURL(string: imagePath);
                        let imageData = NSData(contentsOfURL: imageUrl!)
                        
                        if (imageData != nil) {
                            cell.postedUserImg.image = UIImage(data: imageData!)
                            
                            cell.postedUserImg.layer.cornerRadius = 18.0
                            cell.postedUserImg.layer.masksToBounds = true
                            
                            //BabyboxUtils.babyBoxUtils.setCircularImgStyle(cell.postedUserImg)
                        }
                        
                    }
                }
                
                
                cell.viewBtnIns.layer.borderWidth = CGFloat(1)
                cell.viewBtnIns.layer.borderColor = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF76A4).CGColor
                BabyboxUtils.babyBoxUtils.setButtonRoundBorder(cell.viewBtnIns)
            default:
                reuseidentifier = ""
            }
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
            return CGFloat(105.0)
        case 3:
            return CGFloat(60.0)
        default:
            return UITableViewAutomaticDimension
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
        //_nComment.createdDate = NSDate()
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
        let time = (self.conversations.last?.lastMessageDate)! / 1000
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(time))
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
    
}

