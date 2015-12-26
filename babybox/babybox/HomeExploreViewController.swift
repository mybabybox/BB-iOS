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

class HomeExploreViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var reuseIdentifier = "CellType1"
    var loadingProducts: Bool = false
    var pageOffSet: Int64 = 0
    var apiController: ApiControlller = ApiControlller()
    var currentIndex = 0
    var categories : [CategoryModel] = []
    var products: [PostModel] = []
    
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    
    override func viewDidAppear(animated: Bool) {
        self.pageOffSet = 0
        apiController.getAllCategories();
        apiController.getHomeExploreFeeds(pageOffSet);
        
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = flowLayout
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.rightBarButtonItem = getSellButton()
        
        apiController.getAllCategories();
        apiController.getHomeExploreFeeds(pageOffSet);
        
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
        
        let cSelector : Selector = "gotoSecondSegmentTwo:"
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(leftSwipe)
        
       
        
        
    }
    
    @IBAction func gotoSecondSegmentTwo(sender: AnyObject) {
        let vController = self.view.superview?.superview!.nextResponder() as! InitialHomeSegmentedController
        //let vController = self.storyboard?.instantiateViewControllerWithIdentifier("initialSegmentViewController") as! InitialHomeSegmentedController
        vController.activeSegment = 1
        self.navigationController?.presentViewController(vController, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.products = []
        //self.currentIndex = 0
        //self.pageOffSet = 0
        
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! CatProductCollectionViewCell
        
        let indexPath = collectionView.indexPathForCell(cell)
        //print(indexPath)
        
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
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0;
        if (collectionView.tag == 2){
            count = self.categories.count
        }else{
            count = self.products.count
        }
        return count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (collectionView.tag == 2){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("staticCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let categoryVM = self.categories[indexPath.row]
                let imagePath =  constants.imagesBaseURL + categoryVM.icon;
                let imageUrl  = NSURL(string: imagePath)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.categoryIcon.kf_setImageWithURL(imageUrl!)
                    cell.categoryName.text = categoryVM.name;
                });
            })
            cell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
            cell.layer.borderWidth = 1
            //cell.layer.cornerRadius = 8 // optional
            
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CatProductCollectionViewCell
            
            cell.likeImageIns.tag = indexPath.item
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let post = self.products[indexPath.row]
                
                if (post.hasImage) {
                    let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(post.images[0])
                    let imageUrl  = NSURL(string: imagePath);
                   // print(imageUrl)
                    //let imageData = NSData(contentsOfURL: imageUrl!)
                    //print(imageUrl, terminator: "")
                    dispatch_async(dispatch_get_main_queue(), {
                        //if (imageData != nil) {
                        //let resource = Resource(downloadURL: imageUrl!, cacheKey: String(post.id))
                        //productViewCell.productIcon.kf_setImageWithResource(resource)
                        //cell.prodImageIns.imageView!.kf_setImageWithURL(imageUrl!)
                        cell.prodImageView.kf_setImageWithURL(imageUrl!)
                        //productViewCell.productIcon.image = UIImage(data: imageData!)
                        //}
                    });
                }
                cell.likeCount.text = String(post.numLikes)
                cell.title.text = post.title
                cell.productPrice.text =
                    "\(constants.currencySymbol) \(String(stringInterpolationSegment: post.price))"
            })
            
            //cell.prodImageIns.addTarget(self, action: "ImagePressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeImageIns.addTarget(self, action: "HeartPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
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
        return reusableView!
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if (collectionView.tag == 2){
            if let _ = collectionViewTopCellSize {
                return collectionViewTopCellSize!
            }
        }else{
            if let _ = collectionViewCellSize {
                return collectionViewCellSize!
            }
        }
        return CGSizeZero
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (collectionView.tag == 2){
            return CGSizeZero
        }else{
            return CGSizeMake(self.view.frame.width, 250)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
    }*/
    
    
    func HeartPressed(button: UIButton){
    }
    
    func ImagePressed(button: UIButton){
    }
    
    func getSellButton() -> UIBarButtonItem {
        let sellImage: UIImage = UIImage(named:"ic_info_bubble")!
        let frameimg: CGRect = CGRectMake(0, 0, 30, 30);
        let sellButton = UIButton(frame: frameimg)
        sellButton.setBackgroundImage(sellImage, forState: UIControlState.Normal)
        sellButton.showsTouchWhenHighlighted = true
        sellButton.addTarget(self, action: "sellButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        
        let sellBarButton = UIBarButtonItem()
        sellBarButton.customView = sellButton
        
        return sellBarButton
    }
    
    func sellButtonPressed() {
        NSLog("Sell button Pressed...")
        self.performSegueWithIdentifier("sellProductView", sender: nil)
        
    }
    
    func handleGetAllProductsuccess(resultDto: [PostModel]) {
        //print("got all products...", terminator: "");
        //self.products = resultDto
        if (!resultDto.isEmpty) {
            
            if (self.products.count == 0) {
                self.products = resultDto
                self.collectionView.reloadData()
            } else {
                /*var indexPaths = [NSIndexPath]()
                let firstIndex = self.products.count
                
                for (i, postModel) in resultDto.enumerate() {
                    let indexPath = NSIndexPath(forItem: firstIndex + i, inSection: 0)
                    
                    self.products.append(postModel)
                    indexPaths.append(indexPath)
                }
                
                self.collectionView?.performBatchUpdates({ () -> Void in
                    self.collectionView?.insertItemsAtIndexPaths(indexPaths)
                    }, completion: { (finished) -> Void in
                        //completion?()
                });*/
                self.products.appendContentsOf(resultDto)
                self.collectionView.reloadData()
            }
        }
        
        self.pageOffSet = Int64(self.products[self.products.count-1].offset)
        self.loadingProducts = true
    }
    
    func handleGetCateogriesSuccess(categories: [CategoryModel]) {
        self.categories = categories;
        
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData();
        })
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //var vController = segue.destinationViewController
        let identifier = segue.identifier
        let navigationController = segue.destinationViewController as! UINavigationController
        if (identifier == "gotocatogorydetails") {
            
            let vController = navigationController.viewControllers.first as! CategoryDetailsViewController
            vController.categories.id = self.categories[self.currentIndex].id
            vController.categories.icon = self.categories[self.currentIndex].icon
            vController.categories.name = self.categories[self.currentIndex].name
        } else if (identifier == "gotoproductdetail") {
            let vController = navigationController.viewControllers.first as! ProductDetailsViewController
            vController.productModel = self.products[self.currentIndex]
            vController.fromPage = "homeexplore"
            apiController.getProductDetails(String(Int(self.products[self.currentIndex].id)))
        }
        
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
            if (self.loadingProducts) {
                apiController.getHomeExploreFeeds(self.pageOffSet);
                self.loadingProducts = false
            }
        }
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        let availableWidthForCells:CGFloat = self.view.bounds.width - 30
        let cellWidth :CGFloat = availableWidthForCells / 3
        let cellHeight = CGFloat(95.0)//cellWidth
        collectionViewTopCellSize = CGSizeMake(cellWidth, cellHeight)
    }
    func setCollectionViewSizesInsets() {
        let availableWidthForCells:CGFloat = self.view.bounds.width - 15
        let cellWidth :CGFloat = availableWidthForCells / 2
        let cellHeight = cellWidth * 4/3
        collectionViewCellSize = CGSizeMake(cellWidth, cellHeight)
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.floatingView.hidden = true
        self.topConstraint.constant = 0.0
    }
    
}

