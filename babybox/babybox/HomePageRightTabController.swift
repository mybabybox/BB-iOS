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
    }
    
    func fetchData() {
        apiController.getHomeEollowingFeeds(pageOffSet)
    }
    
    func handleHomePosts(resultDto: [PostModel]) {
        
        for value in resultDto {
            self.homeProducts.append(value)
        }
        
        //self.homeProducts.appendContentsOf(resultDto)
        dispatch_async(dispatch_get_main_queue(), {
            self.followingProductsCollectionView.reloadData()
        })
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0;
        count = self.homeProducts.count
        print("conter of right " + String(self.homeProducts.count), terminator: "")
        return count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let productViewCell: HomeProductsCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("productTypeViewCell", forIndexPath: indexPath) as! HomeProductsCollectionViewCell
            let post = self.homeProducts[indexPath.row]
        productViewCell.productTitle.text = post.title
            productViewCell.productPrice.text = "\(constants.currencySymbol) \(String(stringInterpolationSegment: post.price))"
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
        
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("myProductView") as! ProductDetailsViewController
        
        vController.productModel = self.homeProducts[indexPath.row]
        apiController.getProductDetails(String(Int(vController.productModel.id)))
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            let size:CGSize = CGSizeMake(WINDOW_WIDTH, (WINDOW_WIDTH)*1)
            return size
            
    }*/
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsetsMake(0, 0, 0, 0)
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