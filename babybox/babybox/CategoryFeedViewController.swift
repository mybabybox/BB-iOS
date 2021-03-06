//
//  CategoryFeedViewController.swift
//  Baby Box
//
//  Created by Mac on 20/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus
import Kingfisher

class CategoryFeedViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var feedLoader: FeedLoader? = nil
    var feedViewAdapter: FeedViewAdapter? = nil
    
    var isWidthSet = false
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var reuseIdentifier = "CellType1"
    var loadingProducts: Bool = false
    var selCategory: CategoryVM? = nil
    
    var vController: ProductViewController?
    var currentIndex: NSIndexPath?
    
    func reloadDataToView() {
        self.uiCollectionView.reloadData()
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
        if (currentIndex != nil) {
            let item = vController?.feedItem
            feedLoader?.setItem(currentIndex!.row, item: item!)
            self.uiCollectionView.reloadItemsAtIndexPaths([currentIndex!])
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedLoader = FeedLoader(feedType: FeedFilter.FeedType.CATEGORY_POPULAR, reloadDataToView: reloadDataToView)
        feedLoader!.setActivityIndicator(activityLoading)
        feedLoader!.reloadFeedItems(Int(self.selCategory!.id))
        
        feedViewAdapter = FeedViewAdapter(collectionView: uiCollectionView)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        uiCollectionView.collectionViewLayout = FeedViewAdapter.getFeedViewFlowLayout(self)
        
        let sellBtn: UIButton = UIButton()
        sellBtn.setImage(UIImage(named: "btn_sell"), forState: UIControlState.Normal)
        sellBtn.addTarget(self, action: "onClickSellBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        sellBtn.frame = CGRectMake(0, 0, 35, 35)
        let sellBarBtn = UIBarButtonItem(customView: sellBtn)
        
        self.navigationItem.rightBarButtonItems = [sellBarBtn]
        
        self.uiCollectionView!.alwaysBounceVertical = true
        self.uiCollectionView!.backgroundColor = Color.FEED_BG
        
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            self!.feedLoader?.reloadFeedItems(Int((self?.selCategory?.id)!))
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if (collectionView.tag == 2) {
            count = 1
        } else {
            count = feedLoader!.size()
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (collectionView.tag == 2) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("categoryCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
            
            cell.categoryName.text = self.selCategory?.name
            cell.layer.backgroundColor = Color.FEED_BG.CGColor
            
            let imagePath = (self.selCategory?.icon)!
            let imageUrl  = NSURL(string: imagePath)
            
            dispatch_async(dispatch_get_main_queue(), {
                cell.categoryIcon.kf_setImageWithURL(imageUrl!)
            })
            
            //Divide the width equally among buttons.. 
            if (!isWidthSet) {
                setSizesForFilterButtons(cell)
            }
            
            //Set button width and text color...
            self.setUnClickedBtnBackgroundAndText(cell.popularBtn)
            self.setUnClickedBtnBackgroundAndText(cell.newestBtn)
            self.setUnClickedBtnBackgroundAndText(cell.lowToHighBtn)
            self.setUnClickedBtnBackgroundAndText(cell.highToLow)
            
            switch feedLoader!.feedType {
                case FeedFilter.FeedType.CATEGORY_POPULAR:
                    self.setClickedBtnBackgroundAndText(cell.popularBtn)
                case FeedFilter.FeedType.CATEGORY_NEWEST:
                    self.setClickedBtnBackgroundAndText(cell.newestBtn)
                case FeedFilter.FeedType.CATEGORY_PRICE_LOW_HIGH:
                    self.setClickedBtnBackgroundAndText(cell.lowToHighBtn)
                case FeedFilter.FeedType.CATEGORY_PRICE_HIGH_LOW:
                    self.setClickedBtnBackgroundAndText(cell.highToLow)
                default: break
            }

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
        if (collectionView.tag == 2){
            
        } else {
            //self.performSegueWithIdentifier("gotoproductdetail", sender: nil)
            vController =  self.storyboard!.instantiateViewControllerWithIdentifier("ProductViewController") as? ProductViewController
            let feedItem = feedLoader!.getItem(indexPath.row)
            vController!.feedItem = feedItem
            vController!.category = self.selCategory
            self.currentIndex = indexPath
            ViewUtil.resetBackButton(self.navigationItem)
            self.navigationController?.pushViewController(vController!, animated: true)
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
        if (collectionView.tag == 2){
            return CGSizeZero
        } else {
            return CGSizeMake(self.view.frame.width, Constants.CATEGORY_HEADER_HEIGHT)
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
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            feedLoader!.loadMoreFeedItems(Int(self.selCategory!.id))
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, Constants.CATEGORY_HEADER_HEIGHT)
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
    
    @IBAction func onClickPopulated(sender: AnyObject) {
        ViewUtil.showActivityLoading(self.activityLoading)
        feedLoader!.setFeedType(FeedFilter.FeedType.CATEGORY_POPULAR)
        feedLoader!.reloadFeedItems(Int(self.selCategory!.id))
    }
    
    @IBAction func onClickNewest(sender: AnyObject) {
        ViewUtil.showActivityLoading(self.activityLoading)
        feedLoader!.setFeedType(FeedFilter.FeedType.CATEGORY_NEWEST)
        feedLoader!.reloadFeedItems(Int(self.selCategory!.id))    
    }
    
    @IBAction func onClickHighLow(sender: AnyObject) {
        ViewUtil.showActivityLoading(self.activityLoading)
        feedLoader!.setFeedType(FeedFilter.FeedType.CATEGORY_PRICE_HIGH_LOW)
        feedLoader!.reloadFeedItems(Int(self.selCategory!.id))
    }
    
    @IBAction func onClickLowHigh(sender: AnyObject) {
        ViewUtil.showActivityLoading(self.activityLoading)
        feedLoader!.setFeedType(FeedFilter.FeedType.CATEGORY_PRICE_LOW_HIGH)
        feedLoader!.reloadFeedItems(Int(self.selCategory!.id))
    }
    
    func setClickedBtnBackgroundAndText(sender: UIButton) {
        sender.backgroundColor = Color.PINK
        sender.setTitleColor(Color.WHITE, forState: UIControlState.Normal)
    }
    
    func setUnClickedBtnBackgroundAndText(sender: UIButton) {
        sender.backgroundColor = Color.WHITE
        sender.setTitleColor(Color.DARK_GRAY, forState: UIControlState.Normal)
    }
    
    func onClickSellBtn(sender: AnyObject?) {
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("NewProductViewController") as! NewProductViewController
        vController.selCategory = Int((selCategory?.id)!)
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    func setSizesForFilterButtons(cell: CategoryCollectionViewCell) {
        isWidthSet = true
        let availableWidthForButtons:CGFloat = self.view.bounds.width - 30
        let buttonWidth :CGFloat = availableWidthForButtons / 4
        cell.btnWidthConstraint.constant = buttonWidth
        cell.popularBtn.layer.borderColor = Color.LIGHT_GRAY.CGColor
        cell.popularBtn.layer.borderWidth = 0.5
        
        cell.newestBtn.layer.borderColor = Color.LIGHT_GRAY.CGColor
        cell.newestBtn.layer.borderWidth = 0.5
        
        cell.lowToHighBtn.layer.borderColor = Color.LIGHT_GRAY.CGColor
        cell.lowToHighBtn.layer.borderWidth = 0.5
        
        cell.highToLow.layer.borderColor = Color.LIGHT_GRAY.CGColor
        cell.highToLow.layer.borderWidth = 0.5
    }
}