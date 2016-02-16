//
//  FollowingFeedViewController.swift
//  Baby Box
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import UIKit
import SwiftEventBus
import Kingfisher

class FollowingFeedViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var followingTips: UIView!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    
    var feedLoader: FeedLoader? = nil
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var reuseIdentifier = "CellType1"
    var isHeightSet: Bool = false
    
    func reloadDataToView() {
        self.activityLoading.stopAnimating()
        self.uiCollectionView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedLoader = FeedLoader(feedType: FeedFilter.FeedType.HOME_FOLLOWING, reloadDataToView: reloadDataToView)
        feedLoader!.reloadFeedItems()
        
        if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.HOME_FOLLOWING_TIPS)) {
            self.followingTips.hidden = false
            SharedPreferencesUtil.getInstance().setScreenViewed(SharedPreferencesUtil.Screen.HOME_FOLLOWING_TIPS)
        } else {
            self.followingTips.hidden = true
            self.topSpaceConstraint.constant = 5
        }
        
        setCollectionViewSizesInsets()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 5
        uiCollectionView.collectionViewLayout = flowLayout
    }
    
    @IBAction func onCloseTips(sender: AnyObject) {
        self.followingTips.hidden = true
        self.topSpaceConstraint.constant = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedLoader!.size()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedProductCollectionViewCell
            
        cell.likeImageIns.tag = indexPath.item

        let feedItem = feedLoader!.getItem(indexPath.row)
        if (feedItem.hasImage) {
            ImageUtil.displayPostImage(feedItem.images[0], imageView: cell.prodImageView)
        }
        
        cell.soldImage.hidden = !feedItem.sold
        //cell.likeCount.text = String(post.numLikes)
        cell.likeCountIns.setTitle(String(feedItem.numLikes), forState: UIControlState.Normal)
        if (!feedItem.isLiked) {
            cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
        } else {
            cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
        }
        cell.title.text = feedItem.title
            
        cell.productPrice.text = "\(constants.currencySymbol) \(String(stringInterpolationSegment: Int(feedItem.price)))"
            
        if (feedItem.originalPrice != 0 && feedItem.originalPrice != -1 && feedItem.originalPrice != Int(feedItem.price)) {
            let attrString = NSAttributedString(string: "\(constants.currencySymbol) \(String(stringInterpolationSegment:Int(feedItem.originalPrice)))", attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
                cell.originalPrice.attributedText = attrString
        }  else {
            cell.originalPrice.attributedText = NSAttributedString(string: "")
        }
        
        cell.likeImageIns.addTarget(self, action: "onLikeBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
            
        cell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
        cell.layer.borderWidth = 1
        
        cell.userCircleImg.layer.borderColor = UIColor.whiteColor().CGColor
        cell.userCircleImg.layer.borderWidth = CGFloat(1.0)
        ImageUtil.displayThumbnailProfileImage(feedItem.ownerId, imageView: cell.userCircleImg)
        /*ImageUtil.imageUtil.setCircularImgStyle(cell.userCircleImg)
        cell.userCircleImg.layer.borderColor = UIColor.whiteColor().CGColor
        cell.userCircleImg.layer.borderWidth = CGFloat(1.0)
                
        let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(Int(post.ownerId))
        let imageUrl  = NSURL(string: imagePath);
                
        dispatch_async(dispatch_get_main_queue(), {
            cell.userCircleImg.kf_setImageWithURL(imageUrl!)
        })*/
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("FeedProductViewController") as! FeedProductViewController
        let feedItem = feedLoader!.getItem(indexPath.row)
        vController.productModel = feedItem
        ApiControlller.apiController.getProductDetails(String(Int(feedItem.id)))
        self.tabBarController!.tabBar.hidden = true
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let _ = collectionViewCellSize {
            return collectionViewCellSize!
        }
        return CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        let velocity: CGFloat = scrollView.panGestureRecognizer.velocityInView(scrollView).y
        
        if (velocity > 0) {
            UIView.animateWithDuration(0.5, animations: {
                self.tabBarController?.tabBar.hidden = false
                self.hidesBottomBarWhenPushed = false
                
                if (self.isHeightSet) {
                    let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
                    self.view.frame.size.height = self.view.frame.size.height - tabBarHeight
                    self.isHeightSet = false
                }
            })
        } else if (velocity < 0) {
            self.tabBarController?.tabBar.hidden = true
            self.hidesBottomBarWhenPushed = false
            if (!self.isHeightSet) {
                let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
                self.view.frame.size.height = self.view.frame.size.height + tabBarHeight
                self.isHeightSet = true
            }
        } else {
            NSLog("Can't determine direction as velocity is 0")
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - constants.prodImgLoadThresold){
            feedLoader?.loadMoreFeedItems()
        }
    }
    
    /*func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.enableBottonToolBar()
    }*/
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = ImageUtil.imageUtil.getProductItemCellSize(self.view.bounds.width)
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FeedProductCollectionViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!

        let feedItem = feedLoader!.getItem(indexPath.row)
        //TODO - logic here require if user has already liked the product...
        if (feedItem.isLiked) {
            feedItem.numLikes--
            feedItem.isLiked = false
            cell.likeCountIns.setTitle(String(feedItem.numLikes), forState: UIControlState.Normal)
            cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            ApiControlller.apiController.unlikePost(String(feedItem.id))
        } else {
            feedItem.numLikes++
            feedItem.isLiked = true
            cell.likeCountIns.setTitle(String(feedItem.numLikes), forState: UIControlState.Normal)
            cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            ApiControlller.apiController.likePost(String(feedItem.id))
        }
    }
    
}