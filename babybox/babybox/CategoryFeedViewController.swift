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
    
    @IBOutlet weak var categoryTips: UIView!
    @IBOutlet weak var tipSection: NSLayoutConstraint!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var feedLoader: FeedLoader? = nil
    var isWidthSet = false
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var reuseIdentifier = "CellType1"
    var loadingProducts: Bool = false
    var selCategory: CategoryModel? = nil
    var txtWhiteColor = UIColor(red: CGFloat(255.0), green: CGFloat(255.0), blue: CGFloat(255.0), alpha: CGFloat(1.0))
    var txtPinkColor = ImageUtil.imageUtil.UIColorFromRGB(0xFF76A4)
    
    func reloadDataToView() {
        self.uiCollectionView.reloadData()
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewUtil.showActivityLoading(self.activityLoading)
        feedLoader = FeedLoader(feedType: FeedFilter.FeedType.CATEGORY_POPULAR, reloadDataToView: reloadDataToView)
        feedLoader!.reloadFeedItems(Int(self.selCategory!.id))
        
        if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.CATEGORY_TIPS)) {
            self.categoryTips.hidden = false
            SharedPreferencesUtil.getInstance().setScreenViewed(SharedPreferencesUtil.Screen.CATEGORY_TIPS)
        } else {
            self.categoryTips.hidden = true
            self.tipSection.constant = -5
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 5
        uiCollectionView.collectionViewLayout = flowLayout
        
        let sellBtn: UIButton = UIButton()
        sellBtn.setImage(UIImage(named: "btn_sell"), forState: UIControlState.Normal)
        sellBtn.addTarget(self, action: "onClickSellBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        sellBtn.frame = CGRectMake(0, 0, 35, 35)
        let sellBarBtn = UIBarButtonItem(customView: sellBtn)
        
        self.navigationItem.rightBarButtonItems = [sellBarBtn]
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
        var count = 0;
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
            let imagePath = (self.selCategory?.icon)!
            let imageUrl  = NSURL(string: imagePath)
            
            dispatch_async(dispatch_get_main_queue(), {
                cell.categoryIcon.kf_setImageWithURL(imageUrl!)
            });
            
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedProductCollectionViewCell
            
            cell.likeImageIns.tag = indexPath.item
            
            let feedItem = feedLoader!.getItem(indexPath.row)
            if (feedItem.hasImage) {
                ImageUtil.displayPostImage(feedItem.images[0], imageView: cell.prodImageView)
            }
            
            cell.soldImage.hidden = !feedItem.sold
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
            } else {
                cell.originalPrice.attributedText = NSAttributedString(string: "")
            }
            
            cell.likeImageIns.addTarget(self, action: "onLikeBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
            cell.layer.borderWidth = 1
            return cell
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (collectionView.tag == 2){
            
        } else {
            //self.performSegueWithIdentifier("gotoproductdetail", sender: nil)
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("FeedProductViewController") as! FeedProductViewController
            let feedItem = feedLoader!.getItem(indexPath.row)
            vController.productModel = feedItem
            vController.category = self.selCategory
            ApiControlller.apiController.getProductDetails(String(Int(feedItem.id)))
            self.tabBarController!.tabBar.hidden = true
            ViewUtil.resetBackButton(self.navigationItem)
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
                setCollectionViewSizesInsetsForTopView()
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
            return CGSizeMake(self.view.frame.width, 150)
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
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - constants.FEED_LOAD_SCROLL_THRESHOLD {
            ViewUtil.showActivityLoading(self.activityLoading)
	    feedLoader!.loadMoreFeedItems(Int(self.selCategory!.id))
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, 150)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = ImageUtil.imageUtil.getProductItemCellSize(self.view.bounds.width)
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FeedProductCollectionViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        
        //TODO - logic here require if user has already liked the product...
        let feedItem = feedLoader!.getItem(indexPath.row)
        if (feedItem.isLiked) {
            feedItem.isLiked = false
            feedItem.numLikes--
            cell.likeCountIns.setTitle(String(feedItem.numLikes), forState: UIControlState.Normal)
            cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            ApiControlller.apiController.unlikePost(String(feedItem.id))
        } else {
            feedItem.isLiked = true
            feedItem.numLikes++
            cell.likeCountIns.setTitle(String(feedItem.numLikes), forState: UIControlState.Normal)
            cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            ApiControlller.apiController.likePost(String(feedItem.id))
        }
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
    
    @IBAction func onClickCloseTip(sender: AnyObject) {
        self.categoryTips.hidden = true
        self.tipSection.constant = -5
    }
    
    func setClickedBtnBackgroundAndText(sender: UIButton) {
        sender.backgroundColor = txtPinkColor
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func setUnClickedBtnBackgroundAndText(sender: UIButton) {
        sender.backgroundColor = UIColor.lightGrayColor()
        sender.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
    }
    
    func onClickSellBtn(sender: AnyObject?) {
        self.tabBarController!.tabBar.hidden = true
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("sellProductsViewController") as! SellProductsViewController
        vController.selCategory = Int((selCategory?.id)!)
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    func setSizesForFilterButtons(cell: CategoryCollectionViewCell) {
        isWidthSet = true
        let availableWidthForButtons:CGFloat = self.view.bounds.width - 30
        let buttonWidth :CGFloat = availableWidthForButtons / 4
        cell.btnWidthConstraint.constant = buttonWidth
        cell.popularBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.popularBtn.layer.borderWidth = 1.0
        
        cell.newestBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.newestBtn.layer.borderWidth = 1.0
        
        cell.lowToHighBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.lowToHighBtn.layer.borderWidth = 1.0
        
        cell.highToLow.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.highToLow.layer.borderWidth = 1.0
    }
}