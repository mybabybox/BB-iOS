//
//  HomePageRightTabController.swift
//  Baby Box
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import UIKit
import SwiftEventBus

class HomePageRightTabViewController: UIViewController {
    //this controller will be used to manage category specific products list...
    
    @IBOutlet weak var homeProductsCollectionView: UICollectionView!
    var apiController: ApiControlller = ApiControlller()
    
    var homeProducts: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded HomePageRightTabViewController")
        
        apiController.getHomeEollowingFeeds("0")
        apiController.getHomeExploreFeeds("0")
        self.homeProducts = []
        SwiftEventBus.onMainThread(self, name: "homeExplorePostsReceivedSuccess") { result in
            // UI thread
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleHomePosts(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "homeFollowingPostsReceivedSuccess") { result in
            // UI thread
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleHomePosts(resultDto)
        }
        
    }
    
    func handleHomePosts(resultDto: [PostModel]) {
        self.homeProducts.appendContentsOf(resultDto)
        dispatch_async(dispatch_get_main_queue(), {
            self.homeProductsCollectionView.reloadData()
        })
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0;
        count = self.homeProducts.count
        print("conter of right " + String(self.homeProducts.count))
        return count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let productViewCell: HomeProductsCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("productTypeViewCell", forIndexPath: indexPath) as! HomeProductsCollectionViewCell
            let post = self.homeProducts[indexPath.row]
        productViewCell.productTitle.text = post.title
            productViewCell.productPrice.text = "\(constants.currencySymbol) \(String(post.price))"
            productViewCell.likeCount.text = String(post.numLikes)
            //print("aaaaaaaaaaaaaaa  \(post.isLiked)")
        
        
        productViewCell.layer.borderWidth = 1
        
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
                let imageData = NSData(contentsOfURL: imageUrl!)
                print(imageUrl)
                dispatch_async(dispatch_get_main_queue(), {
                    if (imageData != nil) {
                        productViewCell.productIcon.image = UIImage(data: imageData!)
                    }
                });
            }
            
        })
        return productViewCell;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("myProductView") as! ProductDetailsViewController
        print("User tapped on \(indexPath.row)");
        vController.productModel = self.homeProducts[indexPath.row]
        //print("---------------------------")
        //print(vController.productModel.id)
        apiController.getProductDetails(String(Int(vController.productModel.id)))
        self.navigationController?.pushViewController(vController, animated: true)
    }
   
}