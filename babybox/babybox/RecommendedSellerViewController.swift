//
//  SellerRecommendationViewController.swift
//  babybox
//
//  Created by Mac on 29/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import PullToRefreshSwift

class RecommendedSellerViewController: UIViewController {

    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!

    var parentNavigationController : UINavigationController?
    var collectionViewCellSize : CGSize?
    var recommendedSellers: [SellerVM] = []
    var offSet: Int64 = 0
    var lastContentOffset: CGFloat = 0
    var loading: Bool = false
    var loadedAll: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uiCollectionView.setNeedsLayout()
        self.uiCollectionView.layoutIfNeeded()
        
        self.setCollectionViewSizesInsets()
        
        SwiftEventBus.onMainThread(self, name: "recommendedSellerSuccess") { result in
            let sellers = result.object as! [SellerVM]
            self.handleRecommendedSeller(sellers)
        }
        
        SwiftEventBus.onMainThread(self, name: "recommendedSellerFailed") { result in
            self.view.makeToast(message: "Error getting Recommended Seller!")
        }
        
        ViewUtil.showActivityLoading(self.activityLoading)
        
        ApiController.instance.getRecommendedSellersFeed(offSet)
        
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            self?.reloadSellers()
        })
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    override func viewDidDisappear(animated: Bool) {
        //self.recommendedSellers.removeAll()
        //self.uiCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return recommendedSellers.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("recommendedSellerViewCell", forIndexPath: indexPath) as! RecommendedSellerViewCell
        
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
    
        let item = self.recommendedSellers[indexPath.row]
        cell.contentMode = UIViewContentMode.Redraw
        cell.sizeToFit()
        cell.sellerName.text = String(item.displayName)
        cell.followers.text = String(item.numFollowers)
        cell.aboutMe.numberOfLines = 3
        cell.aboutMe.text = item.aboutMe
        cell.aboutMe.sizeToFit()
        ImageUtil.displayThumbnailProfileImage(self.recommendedSellers[indexPath.row].id, imageView: cell.sellerImg)
        
        // follow
        if (item.isFollowing) {
            ViewUtil.selectFollowButtonStyleLite(cell.followBtn)
        } else {
            ViewUtil.unselectFollowButtonStyleLite(cell.followBtn)
        }
        //ImageUtil.displayCornerView(cell.followBtn)
        
        self.setSizesFoProdImgs(cell)
        
        var imageHolders: [UIImageView] = []
        imageHolders.append(cell.postImg1)
        imageHolders.append(cell.postImg2)
        imageHolders.append(cell.postImg3)
        imageHolders.append(cell.postImg4)
        
        let posts = item.posts
        for i in 0...posts.count - 1 {
            ImageUtil.displayOriginalPostImage(posts[i].images[0], imageView: imageHolders[i])
            if (item.numMoreProducts > 0 && i == posts.count - 1) {
                cell.moreText.setTitle("+" + String(item.numMoreProducts) + " Products", forState: UIControlState.Normal)
                cell.moreText.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell.moreText.titleLabel?.numberOfLines = 2 //if you want unlimited number of lines put 0
                cell.moreText.titleLabel?.textAlignment = NSTextAlignment.Center
                cell.moreText.hidden = false
                imageHolders[i].alpha = 0.50
                cell.moreText.alpha = 1.0
            } else {
                cell.moreText.hidden = true
            }
        }
        
        if (UserInfoCache.getUser()!.id == item.id) {
            cell.followBtn.hidden = true
        } else {
            cell.followBtn.hidden = false
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        moveToUserProfile(indexPath.row)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        /**this code is used to dynamically specify the height to CellView without this code
        contents get overlapped*/
        let dummyLbl = UILabel(frame: CGRect(x: 0,y: 0, width: self.view.bounds.width, height: 0))
        dummyLbl.numberOfLines = 2
        dummyLbl.text = self.recommendedSellers[indexPath.row].aboutMe
        dummyLbl.sizeToFit()
        
        let availableWidthForButtons:CGFloat = self.view.bounds.width - 60
        let buttonWidth :CGFloat = availableWidthForButtons / 4
        
        return CGSizeMake(self.view.bounds.width, CGFloat(60) + dummyLbl.bounds.height + buttonWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                ViewUtil.showActivityLoading(self.activityLoading)
                loading = true
                var feedOffset: Int64 = 0
                if (!self.recommendedSellers.isEmpty) {
                    feedOffset = Int64(self.recommendedSellers[self.recommendedSellers.count-1].offset)
                }
                
                ApiController.instance.getRecommendedSellersFeed(feedOffset)
            }
        }
    }
    
    @IBAction func onClickSeller(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! RecommendedSellerViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        moveToUserProfile(indexPath.row)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = CGSizeMake(self.view.bounds.width, 125)
    }
    
    func handleRecommendedSeller(sellers: [SellerVM]) {
        if (!sellers.isEmpty) {
            if (self.recommendedSellers.count == 0) {
                self.recommendedSellers = sellers
            } else {
                self.recommendedSellers.appendContentsOf(sellers)
            }
            self.uiCollectionView.reloadData()
        } else {
            loadedAll = true
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func moveToUserProfile(index: Int) {
        ViewUtil.resetBackButton(self.navigationItem)
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = self.recommendedSellers[index].id
        vController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    func setSizesFoProdImgs(cell: RecommendedSellerViewCell) {
        
        let availableWidthForButtons:CGFloat = self.view.bounds.width - 60
        let buttonWidth :CGFloat = availableWidthForButtons / 4
        cell.prodImgWidth.constant = buttonWidth
        cell.prodImgHt.constant = buttonWidth
    }
    
    @IBAction func onClickMoreProducs(sender: AnyObject) {
        //
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! RecommendedSellerViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        moveToUserProfile(indexPath.row)
    }
    
    @IBAction func onClickPostImg1(sender: AnyObject) {
        moveToProductView(sender, index: 0)
    }
    
    @IBAction func onClickPostImg2(sender: AnyObject) {
        moveToProductView(sender, index: 1)
    }
    @IBAction func onClickPostImg3(sender: AnyObject) {
        moveToProductView(sender, index: 2)
    }
    
    @IBAction func onClickPostImg4(sender: AnyObject) {
        moveToProductView(sender, index: 3)
    }
    
    func moveToProductView(sender: AnyObject, index: Int) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! RecommendedSellerViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("FeedProductViewController") as! FeedProductViewController
        let feedItem = self.recommendedSellers[indexPath.row]
        vController.feedItem = feedItem.posts[index]
        vController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    @IBAction func onClickFollowUnfollow(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! RecommendedSellerViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        let item = self.recommendedSellers[indexPath.row]
        if (item.isFollowing) {
            unfollow(item, cell: cell)
        } else {
            follow(item, cell: cell)
        }
        
    }
    
    func follow(user: UserVMLite, cell: RecommendedSellerViewCell) {
        
        ApiController.instance.followUser(user.id)
        user.isFollowing = true
        ViewUtil.selectFollowButtonStyleLite(cell.followBtn)
    }
    
    func unfollow(user: UserVMLite, cell: RecommendedSellerViewCell){
        ApiController.instance.unfollowUser(user.id)
        user.isFollowing = false
        ViewUtil.unselectFollowButtonStyleLite(cell.followBtn)
    }
    
    func clearSellers() {
    
        self.loading = false
        self.loadedAll = false
        self.recommendedSellers.removeAll()
        self.recommendedSellers = []
        self.uiCollectionView.reloadData()
        self.offSet = 0
    
    }
    
    func reloadSellers() {
        clearSellers()
        ApiController.instance.getRecommendedSellersFeed(offSet)
        self.loading = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "spuserprofile") {
            let button = sender as! UIButton
            let view = button.superview!
            let cell = view.superview! as! RecommendedSellerViewCell
            let indexPath = self.uiCollectionView.indexPathForCell(cell)!
            let userItem = self.recommendedSellers[indexPath.row]
            let vc = segue.destinationViewController as! UserProfileFeedViewController
            vc.hidesBottomBarWhenPushed = true
            vc.userId = userItem.id
        }
    }
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "spuserprofile") {
            return true
        }
        return false
    }
    
}
