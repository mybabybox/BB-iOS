//
//  SellerRecommendationViewController.swift
//  babybox
//
//  Created by Mac on 29/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class RecommendedSellerViewController: UIViewController {

    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    var collectionViewCellSize : CGSize?
    var recommendedSellers: [SellerVM] = []
    var offSet: Int64 = 0
    var lcontentSize = CGFloat(0.0)
    var lastContentOffset: CGFloat = 0
    var loading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCollectionViewSizesInsets()
        SwiftEventBus.onMainThread(self, name: "recommendedSellerSuccess") { result in
            let sellers = result.object as! [SellerVM]
            self.handleRecommendedSeller(sellers)
        }
        
        SwiftEventBus.onMainThread(self, name: "recommendedSellerFailed") { result in
            self.view.makeToast(message: "Error getting Recommended Seller!")
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
        self.navigationController?.navigationBar.hidden = false
        self.tabBarController?.tabBar.alpha = CGFloat(constants.MAIN_BOTTOM_BAR_ALPHA)
        ViewUtil.hideActivityLoading(self.activityLoading)
        
        ApiController.instance.getRecommendedSellersFeed(offSet)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = true
        self.recommendedSellers.removeAll()
        self.uiCollectionView.reloadData()
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
        
        let item = self.recommendedSellers[indexPath.row]
        cell.contentMode = UIViewContentMode.Redraw
        cell.sizeToFit()
        cell.sellerName.text = String(item.displayName)
        cell.followers.text = String(item.numFollowers)
        cell.aboutMe.numberOfLines = 0
        cell.aboutMe.sizeToFit()
        cell.aboutMe.text = item.aboutMe
        self.lcontentSize = cell.aboutMe.frame.size.height
        ImageUtil.displayThumbnailProfileImage(self.recommendedSellers[indexPath.row].id, imageView: cell.sellerImg)
        ImageUtil.displayCornerView(cell.followBtn)
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
                imageHolders[i].alpha = 0.25
                cell.moreText.alpha = 1.0
            } else {
                cell.moreText.hidden = true
            }
        }
        
        if (UserInfoCache.getUser().id == item.id) {
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
        //return collectionViewCellSize!
        return CGSizeMake(self.view.bounds.width, CGFloat(130))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        /*if (self.lastContentOffset > scrollView.contentOffset.y + constants.SHOW_HIDE_BAR_SCROLL_DISTANCE) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else if (self.lastContentOffset < scrollView.contentOffset.y - constants.SHOW_HIDE_BAR_SCROLL_DISTANCE) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        self.lastContentOffset = scrollView.contentOffset.y
        */
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loading) {
                loading = true
                var feedOffset: Int64 = 0
                if (!self.recommendedSellers.isEmpty) {
                    feedOffset = Int64(self.recommendedSellers[self.recommendedSellers.count-1].offset)
                }
                ApiController.instance.getRecommendedSellersFeed(offSet)
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
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func moveToUserProfile(index: Int) {
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = self.recommendedSellers[index].id
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    func setSizesFoProdImgs(cell: RecommendedSellerViewCell) {
        
        let availableWidthForButtons:CGFloat = self.view.bounds.width - 40
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
        self.navigationController?.pushViewController(vController, animated: true)
    }
}
