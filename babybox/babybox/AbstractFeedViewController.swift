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
    
    @IBOutlet weak var bConstraint: NSLayoutConstraint!
    var pageOffSet: Int64 = 0
    var apiController: ApiControlller = ApiControlller()
    var currentIndex = 0
    var isHeaderView: Bool = false
    var categories : [CategoryModel] = []
    var products: [PostModel] = []
    var contentType: String = "explore"
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var tohide = true
    var reuseIdentifier = "CellType1"
    var loadingProducts: Bool = false
    var isCategoryDetails = false
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.addSubview(self.uiCollectionView)
        
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedSuccess") { result in
            // UI thread
            let resultDto: [CategoryModel] = result.object as! [CategoryModel]
            self.handleGetCateogriesSuccess(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "homeExplorePostsReceivedSuccess") { result in
            // UI thread
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleGetAllProductsuccess(resultDto)
        }
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
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
        self.products = []
    }
    
    override func viewDidAppear(animated: Bool) {
        self.pageOffSet = 0
        categories = []
        products = []
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
            if (isCategoryDetails) {
                count = 1
            } else {
                count = self.categories.count
            }
        }else{
            count = self.products.count
        }
        return count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (collectionView.tag == 2){
            if (isCategoryDetails) {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("categoryCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("staticCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
                let categoryVM = self.categories[indexPath.row]
                let imagePath =  constants.imagesBaseURL + categoryVM.icon;
                let imageUrl  = NSURL(string: imagePath)
                cell.categoryIcon.kf_setImageWithURL(imageUrl!)
                cell.categoryName.text = categoryVM.name;
                
                cell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
                cell.layer.borderWidth = 1
                //cell.layer.cornerRadius = 8 // optional
                
                return cell
            }
        }
        else{
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
            cell.productPrice.text = "\(constants.currencySymbol) \(String(stringInterpolationSegment: post.price))"
            
            //cell.prodImageIns.addTarget(self, action: "ImagePressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeImageIns.addTarget(self, action: "onLikeBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
            cell.layer.borderWidth = 1
            
            return cell
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.currentIndex = indexPath.row
        
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
            headerView.headerViewCollection.reloadData()
            reusableView = headerView
        }
        
        if (!isHeaderView) {
            reusableView?.frame = CGRectZero
            reusableView?.hidden = true
            
            //self.uiCollectionView.frame = CGRectMake(self.uiCollectionView.frame.origin.x, 0, self.uiCollectionView.frame.width, self.uiCollectionView.frame.height)
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
        if (!self.isHeaderView) {
            return CGSizeZero
        } else if (collectionView.tag == 2){
            return CGSizeZero
        } else {
            if (isCategoryDetails) {
                return CGSizeMake(self.view.frame.width, 150)
            } else {
                return CGSizeMake(self.view.frame.width, 250)
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
            
            let vController = segue.destinationViewController as! CategoryDetailsViewController
            /*vController.categories.id = self.categories[self.currentIndex].id
            vController.categories.icon = self.categories[self.currentIndex].icon
            vController.categories.name = self.categories[self.currentIndex].name*/
        } else if (identifier == "gotoproductdetail") {
            let vController = segue.destinationViewController as! ProductDetailsViewController
            vController.productModel = self.products[self.currentIndex]
            vController.fromPage = "homeexplore"
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
            constants.viewControllerIns!.tabBarController!.tabBar.hidden = true
            constants.viewControllerIns!.hidesBottomBarWhenPushed = true
            
            //let tabBarHeight = constants.viewControllerIns!.tabBarController!.tabBar.frame.size.height
            //self.uiCollectionView.frame.size.height = self.uiCollectionView.frame.size.height + tabBarHeight
        })
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
            if (self.loadingProducts) {
                if (self.contentType == "explore") {
                    apiController.getHomeExploreFeeds(self.pageOffSet);
                } else if (self.contentType == "following") {
                    apiController.getHomeEollowingFeeds(self.pageOffSet);
                } else if (self.contentType == "categoryprods") {
                    //High To low
                    //Low to High
                    //Popular
                    //Newest
                    
                    //apiController.getCategoriesFilterByPopularity(<#T##id: Int##Int#>, offSet: <#T##Int64#>)(self.pageOffSet);
                }
                
                self.loadingProducts = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        UIView.animateWithDuration(0.2, animations: {
            constants.viewControllerIns!.tabBarController!.tabBar.hidden = false
            constants.viewControllerIns!.hidesBottomBarWhenPushed = true
        })
        //let tabBarHeight = constants.viewControllerIns!.tabBarController!.tabBar.frame.size.height
        //self.uiCollectionView.frame.size.height = self.uiCollectionView.frame.size.height - tabBarHeight
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        if (self.isCategoryDetails) {
            collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, 150)
        } else {
            let availableWidthForCells:CGFloat = self.view.bounds.width - 35
            let cellWidth :CGFloat = availableWidthForCells / 3
            let cellHeight = CGFloat(95.0)//cellWidth
            collectionViewTopCellSize = CGSizeMake(cellWidth, cellHeight)
        }
    }
    
    func setCollectionViewSizesInsets() {
        let availableWidthForCells:CGFloat = self.view.bounds.width - 15
        let cellWidth :CGFloat = availableWidthForCells / 2
        let cellHeight = cellWidth * 4/3
        collectionViewCellSize = CGSizeMake(cellWidth, cellHeight)
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
}
