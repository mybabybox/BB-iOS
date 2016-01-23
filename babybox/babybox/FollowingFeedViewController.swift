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
    var apiController: ApiControlller = ApiControlller()
    var products: [PostModel] = []
    var pageOffSet: Int64 = 0
    var currentIndex = 0
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var reuseIdentifier = "CellType1"
    var loadingProducts: Bool = false
    var isHeightSet: Bool = false
    
    override func viewDidAppear(animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        apiController.getHomeEollowingFeeds(0)
        
        if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.HOME_FOLLOWING_TIPS)) {
            self.followingTips.hidden = false
            SharedPreferencesUtil.getInstance().setScreenViewed(SharedPreferencesUtil.Screen.HOME_FOLLOWING_TIPS)
        } else {
            self.followingTips.hidden = true
            self.topSpaceConstraint.constant = 5
        }
        
        SwiftEventBus.onMainThread(self, name: "feedReceivedSuccess") { result in
            // UI thread
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleGetAllProductsuccess(resultDto)
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
        return self.products.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CatProductCollectionViewCell
            
        cell.likeImageIns.tag = indexPath.item
            
        let post = self.products[indexPath.row]
        //need carosuel here.
        if (post.hasImage) {
            let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(post.images[0])
            let imageUrl  = NSURL(string: imagePath)
            cell.prodImageView.kf_setImageWithURL(imageUrl!)
        }
        cell.likeCount.text = String(post.numLikes)
        if (!post.isLiked) {
            cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
        } else {
            cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
        }
        cell.title.text = post.title
            
        cell.productPrice.text = "\(constants.currencySymbol) \(String(stringInterpolationSegment: Int(post.price)))"
            
        if (post.originalPrice != 0 && post.originalPrice != -1 && post.originalPrice != Int(post.price)) {
            let attrString = NSAttributedString(string: "\(constants.currencySymbol) \(String(stringInterpolationSegment:Int(post.originalPrice)))", attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
                cell.originalPrice.attributedText = attrString
        }
            
        cell.likeImageIns.addTarget(self, action: "onLikeBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
            
        cell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
        cell.layer.borderWidth = 1
        
        BabyboxUtils.babyBoxUtils.setCircularImgStyle(cell.userCircleImg)
        cell.userCircleImg.layer.borderColor = UIColor.whiteColor().CGColor
        cell.userCircleImg.layer.borderWidth = CGFloat(1.0)
                
        let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(Int(post.ownerId))
        let imageUrl  = NSURL(string: imagePath);
                
        dispatch_async(dispatch_get_main_queue(), {
            cell.userCircleImg.kf_setImageWithURL(imageUrl!)
        })
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.currentIndex = indexPath.row
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("ProductViewController") as! ProductDetailsViewController
        vController.productModel = self.products[self.currentIndex]
        apiController.getProductDetails(String(Int(self.products[self.currentIndex].id)))
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
    
    // MARK: Custom Implementation methods
    
    func handleGetAllProductsuccess(resultDto: [PostModel]) {
        if (!resultDto.isEmpty) {
            
            if (self.products.count == 0) {
                self.products = resultDto
                self.uiCollectionView.reloadData()
            } else {
                self.products.appendContentsOf(resultDto)
                self.uiCollectionView.reloadData()
            }
            self.pageOffSet = Int64(self.products[self.products.count-1].offset)
        }
        self.activityLoading.stopAnimating()
        self.loadingProducts = true
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        UIView.animateWithDuration(0.5, animations: {
            self.tabBarController?.tabBar.hidden = true
            self.hidesBottomBarWhenPushed = false
            if (!self.isHeightSet) {
                let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
                self.view.frame.size.height = self.view.frame.size.height + tabBarHeight
                self.isHeightSet = true
            }
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
                if (self.loadingProducts) {
                    self.apiController.getHomeEollowingFeeds(self.pageOffSet)
                    self.loadingProducts = false
                }
            }
        })
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.enableBottonToolBar()
    }
    
    func enableBottonToolBar() {
        UIView.animateWithDuration(0.5, animations: {
            self.tabBarController?.tabBar.hidden = false
            self.hidesBottomBarWhenPushed = false
            
            if (self.isHeightSet) {
                let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
                self.view.frame.size.height = self.view.frame.size.height - tabBarHeight
                self.isHeightSet = false
            }
        })
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = BabyboxUtils.babyBoxUtils.getProductItemCellSize(self.view.bounds.width)
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! CatProductCollectionViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)
        
        //TODO - logic here require if user has already liked the product...
        if (self.products[(indexPath?.row)!].isLiked) {
            self.products[(indexPath?.row)!].numLikes--
            cell.likeCount.text = String(self.products[(indexPath?.row)!].numLikes)
            self.products[(indexPath?.row)!].isLiked = false
            apiController.unlikePost(String(self.products[(indexPath?.row)!].id))
            button.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            
        } else {
            self.products[(indexPath?.row)!].isLiked = true
            self.products[(indexPath?.row)!].numLikes++
            cell.likeCount.text = String(self.products[(indexPath?.row)!].numLikes)
            apiController.likePost(String(self.products[(indexPath?.row)!].id))
            button.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            
        }
    }
    
}