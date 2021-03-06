//
//  ViewController.swift
//
//
//  Created by Apple on 11/12/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit
import AMScrollingNavbar
import SwiftEventBus
import Kingfisher

class HomeFeedViewController: CustomNavigationController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    
    var feedLoader: FeedLoader? = nil
    var feedViewAdapter: FeedViewAdapter? = nil
    
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var lastContentOffset: CGFloat = 0
    var reuseIdentifier = "CellType1"
    var currentIndex: NSIndexPath?
    var categories : [CategoryVM] = []
    
    var vController: ProductViewController?
    var featuredItems: [FeaturedItemVM]?
    
    var bannerImages: [String] = []
    var bannerCollectionView: UICollectionView?
    var pageControl: UIPageControl?
    var currentBannerPage: Int?
    var homeBannerHeight: NSLayoutConstraint?
    
    func reloadDataToView() {
        self.categories = CategoryCache.categories
        self.uiCollectionView.reloadData()
        self.lastContentOffset = 0
    }
    
    func onSuccessGetCategories(categories: [CategoryVM]) {
        reloadDataToView()
    }
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
        NotificationCounter.refresh(onSuccessRefreshNotifications, failureCallback: onFailureRefreshNotifications)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.alpha = CGFloat(Constants.MAIN_BOTTOM_BAR_ALPHA)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(uiCollectionView, delay: 50.0)
            navigationController.scrollingNavbarDelegate = self
        }
        
        if (currentIndex != nil && vController?.feedItem != nil) {
            let item = vController?.feedItem
            feedLoader?.setItem(currentIndex!.row, item: item!)
            self.uiCollectionView.reloadItemsAtIndexPaths([currentIndex!])
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ViewUtil.appOpenByNotification {
            ViewUtil.handleAppRedirection(self)
        } else if UrlUtil.isSellerDeepLink || UrlUtil.isProductDeepLink {
            UrlUtil.handleDeepLinkRedirection(self, successCallback: onSuccessGetUserByDisplayName, failureCallback: onFailedGetUserByDisplayName)
        }
        
        feedLoader = FeedLoader(feedType: FeedFilter.FeedType.HOME_EXPLORE, reloadDataToView: reloadDataToView)
        feedLoader!.setActivityIndicator(activityLoading)
        feedLoader!.reloadFeedItems()
        
        feedViewAdapter = FeedViewAdapter(collectionView: uiCollectionView)
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        self.uiCollectionView.registerClass(HomeReusableView.self, forSupplementaryViewOfKind: "CategoryHeaderView", withReuseIdentifier: "HeaderView")
        
        self.uiCollectionView.collectionViewLayout = FeedViewAdapter.getFeedViewFlowLayout(self)
        
        self.uiCollectionView!.alwaysBounceVertical = true
        self.uiCollectionView!.backgroundColor = Color.FEED_BG
        
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            ApiFacade.getHomeSliderFeaturedItems(self!.onSuccessGetHomeFeaturedItems, failureCallback: self!.onFailureGetHomeFeaturedItems)
            CategoryCache.refresh(self!.onSuccessGetCategories, failureCallback: nil)
            self!.feedLoader?.reloadFeedItems()
            })
        
        ApiFacade.getHomeSliderFeaturedItems(onSuccessGetHomeFeaturedItems, failureCallback: onFailureGetHomeFeaturedItems)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.bannerCollectionView {
            return self.bannerImages.count
        }
        var count = 0
        if (collectionView.tag == 2) {
            count = self.categories.count
        } else {
            count = feedLoader!.size()
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == self.bannerCollectionView {
            let cell = self.bannerCollectionView?.dequeueReusableCellWithReuseIdentifier("homeBannerCell", forIndexPath: indexPath) as! ImageCollectionViewCell
            let imageView = cell.imageView
            
            ImageUtil.displayFeaturedItemImage(self.bannerImages[indexPath.row], imageView: imageView)
            
            cell.pageControl.numberOfPages = self.bannerImages.count
            cell.pageControl.currentPage = indexPath.row
            cell.pageControl.hidesForSinglePage = true
            
            if self.pageControl == nil {
                self.pageControl = cell.pageControl
                self.currentBannerPage = indexPath.row
            }
            return cell
        }
        
        if (collectionView.tag == 2){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("staticCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
            let categoryVM = self.categories[indexPath.row]
            let imagePath = categoryVM.icon
            let imageUrl  = NSURL(string: imagePath)
            cell.categoryIcon.kf_setImageWithURL(imageUrl!)
            cell.categoryName.text = categoryVM.name
            
            cell.layer.borderColor = Color.FEED_ITEM_BORDER.CGColor
            cell.layer.borderWidth = 0.5
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = cell.bounds
            gradientLayer.locations = [0.0, 1.0]
            
            gradientLayer.colors = [
                UIColor(white: 0, alpha: 0.0).CGColor,
                UIColor(white: 0, alpha: 0.4).CGColor,
                Color.LIGHT_GRAY.CGColor
            ]
            cell.categoryIcon.layer.sublayers = nil
            cell.categoryIcon.layer.insertSublayer(gradientLayer, atIndex: 0)
            
            return cell
        } else {
            let feedItem = feedLoader!.getItem(indexPath.row)
            if feedItem.id == -1 {
                //this mean there are no results.... hence show no result text
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoItemsToolTip", forIndexPath: indexPath) as! TooltipViewCell
                return feedViewAdapter!.bindNoItemToolTip(cell, feedType: (self.feedLoader?.feedType)!)
            }
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedProductCollectionViewCell
            //let feedItem = feedLoader!.getItem(indexPath.row)
            return feedViewAdapter!.bindViewCell(cell, feedItem: feedItem, index: indexPath.item)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.bannerCollectionView {
            ViewUtil.handleFeaturedItemAction(self, featuredItem: self.featuredItems![indexPath.row])
        } else {
            if (collectionView.tag == 2){
                self.currentIndex = indexPath
                self.performSegueWithIdentifier("categoryscreen", sender: nil)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        if (kind == UICollectionElementKindSectionHeader && self.uiCollectionView == collectionView) {
            let headerView : HomeReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! HomeReusableView
            headerView.headerViewCollection.reloadData()
            
            self.bannerCollectionView = headerView.homeBannerView.subviews[0] as? UICollectionView
            self.bannerCollectionView?.dataSource = self
            self.bannerCollectionView?.delegate = self
            self.homeBannerHeight = headerView.bannerHeight
            //self.homeBannerHeight?.constant = 0
            reusableView = headerView
        }
        
        return reusableView!
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if collectionView == self.bannerCollectionView {
            return CGSizeMake(self.view.bounds.width, self.view.bounds.width / Constants.HOME_BANNER_WIDTH_HEIGHT_RATIO)
        }
        
        if (collectionView.tag == 2) {
            if let _ = collectionViewTopCellSize {
                return collectionViewTopCellSize!
            }
        } else {
            
            if self.feedLoader?.feedItems.count == 1 {
                if self.feedLoader?.feedItems[0].id == -1 {
                    return FeedViewAdapter.getNoFeedItemCellSize(self.view.bounds.width)
                }
            }
            
            if let _ = collectionViewCellSize {
                return collectionViewCellSize!
            }
        }
        return CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == self.bannerCollectionView {
            return CGSizeZero
        }
        
        if collectionView.tag == 2 {
            return CGSizeZero
        } else {
            let availableWidthForCells: CGFloat = self.view.bounds.width - Constants.HOME_HEADER_ITEMS_MARGIN_TOTAL
            let cellWidth: CGFloat = availableWidthForCells / 3
            let ht = cellWidth * CGFloat(Int(self.categories.count / 3))
            let extraMargin = CGFloat(60)
            if self.bannerImages.isEmpty {
                return CGSizeMake(self.view.frame.width, ht + extraMargin)
            } else {
                let bannerHeight = self.view.bounds.width / Constants.HOME_BANNER_WIDTH_HEIGHT_RATIO
                return CGSizeMake(self.view.frame.width, ht + bannerHeight + extraMargin)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "categoryscreen") {
            return true
        } else if (identifier == "productScreen") {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "categoryscreen") {
            let vController = segue.destinationViewController as! CategoryFeedViewController
            vController.selCategory = self.categories[self.currentIndex!.row]
            vController.hidesBottomBarWhenPushed = true
        } else if (segue.identifier == "productScreen") {
            let cell = sender as! FeedProductCollectionViewCell
            let indexPath = self.uiCollectionView!.indexPathForCell(cell)
            let feedItem = feedLoader!.getItem(indexPath!.row)
            self.currentIndex = indexPath
            vController = segue.destinationViewController as? ProductViewController
            vController!.feedItem = feedItem
            vController!.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == bannerCollectionView {
            return
        }
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            feedLoader!.loadMoreFeedItems()
        }
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        let availableWidthForCells: CGFloat = self.view.bounds.width - Constants.HOME_HEADER_ITEMS_MARGIN_TOTAL
        let cellWidth: CGFloat = availableWidthForCells / 3
        collectionViewTopCellSize = CGSizeMake(cellWidth, cellWidth)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = FeedViewAdapter.getFeedItemCellSize(self.view.bounds.width)
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FeedProductCollectionViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        let feedItem = feedLoader!.getItem(indexPath.row)
        
        feedViewAdapter!.onLikeBtnClick(cell, feedItem: feedItem)
    }
    
    func onSuccessRefreshNotifications(notifcationCounter: NotificationCounterVM) {
        ViewUtil.refreshNotifications((self.tabBarController?.tabBar)!, navigationItem: self.navigationItem)
    }
    
    func onFailureRefreshNotifications(message: String) {
        NSLog(message)
    }
    
    func onSuccessGetUserByDisplayName(userVM: UserVM) -> Void {
        //get the userid and redirect to profile page....
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = userVM.id
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    func onFailedGetUserByDisplayName(error: String) {
        //do nothing.
    }
    
    func onSuccessGetHomeFeaturedItems(featuredItems: [FeaturedItemVM]) {
        self.featuredItems?.removeAll()
        self.featuredItems = featuredItems
        if featuredItems.count > 0 {
            for i in 0...(self.featuredItems?.count)! - 1 {
                self.bannerImages.append(String(self.featuredItems![i].image))
            }
            _ = NSTimer.scheduledTimerWithTimeInterval(Constants.BANNER_REFRESH_TIME_INTERVAL, target: self, selector: "scrollHomeBanner", userInfo: nil, repeats: true)
            //self.homeBannerHeight?.constant = Constants.HOME_BANNER_VIEW_HEIGHT
            self.bannerCollectionView?.reloadData()
            //self.uiCollectionView.reloadData()
        }
    }
    
    func onFailureGetHomeFeaturedItems(message: String) {
        NSLog("Error getting home slider featured items")
    }
    
    func scrollHomeBanner() {
        if self.pageControl != nil {
            let indexPath = NSIndexPath(forRow: self.currentBannerPage!, inSection: 0)
            self.pageControl?.currentPage = self.currentBannerPage!
            self.bannerCollectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: true)
            self.currentBannerPage! = self.currentBannerPage! + 1
            if self.currentBannerPage == self.bannerImages.count {
                self.currentBannerPage = 0
            }
        }
    }
}

