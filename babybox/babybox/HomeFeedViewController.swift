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

class HomeFeedViewController: CustomNavigationController {
    
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var exploreTip: UIView!
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
    //var notificationCounterVM: NotificationCounterVM? = nil
    
    func reloadDataToView() {
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
        
        if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.HOME_EXPLORE_TIPS)) {
            self.exploreTip.hidden = false
            SharedPreferencesUtil.getInstance().setScreenViewed(SharedPreferencesUtil.Screen.HOME_EXPLORE_TIPS)
        } else {
            self.exploreTip.hidden = true
            self.topSpaceConstraint.constant = 5
        }
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        self.uiCollectionView.registerClass(HomeReusableView.self, forSupplementaryViewOfKind: "CategoryHeaderView", withReuseIdentifier: "HeaderView")
        
        uiCollectionView.collectionViewLayout = feedViewAdapter!.getFeedViewFlowLayout(self)
        
        self.categories = CategoryCache.categories
        self.uiCollectionView!.alwaysBounceVertical = true
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            CategoryCache.refresh(self?.onSuccessGetCategories, failureCallback: nil)
            self!.feedLoader?.reloadFeedItems()
        })
    }
    
    @IBAction func onClicTipClose(sender: AnyObject) {
        self.exploreTip.hidden = true
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
        var count = 0
        if (collectionView.tag == 2) {
            count = self.categories.count
        } else {
            count = feedLoader!.size()
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedProductCollectionViewCell
            let feedItem = feedLoader!.getItem(indexPath.row)
            return feedViewAdapter!.bindViewCell(cell, feedItem: feedItem, index: indexPath.item)
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (collectionView.tag == 2){
            self.currentIndex = indexPath
            self.performSegueWithIdentifier("categoryscreen", sender: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView : HomeReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! HomeReusableView
            headerView.headerViewCollection.reloadData()
            reusableView = headerView
        }
        
        return reusableView!
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (collectionView.tag == 2) {
            if let _ = collectionViewTopCellSize {
                return collectionViewTopCellSize!
            }
        } else {
            if let _ = collectionViewCellSize {
                return collectionViewCellSize!
            }
        }
        return CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView.tag == 2 {
            return CGSizeZero
        } else {
            let availableWidthForCells: CGFloat = self.view.bounds.width - Constants.HOME_HEADER_ITEMS_MARGIN_TOTAL
            let cellWidth: CGFloat = availableWidthForCells / 3
            let ht = cellWidth * CGFloat(Int(self.categories.count / 3))
            return CGSizeMake(self.view.frame.width, ht + 60)
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
        collectionViewCellSize = feedViewAdapter!.getFeedItemCellSize(self.view.bounds.width)
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
    
}

