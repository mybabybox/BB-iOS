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
    var categories : [CategoryModel] = []
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var reuseIdentifier = "CellType1"
    var isHeightSet: Bool = false
    
    func reloadDataToView() {
        self.activityLoading.stopAnimating()
        self.uiCollectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedLoader = FeedLoader(feedType: FeedFilter.FeedType.HOME_EXPLORE, reloadDataToView: reloadDataToView)
        feedLoader!.reloadFeedItems()
        
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
        
        ApiControlller.apiController.getAllCategories()
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
        self.tabBarController!.tabBar.hidden = true

        if (collectionView.tag == 2){
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("CategoryFeedViewController") as! CategoryFeedViewController
            vController.selCategory = self.categories[indexPath.row]
            self.navigationController?.pushViewController(vController, animated: true)
        } else {
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("FeedProductViewController") as! FeedProductViewController
            let feedItem = feedLoader!.getItem(indexPath.row)
            vController.productModel = feedItem
            ApiControlller.apiController.getProductDetails(String(Int(feedItem.id)))
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
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
       
        let velocity: CGFloat = scrollView.panGestureRecognizer.velocityInView(scrollView).y
        
        if (velocity > 0) {
            //self.navigationController?.setNavigationBarHidden(false, animated: true)
            //self.navigationController?.setToolbarHidden(false, animated: true)
            self.tabBarController?.tabBar.alpha = CGFloat(1.0)
            /*UIView.animateWithDuration(0.1, animations: {
                //self.tabBarController?.tabBar.frame.size.height = 0
                //self.tabBarController?.tabBar.hidden = false
                //self.hidesBottomBarWhenPushed = true
                
                if (self.isHeightSet) {
                    let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
                    self.view.frame.size.height = self.view.frame.size.height - tabBarHeight
                    self.isHeightSet = false
                }
            })*/
            
        } else if (velocity < 0) {
            //self.navigationController?.setNavigationBarHidden(true, animated: true)
            //self.navigationController?.setToolbarHidden(true, animated: true)

            self.tabBarController?.tabBar.alpha = CGFloat(0.1)
            
            /*UIView.animateWithDuration(0.1, animations: {
                //self.tabBarController?.tabBar.hidden = true
                //self.hidesBottomBarWhenPushed = true
                
               if (!self.isHeightSet) {
                    let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
                    self.view.frame.size.height = self.view.frame.size.height + tabBarHeight
                    self.isHeightSet = true
                }
            })*/
            
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height ){
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
}

