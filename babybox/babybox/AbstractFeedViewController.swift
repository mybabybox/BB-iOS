//
//  AbstractFeedViewController.swift
//  babybox
//
//  Created by Mac on 04/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class AbstractFeedViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var pageOffSet: Int64 = 0
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    var apiController: ApiControlller = ApiControlller()
    var currentIndex = 0
    
    var isHeaderView: Bool = true
    var categories : [CategoryModel] = []
    var products: [PostModel] = []
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var tohide = true
    var reuseIdentifier = "CellType1"
    var loadingProducts: Bool = false
    var selCategory: CategoryModel? = nil
    
    var feedFilter: FeedFilter.FeedType? = FeedFilter.FeedType.HOME_EXPLORE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedSuccess") { result in
            // UI thread
            let resultDto: [CategoryModel] = result.object as! [CategoryModel]
            self.handleGetCateogriesSuccess(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "feedReceivedSuccess") { result in
            // UI thread
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleGetAllProductsuccess(resultDto)
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
        
        //self.view.bringSubviewToFront(customView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0;
        if (collectionView.tag == 2) {
            switch feedFilter! {
                case .HOME_EXPLORE:
                    count = self.categories.count
                    break
                case .HOME_FOLLOWING:
                    count = 0
                    break
                default:
                    count = 1
            }
            
        }else{
            count = self.products.count
        }
        return count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (collectionView.tag == 2){
            
            switch feedFilter! {
                case .HOME_EXPLORE:
                    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("staticCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
                    let categoryVM = self.categories[indexPath.row]
                    let imagePath =  constants.imagesBaseURL + categoryVM.icon;
                    let imageUrl  = NSURL(string: imagePath)
                    cell.categoryIcon.kf_setImageWithURL(imageUrl!)
                    cell.categoryName.text = categoryVM.name;
                    
                    cell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
                    cell.layer.borderWidth = 1
                    
                    //var arrayOfColors: [AnyObject] = arrayOfColorsAt(indexPath)
                    
                    let gradientLayer = CAGradientLayer()
                    gradientLayer.frame = cell.bounds
                    gradientLayer.locations = [0.0, 1.0]
                        
                    gradientLayer.colors = [
                        UIColor(white: 0, alpha: 0.10).CGColor,
                        UIColor(white: 0, alpha: 0.10).CGColor,
                        UIColor.lightGrayColor().CGColor
                    ]
                        
                    cell.categoryIcon.layer.insertSublayer(gradientLayer, atIndex: 0)
                    
                    
                    return cell
                
                case .CATEGORY_POPULAR,
                     .CATEGORY_NEWEST,
                     .CATEGORY_PRICE_HIGH_LOW,
                     .CATEGORY_PRICE_LOW_HIGH:
                    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("categoryCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
                    
                    cell.categoryName.text = self.selCategory?.name
                    let imagePath =  constants.imagesBaseURL + (self.selCategory?.icon)!;
                    let imageUrl  = NSURL(string: imagePath);
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.categoryIcon.kf_setImageWithURL(imageUrl!)
                    });
                    
                    return cell
                default:
                    return collectionView.dequeueReusableCellWithReuseIdentifier("staticCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
            }
        }
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CatProductCollectionViewCell
            
            cell.likeImageIns.tag = indexPath.item
            
            let post = self.products[indexPath.row]
            if (post.hasImage) {
                let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(post.images[0])
                let imageUrl  = NSURL(string: imagePath)
                cell.prodImageView.kf_setImageWithURL(imageUrl!)
            }
            cell.likeCount.text = String(post.numLikes)
            cell.title.text = post.title
            
            cell.productPrice.text = "\(constants.currencySymbol) \(String(stringInterpolationSegment: Int(post.price)))"
            
            if (post.originalPrice != 0 && post.originalPrice != -1 && post.originalPrice != Int(post.price)) {
                let attrString = NSAttributedString(string: "\(constants.currencySymbol) \(String(stringInterpolationSegment:Int(post.originalPrice)))", attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
                cell.originalPrice.attributedText = attrString
            }
            
            cell.likeImageIns.addTarget(self, action: "onLikeBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
            cell.layer.borderWidth = 1
            
            if (feedFilter == FeedFilter.FeedType.HOME_FOLLOWING) {
                cell.userCircleImg.layer.cornerRadius = 20.0
                cell.userCircleImg.layer.masksToBounds = true
                cell.userCircleImg.layer.borderColor = UIColor.whiteColor().CGColor
                cell.userCircleImg.layer.borderWidth = CGFloat(1.0)
                
                let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(Int(post.ownerId))
                let imageUrl  = NSURL(string: imagePath);
                
                dispatch_async(dispatch_get_main_queue(), {
                    cell.userCircleImg.kf_setImageWithURL(imageUrl!)
                });
                
            }
            return cell
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.currentIndex = indexPath.row
        
        print("pushing another controller.. from here..")
        if (collectionView.tag == 2){
            self.performSegueWithIdentifier("gotocatogorydetails", sender: nil)
            
        } else {
            self.performSegueWithIdentifier("gotoproductdetail", sender: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        
        
        if (kind == UICollectionElementKindSectionHeader) {
            
            let headerView : HomeReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! HomeReusableView
            
            switch feedFilter! {
                case FeedFilter.FeedType.CATEGORY_POPULAR:
                    headerView.suggestedFor.hidden = true
                    headerView.categoryLbl.hidden = true
                    break;
                default: break
                    //do nothing.
            }
            headerView.headerViewCollection.reloadData()
            reusableView = headerView
        }
        
        if (!isHeaderView) {
            reusableView?.frame = CGRectZero
            reusableView?.hidden = true
        } else {
            
        }
        return reusableView!
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (collectionView.tag == 2) {
            if let _ = collectionViewTopCellSize {
                
                switch feedFilter! {
                case .CATEGORY_PRICE_LOW_HIGH,
                .CATEGORY_PRICE_HIGH_LOW,
                .CATEGORY_POPULAR,
                .CATEGORY_NEWEST:
                    setCollectionViewSizesInsetsForTopView()
                    return collectionViewTopCellSize!
                default:
                    return collectionViewTopCellSize!
                    
                }
                
            }
        } else {
            if let _ = collectionViewCellSize {
                return collectionViewCellSize!
            }
        }
        return CGSizeZero
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (!self.isHeaderView) {
            return CGSizeZero
        } else if (collectionView.tag == 2){
            return CGSizeZero
        } else {
            switch feedFilter! {
                case .CATEGORY_PRICE_LOW_HIGH,
                    .CATEGORY_PRICE_HIGH_LOW,
                    .CATEGORY_POPULAR,
                    .CATEGORY_NEWEST:
                return CGSizeMake(self.view.frame.width, 190)
                default:
                    let availableWidthForCells:CGFloat = self.view.bounds.width - 35
                    let cellWidth :CGFloat = availableWidthForCells / 3
                    return CGSizeMake(self.view.frame.width, (cellWidth * 2) + 60)
                
            }
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
        
        //var vController = segue.destinationViewController
        let identifier = segue.identifier
        if (identifier == "gotocatogorydetails") {
            let navController = segue.destinationViewController as! UINavigationController
            let vController = navController.viewControllers.first as! CategoryDetailsViewController
            //let vController = segue.destinationViewController as! CategoryDetailsViewController
            vController.categories = self.categories[self.currentIndex]
        } else if (identifier == "gotoproductdetail") {
            let navController = segue.destinationViewController as! UINavigationController
            let vController = navController.viewControllers.first as! ProductDetailsViewController
            vController.productModel = self.products[self.currentIndex]
            
            switch feedFilter! {
            case .CATEGORY_PRICE_LOW_HIGH,
            .CATEGORY_PRICE_HIGH_LOW,
            .CATEGORY_POPULAR,
            .CATEGORY_NEWEST:
                vController.category = self.selCategory
                vController.fromPage = "categorydetails"
            case .HOME_FOLLOWING:
                vController.fromPage = "homefollowing"
            default:
                vController.fromPage = "homeexplore"
                
            }
            
            apiController.getProductDetails(String(Int(self.products[self.currentIndex].id)))
        }
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
    
    func handleGetCateogriesSuccess(categories: [CategoryModel]) {
        self.categories = categories;
        /*dispatch_async(dispatch_get_main_queue(), {
            self.uiCollectionView.reloadData();
        })*/
        
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        UIView.animateWithDuration(0.2, animations: {
            //constants.viewControllerIns!.tabBarController!.tabBar.hidden = true
            constants.viewControllerIns!.hidesBottomBarWhenPushed = true
            
            //let tabBarHeight = constants.viewControllerIns!.tabBarController!.tabBar.frame.size.height
            //self.uiCollectionView.frame.size.height = self.uiCollectionView.frame.size.height + tabBarHeight
        })
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
            if (self.loadingProducts) {
                
                switch feedFilter! {
                    case FeedFilter.FeedType.HOME_EXPLORE:
                        apiController.getHomeExploreFeeds(self.pageOffSet)
                    case FeedFilter.FeedType.HOME_FOLLOWING:
                        apiController.getHomeEollowingFeeds(self.pageOffSet)
                    case FeedFilter.FeedType.CATEGORY_POPULAR:
                        apiController.getCategoriesFilterByPopularity(0, offSet: self.pageOffSet)
                    case FeedFilter.FeedType.CATEGORY_NEWEST:
                        apiController.getCategoriesFilterByNewestPrice(0, offSet: self.pageOffSet)
                    case FeedFilter.FeedType.CATEGORY_PRICE_LOW_HIGH:
                        apiController.getCategoriesFilterByLhPrice(0, offSet: self.pageOffSet)
                    case FeedFilter.FeedType.CATEGORY_PRICE_HIGH_LOW:
                        apiController.getCategoriesFilterByHlPrice(0, offSet: self.pageOffSet)
                    default: break
                }
            
                self.loadingProducts = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        UIView.animateWithDuration(0.2, animations: {
            //constants.viewControllerIns!.tabBarController!.tabBar.hidden = false
            constants.viewControllerIns!.hidesBottomBarWhenPushed = true
        })
        //let tabBarHeight = constants.viewControllerIns!.tabBarController!.tabBar.frame.size.height
        //self.uiCollectionView.frame.size.height = self.uiCollectionView.frame.size.height - tabBarHeight
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        print(feedFilter)
        switch feedFilter! {
            case .CATEGORY_PRICE_LOW_HIGH,
            .CATEGORY_PRICE_HIGH_LOW,
            .CATEGORY_POPULAR,
            .CATEGORY_NEWEST:
            collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, 190)
        default:
            let availableWidthForCells:CGFloat = self.view.bounds.width - 35
            let cellWidth :CGFloat = availableWidthForCells / 3
            collectionViewTopCellSize = CGSizeMake(cellWidth, cellWidth)
        
        }
    }
    
    func setCollectionViewSizesInsets() {
        let availableWidthForCells:CGFloat = self.view.bounds.width - 15
        let cellWidth :CGFloat = availableWidthForCells / 2
        collectionViewCellSize = CGSizeMake(cellWidth, cellWidth)
    }
    
    func setFeedtype(feedType: FeedFilter.FeedType) {
        self.feedFilter = feedType
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! CatProductCollectionViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)
        
        //TODO - logic here require if user has already liked the product...
        if (self.products[(indexPath?.row)!].isLiked) {
            //if (self.products[(indexPath?.row)!].prodLiked) {
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
    
    @IBAction func onClickPopulated(sender: AnyObject) {
        self.pageOffSet = 0
        self.setFeedtype(FeedFilter.FeedType.CATEGORY_POPULAR)
        self.products = []
        
        ApiControlller.apiController.getCategoriesFilterByPopularity(Int(self.selCategory!.id), offSet: 0)
    }
    
    @IBAction func onClickNewest(sender: AnyObject) {
        self.pageOffSet = 0
        self.setFeedtype(FeedFilter.FeedType.CATEGORY_NEWEST)
        self.products = []
        ApiControlller.apiController.getCategoriesFilterByNewestPrice(Int(self.selCategory!.id), offSet: 0)
    }
    
    @IBAction func onClickHighLow(sender: AnyObject) {
        self.pageOffSet = 0
        self.setFeedtype(FeedFilter.FeedType.CATEGORY_PRICE_HIGH_LOW)
        self.products = []
        ApiControlller.apiController.getCategoriesFilterByHlPrice(Int(self.selCategory!.id), offSet: 0)
    }
    
    @IBAction func onClickLowHigh(sender: AnyObject) {
        self.pageOffSet = 0
        self.setFeedtype(FeedFilter.FeedType.CATEGORY_PRICE_LOW_HIGH)
        self.products = []
        ApiControlller.apiController.getCategoriesFilterByLhPrice(Int(self.selCategory!.id), offSet: 0)
    }
    
    
    

}
