//
//  ViewController.swift
//  
//
//  Created by Apple on 11/12/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit
import SwiftEventBus
import Kingfisher

class HomeFeedViewController: UIViewController, UIScrollViewDelegate {
    
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
    
    var categories : [CategoryModel] = []
    
    func reloadDataToView() {
        self.uiCollectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
        self.tabBarController?.tabBar.alpha = CGFloat(constants.MAIN_BOTTOM_BAR_ALPHA)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedSuccess") { result in
            let resultDto: [CategoryModel] = result.object as! [CategoryModel]
            self.handleGetCategoriesSuccess(resultDto)
        }
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        self.uiCollectionView.registerClass(HomeReusableView.self, forSupplementaryViewOfKind: "CategoryHeaderView", withReuseIdentifier: "HeaderView")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 5
        uiCollectionView.collectionViewLayout = flowLayout
        
        ApiController.instance.getAllCategories()
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
        var count = 0;
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
            cell.categoryName.text = categoryVM.name;
            
            cell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
            cell.layer.borderWidth = 1
                
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = cell.bounds
            gradientLayer.locations = [0.0, 1.0]
            
            gradientLayer.colors = [
                UIColor(white: 0, alpha: 0.0).CGColor,
                UIColor(white: 0, alpha: 0.2).CGColor,
                UIColor.lightGrayColor().CGColor
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
        self.tabBarController!.tabBar.hidden = true

        if (collectionView.tag == 2){
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("CategoryFeedViewController") as! CategoryFeedViewController
            vController.selCategory = self.categories[indexPath.row]
            self.navigationController?.pushViewController(vController, animated: true)
        } else {
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("FeedProductViewController") as! FeedProductViewController
            let feedItem = feedLoader!.getItem(indexPath.row)
            vController.productModel = feedItem
            self.navigationController?.pushViewController(vController, animated: true)
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
        
        if (collectionView.tag == 2){
            return CGSizeZero
        } else {
            let availableWidthForCells:CGFloat = self.view.bounds.width - 35
            let cellWidth :CGFloat = availableWidthForCells / 3
            let ht = cellWidth * CGFloat(Int(self.categories.count / 3))
            return CGSizeMake(self.view.frame.width, ht + 60)
        }
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
    func handleGetCategoriesSuccess(categories: [CategoryModel]) {
        self.categories = categories
        CategoryCache.setCategories(self.categories)
        self.uiCollectionView.reloadData()
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y + constants.SHOW_HIDE_BAR_SCROLL_DISTANCE) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else if (self.lastContentOffset < scrollView.contentOffset.y - constants.SHOW_HIDE_BAR_SCROLL_DISTANCE) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        self.lastContentOffset = scrollView.contentOffset.y
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - constants.FEED_LOAD_SCROLL_THRESHOLD {
            feedLoader!.loadMoreFeedItems()
        }
    }
        
    func setCollectionViewSizesInsetsForTopView() {
        let availableWidthForCells:CGFloat = self.view.bounds.width - 35
        let cellWidth :CGFloat = availableWidthForCells / 3
        collectionViewTopCellSize = CGSizeMake(cellWidth, cellWidth)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = ImageUtil.imageUtil.getProductItemCellSize(self.view.bounds.width)
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FeedProductCollectionViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        let feedItem = feedLoader!.getItem(indexPath.row)
        
        feedViewAdapter!.onLikeBtnClick(cell, feedItem: feedItem)
    }
}

