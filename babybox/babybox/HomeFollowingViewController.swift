//
//  HomeFollowingViewController.swift
//  Baby Box
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import UIKit
import SwiftEventBus
import Kingfisher

class HomeFollowingViewController: UIViewController {
    //this controller will be used to manage category specific products list...
    
    var pageOffSet: Int64 = 0
    var currentSelProduct: Int = 0
    var apiController: ApiControlller = ApiControlller()
    var isLoading : Bool = false
    let WINDOW_WIDTH = UIScreen.mainScreen().bounds.width
    @IBOutlet weak var likeCountLabel: UILabel!
    let WINDOW_HEIGHT = UIScreen.mainScreen().bounds.height
    
    @IBOutlet weak var followingProductsCollectionView: UICollectionView!
    var homeProducts: [PostModel] = []
    
    var collectionViewCellSize : CGSize?
    
    override func viewDidAppear(animated: Bool) {
        apiController.getHomeEollowingFeeds(pageOffSet)
        
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.followingProductsCollectionView.collectionViewLayout = flowLayout
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded HomeFollowingViewController", terminator: "")
        
        apiController.getHomeEollowingFeeds(pageOffSet)
        
        SwiftEventBus.onMainThread(self, name: "homeFollowingPostsReceivedSuccess") { result in
            // UI thread
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleHomePosts(resultDto)
        }
        setCollectionViewSizesInsets()
        
        let cSelector : Selector = "gotoSecondSegmentOne:"
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(rightSwipe)
        
    }
    
    @IBAction func gotoSecondSegmentOne(sender: AnyObject) {
        let vController = self.view.superview?.superview!.nextResponder() as! InitialHomeSegmentedController
        //let vController = self.storyboard?.instantiateViewControllerWithIdentifier("initialSegmentViewController") as! InitialHomeSegmentedController
        vController.activeSegment = 0
        self.navigationController?.presentViewController(vController, animated: false, completion: nil)
    }
    
    func handleHomePosts(resultDto: [PostModel]) {
        
        //self.homeProducts.appendContentsOf(resultDto)
        if (!resultDto.isEmpty) {
            
            /*dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
            })*/
            
            if (self.homeProducts.count == 0) {
                self.homeProducts = resultDto
                self.followingProductsCollectionView.reloadData()
            } else {
                /*var indexPaths = [NSIndexPath]()
                let firstIndex = self.homeProducts.count
                
                for (i, postModel) in resultDto.enumerate() {
                    let indexPath = NSIndexPath(forItem: firstIndex + i, inSection: 0)
                    
                    self.homeProducts.append(postModel)
                    indexPaths.append(indexPath)
                }
                
                self.followingProductsCollectionView?.performBatchUpdates({ () -> Void in
                    self.followingProductsCollectionView?.insertItemsAtIndexPaths(indexPaths)
                    }, completion: { (finished) -> Void in
                        //completion?()
                });*/
                self.homeProducts.appendContentsOf(resultDto)
                self.followingProductsCollectionView.reloadData()
            }
            self.pageOffSet = Int64(self.homeProducts[self.homeProducts.count-1].offset)
        }
        
        self.isLoading = true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0;
        count = self.homeProducts.count
        return count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let productViewCell: HomeProductsCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("productTypeViewCell", forIndexPath: indexPath) as! HomeProductsCollectionViewCell
            let post = self.homeProducts[indexPath.row]
        productViewCell.productTitle.text = post.title
            productViewCell.productPrice.text = "\(constants.currencySymbol) \(String(stringInterpolationSegment: post.price))"
            productViewCell.likeCount.text = String(post.numLikes)
        
        //if(post.ownerId) {
            productViewCell.userProfileImage.layer.cornerRadius = 20.0
            productViewCell.userProfileImage.layer.masksToBounds = true
        
        let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(Int(post.ownerId))
            let imageUrl  = NSURL(string: imagePath);
            print(imageUrl)
            //let imageData = NSData(contentsOfURL: imageUrl!)
            dispatch_async(dispatch_get_main_queue(), {
                productViewCell.userProfileImage.kf_setImageWithURL(imageUrl!)
            });
            productViewCell.id = post.id
            if(post.isLiked == false){
               productViewCell.buttonLike.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
                productViewCell.likeFlag = false
            }else {
                productViewCell.buttonLike.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
                productViewCell.likeFlag = true
            }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            if (post.hasImage) {
                let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(post.images[0])
                let imageUrl  = NSURL(string: imagePath);
                print(imageUrl)
                dispatch_async(dispatch_get_main_queue(), {
                    productViewCell.productIcon.kf_setImageWithURL(imageUrl!)
                });
            }
        })
        
        productViewCell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
        productViewCell.layer.borderWidth = 1
        
        return productViewCell;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.currentSelProduct = indexPath.row
        self.performSegueWithIdentifier("showProductDetail", sender: nil)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if let _ = collectionViewCellSize {
                return collectionViewCellSize!
        }
        
        return CGSizeZero
    }
    
    //
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "showProductDetail") {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showProductDetail") {
            let controller = segue.destinationViewController as! UINavigationController
            let prodController = controller.viewControllers.first as! ProductDetailsViewController
            prodController.fromPage = "homefollowing"
            prodController.productModel = self.homeProducts[self.currentSelProduct]
            apiController.getProductDetails(String(Int(prodController.productModel.id)))
        }
    }
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsetsMake(0, 0, 0, 0)
    }*/
    
    @IBAction func onClickLikeProduct(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! HomeProductsCollectionViewCell
        
        let indexPath = followingProductsCollectionView.indexPathForCell(cell)
        print(indexPath)
        //TODO - logic here require if user has already liked the product... 
        if (self.homeProducts[(indexPath?.row)!].prodLiked) {
            self.homeProducts[(indexPath?.row)!].prodLiked = false
            apiController.unlikePost(String(self.homeProducts[(indexPath?.row)!].id))
            button.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            
        } else {
            self.homeProducts[(indexPath?.row)!].prodLiked = true
            apiController.likePost(String(self.homeProducts[(indexPath?.row)!].id))
            button.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            
        }
        
    }
    
    func photoForIndexPath(indexPath: NSIndexPath) -> PostModel {
        return homeProducts[indexPath.row]
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
            if (self.isLoading) {
                apiController.getHomeEollowingFeeds(pageOffSet)
                self.isLoading = false
            }
        }
    }
    
    func setCollectionViewSizesInsets() {
        let availableWidthForCells:CGFloat = self.view.bounds.width - 15
        let cellWidth :CGFloat = (availableWidthForCells / 2)
        let cellHeight = cellWidth * 4/3
        collectionViewCellSize = CGSizeMake(cellWidth, cellHeight)
    }
   
}