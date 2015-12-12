//
//  HomePageRightTabController.swift
//  Baby Box
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import UIKit
import SwiftEventBus
import Kingfisher

class HomePageRightTabViewController: UIViewController {
    //this controller will be used to manage category specific products list...
    
    var pageOffSet: Int = 0
    var currentSelProduct: Int = 0
    var apiController: ApiControlller = ApiControlller()
    
    let WINDOW_WIDTH = UIScreen.mainScreen().bounds.width
    let WINDOW_HEIGHT = UIScreen.mainScreen().bounds.height
    
    @IBOutlet weak var followingProductsCollectionView: UICollectionView!
    var homeProducts: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded HomePageRightTabViewController", terminator: "")
        
        SwiftEventBus.onMainThread(self, name: "homeFollowingPostsReceivedSuccess") { result in
            // UI thread
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleHomePosts(resultDto)
        }
        
        apiController.getHomeEollowingFeeds(pageOffSet)
    }
    
    func handleHomePosts(resultDto: [PostModel]) {
        
        self.homeProducts.appendContentsOf(resultDto)
        if (!self.homeProducts.isEmpty) {
            self.pageOffSet = Int(self.homeProducts[self.homeProducts.count - 1].offSet)
            dispatch_async(dispatch_get_main_queue(), {
                self.followingProductsCollectionView.reloadData()
            })
        }
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
        
        //productViewCell.layer.borderWidth = 1
        
            //print(productViewCell.buttonLike)
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
                //let imageData = NSData(contentsOfURL: imageUrl!)
                dispatch_async(dispatch_get_main_queue(), {
                    productViewCell.productIcon.kf_setImageWithURL(imageUrl!)
                    /*if (imageData != nil) {
                        productViewCell.productIcon.image = UIImage(data: imageData!)
                    }*/
                });
            }
        })
        return productViewCell;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("click on image..")
        //let vController = self.storyboard?.instantiateViewControllerWithIdentifier("myProductView") as! ProductDetailsViewController
        
        self.currentSelProduct = indexPath.row
        self.performSegueWithIdentifier("showProductDetail", sender: nil)
        //vController.productModel = self.homeProducts[indexPath.row]
        //
        //self.navigationController?.pushViewController(vController, animated: true)
        
        
    }
    
    //
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showProductDetail") {
            let controller = segue.destinationViewController as! UINavigationController
            let prodController = controller.viewControllers.first as! ProductDetailsViewController
            prodController.productModel = self.homeProducts[self.currentSelProduct]
            apiController.getProductDetails(String(Int(prodController.productModel.id)))
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    @IBAction func onClickLikeProduct(sender: AnyObject) {
        print(" ---- ")
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
    
    
    func reversePhotoArray(photoArray:[PostModel], startIndex:Int, endIndex:Int){
        if startIndex >= endIndex{
            return
        }
        swap(&homeProducts[startIndex], &homeProducts[endIndex])
        
        reversePhotoArray(homeProducts, startIndex: startIndex + 1, endIndex: endIndex - 1)
    }
    
    
   
}