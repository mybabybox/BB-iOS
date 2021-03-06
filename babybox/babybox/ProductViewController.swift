//
//  ProductViewController.swift
//  babybox
//
//  Created by Apple on 14/12/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit
import SwiftEventBus
import PhotoSlider

class ProductViewController: ProductNavigationController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoSliderDelegate {

    @IBOutlet weak var buyerSoldButtonsLayout: UIView!
    @IBOutlet weak var buyerButtonsLayout: UIView!
    @IBOutlet weak var sellerButtonsLayout: UIView!
    @IBOutlet weak var sellerSoldButtonsLayout: UIView!
    
    @IBOutlet weak var soldViewChatsButton: UIButton!
    @IBOutlet weak var viewChatsButton: UIButton!
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var soldText: UIButton!
    
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var likeImgBtn: UIButton!
    @IBOutlet weak var likeCountTxt: UIButton!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var activeText: UITextField!
    
    var moreCommentUpdated: Bool = false
    
    var lcontentSize = CGFloat(0.0)
    var lblCommentsSize = CGFloat(0.0)
    var feedItem: PostVMLite = PostVMLite()
    var myDate: NSDate = NSDate()
    var isShownKeyboard = false
    
    var productInfo: PostVM?
    var comments: [CommentVM] = []
    var category: CategoryVM?
    var customDate: NSDate = NSDate()
    
    var collectionView: UICollectionView!
    
    var images: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name: "soldPostSuccess") { result in
            self.feedItem.sold = true
            self.productInfo?.sold = true
            self.processButtonsVisibility()
        }
        
        SwiftEventBus.onMainThread(self, name: "soldPostFailed") { result in
            ViewUtil.makeToast("Failed to mark item as sold. Please try again later.", view: self.view)
        }
        
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        //view.addGestureRecognizer(tap)
        
        self.detailTableView.separatorColor = Color.WHITE
        //self.detailTableView.estimatedRowHeight = Constants.PRODUCT_TABLE_ESTIMATED_HEIGHT
        self.detailTableView.rowHeight = UITableViewAutomaticDimension
        
        self.detailTableView.setNeedsLayout()
        self.detailTableView.layoutIfNeeded()
        self.detailTableView.reloadData()
        self.detailTableView.translatesAutoresizingMaskIntoConstraints = true
        //self.detailTableView.backgroundColor = Color.FEED_BG
        
        ViewUtil.showActivityLoading(self.activityLoading)
        
        ApiFacade.getPost(feedItem.id, successCallback: onSuccessGetPost, failureCallback: onFailure)
        
        /*
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil)
        */
    }
    
    override func viewDidAppear(animated: Bool) {
        self.myDate = NSDate()
        if moreCommentUpdated {
            //let indexPaths = [NSIndexPath(forRow: 1, inSection: 3)]
            //self.detailTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
            moreCommentUpdated = false
            self.detailTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UITableViewDelegate

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
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
            rows = 1
        case 4:
            rows = self.comments.count + 1
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
            reuseidentifier = "cell4"
        case 4:
            reuseidentifier = ""
            if indexPath.row != self.comments.count{
                reuseidentifier = "mCell1"
            } else {
                reuseidentifier = "mCell2"
            }
        default:
            reuseidentifier = ""
        }
        
        if indexPath.section == 4 {
            let cell:MessageTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseidentifier, forIndexPath: indexPath) as! MessageTableViewCell
            
            if indexPath.row == self.comments.count {
                cell.btnPostComments.tag = indexPath.row
                cell.btnPostComments.addTarget(self, action: "PostComments:", forControlEvents: UIControlEvents.TouchUpInside)
                ViewUtil.displayRoundedCornerView(cell.btnPostComments)
                cell.btnPostComments.layer.borderColor = Color.LIGHT_GRAY.CGColor
                cell.commentTxt.layer.cornerRadius = Constants.DEFAULT_CORNER_RADIUS
                cell.commentTxt.layer.masksToBounds = true
                //cell.commentTxt.delegate = self
            } else {
                let comment:CommentVM = self.comments[indexPath.row]
                cell.lblComments.text = comment.body
                //cell.lblComments.numberOfLines = 0
                //self.lblCommentsSize = cell.lblComments.frame.size.height
                
                //cell.lblComments.sizeToFit()
                cell.postUserName.setTitle(comment.ownerName, forState: .Normal)
                if (comment.id != -1) {
                    cell.postedTime.text = NSDate(timeIntervalSince1970:Double(comment.createdDate) / 1000.0).timeAgo
                } else {
                    cell.postedTime.text = NSDate(timeIntervalSinceNow: comment.createdDate / 1000.0).timeAgo
                }
                ImageUtil.displayThumbnailProfileImage(self.comments[indexPath.row].ownerId, imageView: cell.userImg)
            }
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseidentifier, forIndexPath: indexPath) as! DetailsTableViewCell
            
            switch indexPath.section {
            case 0:
                if self.productInfo != nil && self.productInfo!.images.count > 0 {
                    for i in 0...self.productInfo!.images.count - 1 {
                        self.images.append(String(self.productInfo!.images[i]))
                    }
                    self.collectionView = cell.viewWithTag(1) as! UICollectionView
                    self.collectionView.delegate = self
                    self.collectionView.dataSource = self
                    cell.soldImage.hidden = !self.productInfo!.sold
                }
                
            case 1:
                cell.contentMode = UIViewContentMode.Redraw
                cell.sizeToFit()
                if self.productInfo != nil {
                    cell.productDesc.text = self.productInfo!.body
                    cell.productDesc.numberOfLines = 0
                    cell.productDesc.sizeToFit()
                    self.lcontentSize = cell.productDesc.frame.size.height
                
                    cell.productTitle.text = self.productInfo!.title
                    cell.prodCondition.text = ViewUtil.parsePostConditionTypeFromType(self.productInfo!.conditionType)
                    
                    if (self.productInfo!.originalPrice != 0 && self.productInfo!.originalPrice != -1 && self.productInfo!.originalPrice != Int(self.productInfo!.price)) {
                        let attrString = NSAttributedString(string: "\(Constants.CURRENCY_SYMBOL)\(String(stringInterpolationSegment:Int(self.productInfo!.originalPrice)))", attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
                        cell.prodOriginalPrice.attributedText = attrString
                    } else {
                        cell.prodOriginalPrice.attributedText = NSAttributedString(string: "")
                    }
                    
                    cell.prodPrice.text = "\(Constants.CURRENCY_SYMBOL)\(String(stringInterpolationSegment: Int(self.productInfo!.price)))"
                
                }
                
                if self.productInfo != nil {
                    //cell.prodTimerCount.text = String(self.productInfo.numComments)
                    cell.categoryBtn.hidden = false
                    cell.categoryBtn.setTitle(self.productInfo!.categoryName, forState: .Normal)
                    cell.categoryBtn.setTitleColor(Color.PINK, forState: .Normal)
                    cell.categoryBtn.sizeToFit()
                    cell.prodTimerCount.text = NSDate(timeIntervalSince1970:Double(self.productInfo!.createdDate) / 1000.0).timeAgo
                } else {
                    cell.categoryBtn.hidden = true
                }
                
            case 2:
                if self.productInfo != nil {
                    cell.followersCount.text = String(self.productInfo!.ownerNumFollowers)
                    cell.noOfProducts.text = String(self.productInfo!.ownerNumProducts)
                    
                    cell.postTitle.text = self.productInfo!.ownerName
                    cell.postedUserImg.image = UIImage(named: "")
                    cell.ownerLastLogin.text = NSDate(timeIntervalSince1970: self.productInfo!.ownerLastLogin / 1000.0).timeAgo
                    
                    if self.productInfo!.ownerId != -1 {
                        ImageUtil.displayThumbnailProfileImage(self.productInfo!.ownerId, imageView: cell.postedUserImg)
                        cell.postedUserImg.layer.cornerRadius = cell.postedUserImg.frame.height / 2
                        cell.postedUserImg.layer.masksToBounds = true
                    }
                }
                
                ViewUtil.displayRoundedCornerView(cell.viewBtnIns, bgColor: Color.PINK)
            case 3:
                if let commentCount = productInfo?.numComments {
                    cell.commentsCount.text = String(commentCount)
                }
                
            default:
                reuseidentifier = ""
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            let returnedView = UIView(frame: CGRectMake(0, 0, self.detailTableView.bounds.width, 15.0))
            returnedView.backgroundColor = Color.DARK_GRAY
            return returnedView
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        } else {
            return 0.0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            // image slider
            return ViewUtil.getScreenWidth(self.view)
        case 1:
            // Product info
            if self.productInfo != nil {
                return Constants.PRODUCT_INFO_HEIGHT + self.lcontentSize
            }
            return Constants.PRODUCT_INFO_HEIGHT
        case 2:
            // seller
            return Constants.PRODUCT_SELLER_HEIGHT
        case 4:
            // comments
            return Constants.PRODUCT_COMMENTS_HEIGHT
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // on click of User section show the User profile screen.
        if indexPath.section == 2  {
            self.performSegueWithIdentifier("userprofile", sender: nil)
        } else if (indexPath.section == 4 && indexPath.row == self.comments.count) || indexPath.section == 3 {
            pushMoreCommentsController()
        }
    }
    
    @IBAction func onClickLikeOrUnlikeButton(sender: AnyObject) {
        if (self.productInfo!.isLiked) {
            self.productInfo!.numLikes -= 1
            self.productInfo!.isLiked = false
            
            self.feedItem.numLikes -= 1
            self.feedItem.isLiked = false
            
            self.likeImgBtn.setImage(UIImage(named: "ic_like.png"), forState: UIControlState.Normal)
            self.likeCountTxt.setTitle(String(self.productInfo!.numLikes), forState: UIControlState.Normal)
            ApiController.instance.unlikePost(self.productInfo!.id)
        } else {
            self.productInfo!.numLikes += 1
            self.productInfo!.isLiked = true
            
            self.feedItem.numLikes += 1
            self.feedItem.isLiked = true
            
            self.likeImgBtn.setImage(UIImage(named: "ic_liked.png"), forState: UIControlState.Normal)
            self.likeCountTxt.setTitle(String(self.productInfo!.numLikes), forState: UIControlState.Normal)
            ApiController.instance.likePost(self.productInfo!.id)
        }
    }
    
    func onSuccessGetPost(productInfo: PostVM) {
        self.productInfo = productInfo
        self.comments.removeAll()
        for comment in self.productInfo!.latestComments {
            self.comments.append(comment)
        }
        self.initLikeUnlike()
        self.detailTableView.reloadData()
        self.processButtonsVisibility()
        self.enableEditPost()
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("hcell", forIndexPath: indexPath) as! ImageCollectionViewCell
        let imageView = cell.imageView
        cell.pageControl.numberOfPages = self.productInfo!.images.count
        cell.pageControl.currentPage = indexPath.row
        cell.pageControl.hidesForSinglePage = true
        ImageUtil.displayOriginalPostImage(Int(self.images[indexPath.row])!, imageView: imageView)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tCell = collectionView.cellForItemAtIndexPath(indexPath) as? ImageCollectionViewCell
        let imageUrl = ImageUtil.getProductImageUrl(self.images[indexPath.row])
        ViewUtil.viewFullScreenImageByUrl(imageUrl, viewController: self)
        tCell?.pageControl.currentPage = indexPath.row
    }
    
    // MARK: - PhotoSliderDelegate
    
    func photoSliderControllerWillDismiss(viewController: PhotoSlider.ViewController) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        let indexPath = NSIndexPath(forItem: viewController.currentPage, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
    }
    
    func initLikeUnlike() {
        if (self.productInfo!.numLikes == 0) {
            self.likeCountTxt.setTitle("Like", forState: UIControlState.Normal)
        } else {
            self.likeCountTxt.setTitle(String(self.productInfo!.numLikes), forState: UIControlState.Normal)
        }
        
        if (self.productInfo!.isLiked) {
            self.likeImgBtn.setImage(UIImage(named: "ic_liked.png"), forState: UIControlState.Normal)
        } else {
            self.likeImgBtn.setImage(UIImage(named: "ic_like.png"), forState: UIControlState.Normal)
        }
    }
    
    //categoryScreen
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "categoryScreen" {
            return true
        } else if identifier == "userprofile" {
            return true
        } else if identifier == "viewChats" || identifier == "soldViewChat" {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "categoryScreen" {
            let vController = segue.destinationViewController as! CategoryFeedViewController
            vController.selCategory = CategoryCache.getCategoryById(self.productInfo!.categoryId)
            vController.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "userprofile" {
            let vController = segue.destinationViewController as! UserProfileFeedViewController
            vController.userId = self.productInfo!.ownerId
            vController.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "viewChats" || segue.identifier == "soldViewChat" {
            //postId
            let vController = segue.destinationViewController as! ProductChatViewController
            vController.postId = self.productInfo!.id
            vController.hidesBottomBarWhenPushed = true
        }
        
        ViewUtil.resetBackButton(self.navigationItem)
    }
    
    func processButtonsVisibility() {
        
        self.buyerButtonsLayout.hidden = true
        self.sellerButtonsLayout.hidden = true
        self.buyerSoldButtonsLayout.hidden = true
        self.sellerSoldButtonsLayout.hidden = true
        
        if (self.productInfo!.isOwner) {
            if (self.productInfo!.sold) {
                self.sellerSoldButtonsLayout.hidden = false
            } else {
                self.sellerButtonsLayout.hidden = false                
            }
        } else {
            if (self.productInfo!.sold) {
                self.buyerSoldButtonsLayout.hidden = false
            } else {
                self.buyerButtonsLayout.hidden = false
            }
        }
    }
    
    @IBAction func onClickMarkAsSold(sender: AnyObject) {
        let _messageDialog = UIAlertController(title: "", message: Constants.PRODUCT_SOLD_CONFIRM_TEXT, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Default, handler: nil)
        let confirmAction = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            ApiController.instance.soldPost(self.feedItem.id)
            //ViewUtil.makeToast("Confirm Sold", view: self.view)
        })
    
        _messageDialog.addAction(cancelAction)
        _messageDialog.addAction(confirmAction)
        self.presentViewController(_messageDialog, animated: true, completion: nil)
    }
    
    @IBAction func onClickBuyNow(sender: AnyObject) {
        let vController = self.storyboard!.instantiateViewControllerWithIdentifier("MakeOfferViewController") as! MakeOfferViewController
        vController.productInfo = self.productInfo
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    @IBAction func onClickChatNow(sender: AnyObject) {
        ConversationCache.open(self.productInfo!.id, successCallback: onSuccessOpenConversation, failureCallback: onFailure)
    }
    
    @IBAction func onClickViewChat(sender: AnyObject) {
    }
    
    @IBAction func onClickSold(sender: AnyObject) {
        let _messageDialog = UIAlertController(title: "", message: Constants.PRODUCT_SOLD_TEXT, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertActionStyle.Default, handler: nil)
        _messageDialog.addAction(okAction)
        
        self.presentViewController(_messageDialog, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool { // called when 'return' key pressed. return NO to ignore.
        textField.resignFirstResponder()
        return true
    }
    
    func onSuccessOpenConversation(conversation: ConversationVM) {
        let vController = self.storyboard!.instantiateViewControllerWithIdentifier("MessagesViewController") as! MessagesViewController
        vController.conversation = conversation
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    func onFailure(message: String) {
        ViewUtil.showDialog("Error", message: message, view: self)
    }
    
    func enableEditPost() {
        if (self.productInfo!.isOwner) {
            let editProductImg: UIButton = UIButton()
            editProductImg.setTitle(NSLocalizedString("edit", comment: ""), forState: UIControlState.Normal)
            editProductImg.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            editProductImg.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
            editProductImg.frame = CGRectMake(0, 0, 35, 35)
            editProductImg.addTarget(self, action: "onClickEditBtn:", forControlEvents: UIControlEvents.TouchUpInside)
            let editProductBarBtn = UIBarButtonItem(customView: editProductImg)
            self.navigationItem.rightBarButtonItems?.insert(editProductBarBtn, atIndex: 0)
        }
    }
    
    /* Product Navigation Method Implementation */
    func onClickEditBtn(sender: AnyObject?) {
        let vController =
            self.storyboard?.instantiateViewControllerWithIdentifier("EditProductViewController") as? EditProductViewController
        vController!.hidesBottomBarWhenPushed = true
        vController!.postId = self.feedItem.id
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController!, animated: true)
    }
    
    func onClickWhatsupBtn(sender: AnyObject?) {
        SharingUtil.shareToWhatsapp(self.productInfo!)
    }
    
    func onClickCopyLinkBtn(sender: AnyObject?) {
        //copy url to cliboard
        ViewUtil.copyToClipboard(UrlUtil.createProductUrl(self.productInfo!))
        ViewUtil.makeToast(NSLocalizedString("link_copy", comment: ""), view: self.view)
    }
    
    func onClickFacebookLinkBtn(sender: AnyObject?) {
        SharingUtil.shareToFacebook(self.productInfo!, vController: self)
    }
 
    /*
    func textFieldDidBeginEditing(textField: UITextField) {
        activeText = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeText = nil
    }
    
    //Keyboard Overlapping UITextField solution approach
    //http://stackoverflow.com/questions/594181/making-a-uitableview-scroll-when-text-field-is-selected
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            var frame = self.detailTableView.frame
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(0.3)
            frame.size.height -= keyboardSize.height
            self.detailTableView.frame = frame
            if activeText != nil {
                let rect = self.detailTableView.convertRect(activeText.bounds, fromView: activeText)
                self.detailTableView.scrollRectToVisible(rect, animated: false)
            }
            UIView.commitAnimations()
        }
        
        if !isShownKeyboard {
            
            var info = notification.userInfo!
            let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                //self.buttomLayoutConstraint = keyboardFrame.size.height
                
                var frame = self.detailTableView.frame
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationBeginsFromCurrentState(true)
                UIView.setAnimationDuration(0.3)
                frame.size.height -= keyboardFrame.size.height
                self.detailTableView.frame = frame
                if self.activeText != nil {
                    let rect = self.detailTableView.convertRect(self.activeText.bounds, fromView: self.activeText)
                    self.detailTableView.scrollRectToVisible(rect, animated: false)
                }
                
                }) { (completed: Bool) -> Void in
                    
            }
            isShownKeyboard = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            var frame = self.detailTableView.frame
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(0.3)
            frame.size.height += keyboardSize.height
            self.detailTableView.frame = frame
            isShownKeyboard = false
            UIView.commitAnimations()
        }
    }
    */

    @IBAction func onClickMoreComments(sender: AnyObject) {
        pushMoreCommentsController()
    }
    
    @IBAction func onClickPostUser(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! MessageTableViewCell
        
        let indexPath = self.detailTableView.indexPathForCell(cell)!
        
        let vController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = self.comments[indexPath.row].ownerId
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    func pushMoreCommentsController() {
        let vController = self.storyboard!.instantiateViewControllerWithIdentifier("MoreCommentsViewController") as! MoreCommentsViewController
        if let postId = self.productInfo?.id {
            vController.postId = postId
            ViewUtil.resetBackButton(self.navigationItem)
            self.navigationController?.pushViewController(vController, animated: true)
        }
    }
}
