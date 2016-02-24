//
//  FeedProductViewController.swift
//  GallerySwiftApp
//
//  Created by Apple on 14/12/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit
import SwiftEventBus
import PhotoSlider

class FeedProductViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoSliderDelegate {

    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var likeImgBtn: UIButton!
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyNowBtn: UIButton!
    @IBOutlet weak var chatNowBtn: UIButton!
    @IBOutlet weak var likeCountTxt: UIButton!
    @IBOutlet weak var detailTableView: UITableView!
    var lcontentSize = CGFloat(0.0)
    var productModel: PostModel = PostModel()
    var myDate: NSDate = NSDate()
    //var conversations: [ConversationVM] = []
    
    var likeFlag: Bool = false
    
    var productInfo: [PostCatModel] = []
    var noOfComments: Int = 0
    var items: [CommentModel] = [] //comment items
    var category: CategoryModel?
    var customDate: NSDate = NSDate()
    //var comments : [String]? = []
    
    var collectionView:UICollectionView!
    
    var images: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NSThread.sleepForTimeInterval(0.3)
        setSizesForFilterButtons()
        self.detailTableView.separatorColor = UIColor.whiteColor()
        self.detailTableView.estimatedRowHeight = 300.0
        self.detailTableView.rowHeight = UITableViewAutomaticDimension
        
        self.detailTableView.setNeedsLayout()
        self.detailTableView.layoutIfNeeded()
        self.detailTableView.reloadData()
        self.detailTableView.translatesAutoresizingMaskIntoConstraints = true
        ViewUtil.showActivityLoading(self.activityLoading)
        SwiftEventBus.onMainThread(self, name: "productDetailsReceivedSuccess") { result in
            // UI thread
            let resultDto: [PostCatModel] = result.object as! [PostCatModel]
            self.handleGetProductDetailsSuccess(resultDto)
        }
        ApiController.instance.getProductDetails(String(Int(productModel.id)))
    }
    
    override func viewDidAppear(animated: Bool) {
        self.myDate = NSDate()
        //self.conversations = []
        
        //ApiController.instance.getConversation()
        
        if (productModel.numLikes == 0) {
            self.likeCountTxt.setTitle("Like", forState: UIControlState.Normal)
        } else {
            self.likeCountTxt.setTitle(String(self.productModel.numLikes), forState: UIControlState.Normal)
        }
        
        if(productModel.isLiked == false){
            self.likeImgBtn.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = false
        } else {
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
            if indexPath.row == items.count {
                cell.btnPostComments.tag = indexPath.row
                cell.btnPostComments.addTarget(self, action: "PostComments:", forControlEvents: UIControlEvents.TouchUpInside)
                ImageUtil.displayButtonRoundBorder(cell.btnPostComments)
                cell.btnPostComments.layer.borderColor = UIColor.lightGrayColor().CGColor
                
                cell.commentTxt.layer.cornerRadius = 15.0
                cell.commentTxt.layer.masksToBounds = true
                
            } else {
                let comment:CommentModel = self.items[indexPath.row] 
                cell.lblComments.text = comment.body
                cell.postedUserName.text = comment.ownerName
                cell.btnDeleteComments.tag = indexPath.row
                
                cell.postedTime.text = NSDate(timeIntervalSince1970:Double(comment.createdDate) / 1000.0).timeAgo
                if (comment.ownerId == UserInfoCache.getUser().id) {
                    cell.btnDeleteComments.hidden = false
                } else {
                    cell.btnDeleteComments.hidden = true
                }
                ImageUtil.displayThumbnailProfileImage(self.items[indexPath.row].ownerId, imageView: cell.postedUserImg)
                cell.btnDeleteComments.addTarget(self, action: "DeleteComments:", forControlEvents: UIControlEvents.TouchUpInside)
                
                let time = comment.createdDate
                cell.postedTime.text = NSDate(timeIntervalSince1970:Double(time) / 1000.0).timeAgo
                
            }
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseidentifier, forIndexPath: indexPath)
                as!  DetailsTableViewCell
            
            switch indexPath.section {
            case 0:
                
                for i in 0...self.productModel.images.count - 1 {
                    self.images.append(String(self.productModel.images[i]))
                }
                self.collectionView = cell.viewWithTag(1) as! UICollectionView
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                cell.soldImage.hidden = !self.productModel.sold
                
            case 1:
                cell.contentMode = UIViewContentMode.Redraw
                cell.sizeToFit()
                if (self.productInfo.count > 0) {
                    cell.productDesc.text = self.productInfo[0].body
                    cell.productDesc.numberOfLines = 0
                    cell.productDesc.sizeToFit()
                    self.lcontentSize = cell.productDesc.frame.size.height
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
                    cell.prodTimerCount.text = NSDate(timeIntervalSince1970:Double(self.productInfo[0].createdDate) / 1000.0).timeAgo
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
        case 0: return ViewUtil.getScreenWidth(self.view)
        case 1:
            if (self.productInfo.count > 0) {
                return CGFloat(220.0) + self.lcontentSize
            }
            return CGFloat(220.0)
        case 2:
            return CGFloat(95.0)
        case 3:
            return CGFloat(50.0)
        default:
            return UITableViewAutomaticDimension
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //on click of User section show the User profile screen.
        if (indexPath.section == 2) {
            let vController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
            vController.userId = self.productInfo[0].ownerId
            ViewUtil.resetBackButton(self.navigationItem)
            self.navigationController?.pushViewController(vController, animated: true)
        }
    }
    
    //MARK: Button Press Events
    func DeleteComments(button: UIButton){
        ApiController.instance.deleteComment(self.items[button.tag].id)
        items.removeAtIndex(button.tag)
        //self.detailTableView.reloadData()
        detailTableView.contentInset =  UIEdgeInsetsZero
        
        self.noOfComments--
        self.detailTableView.reloadData()
        self.view.makeToast(message: "Comment Deleted Successfully", duration: 1, position: HRToastPositionCenter)
    }
    
    func PostComments(button: UIButton){
        let cell: MessageTableViewCell = button.superview!.superview as! MessageTableViewCell
        let _nComment = CommentModel()
        _nComment.ownerId = UserInfoCache.getUser().id
        _nComment.body = cell.commentTxt.text!
        _nComment.ownerName = UserInfoCache.getUser().displayName
        _nComment.deviceType = "iOS"
        _nComment.createdDate = Int(NSDate().timeIntervalSince1970)
        _nComment.id = -1
        ApiController.instance.postComment(String(Int(productModel.id)), comment: cell.commentTxt.text!)
        
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
           ApiController.instance.likePost(String(Int(productModel.id)))
            self.likeCountTxt.setTitle(String(self.productModel.numLikes), forState: UIControlState.Normal)
            
        } else {
            self.productModel.numLikes++
            self.productModel.isLiked = true
            self.likeImgBtn.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            ApiController.instance.unlikePost(String(Int(productModel.id)))
            self.likeCountTxt.setTitle(String(self.productModel.numLikes), forState: UIControlState.Normal)
            
        }
    }
    
    /*func handleConversation(conversation: [ConversationVM]) {
        self.conversations = conversation
        //let time = (self.conversations.last?.lastMessageDate)! / 1000
        //let date = NSDate(timeIntervalSinceNow: NSTimeInterval(time))
    }*/
    
    func handleGetProductDetailsSuccess(result: [PostCatModel]) {
        self.items.removeAll()
        if (result.count > 0) {
            self.productInfo.append(result[0])
            
            for comment in self.productInfo[0].latestComments {
                self.items.append(comment)
            }
            self.noOfComments = self.items.count
        }
        
        self.detailTableView.reloadData()
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    @IBAction func onSelectCategory(sender: AnyObject) {
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("CategoryFeedViewController") as! CategoryFeedViewController
        
        vController.selCategory = CategoryCache.getCategoryById(self.productInfo[0].categoryId)
        self.tabBarController!.tabBar.hidden = true
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController, animated: true)
    }
    @IBAction func onClickViewShop(sender: AnyObject) {
        
            let vController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
            vController.userId = self.productInfo[0].ownerId
            ViewUtil.resetBackButton(self.navigationItem)
            self.navigationController?.pushViewController(vController, animated: true)
        
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
        ImageUtil.displayOriginalPostImage(Int(self.images[indexPath.row])!, imageView: imageView)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: - PhotoSliderDelegate
    
    func photoSliderControllerWillDismiss(viewController: PhotoSlider.ViewController) {
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        
        let indexPath = NSIndexPath(forItem: viewController.currentPage, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
    }
}
