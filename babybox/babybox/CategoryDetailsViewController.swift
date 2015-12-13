//
//  CategoryDetailsViewController.swift
//  Baby Box
//
//  Created by Mac on 20/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus
import Kingfisher

class CategoryDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var prodCollectionView: UICollectionView!
    var pageOffSet = 0
    var catProducts: [PostModel] = []
    @IBOutlet var typesButtonGroup: [UIButton]!
    var filterType: Int = 1
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    var categories : CategoryModel = CategoryModel()
    
    @IBAction func onClickHighToLwFilter(sender: AnyObject) {
        self.pageOffSet = 0
        filterType = 1
        self.catProducts = []
        self.prodCollectionView.reloadData()
        ApiControlller.apiController.getCategoriesFilterByHlPrice(Int(categories.id), offSet: pageOffSet)

    }
    
    @IBAction func onClickLwToHighFilter(sender: AnyObject) {
        self.pageOffSet = 0
        filterType = 2
        self.catProducts = []
        self.prodCollectionView.reloadData()
        ApiControlller.apiController.getCategoriesFilterByLhPrice(Int(categories.id), offSet: pageOffSet)
    }
    
    @IBAction func onClickFilterByNewest(sender: AnyObject) {
        self.pageOffSet = 0
        filterType = 3
        self.catProducts = []
        self.prodCollectionView.reloadData()
        ApiControlller.apiController.getCategoriesFilterByNewestPrice(Int(categories.id), offSet: pageOffSet)
    }
    
    @IBAction func onClickPopularFilter(sender: AnyObject) {
        self.pageOffSet = 0
        self.catProducts = []
        self.prodCollectionView.reloadData()
        filterType = 4
        ApiControlller.apiController.getCategoriesFilterByPopularity(Int(categories.id), offSet: pageOffSet)
        
    }
    
    override func viewDidAppear(animated: Bool) {
       
        print("Show the detail of selected product view.... ", terminator: "");
        
        self.categoryName.text = self.categories.name
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let categoryVM = self.categories
            let imagePath =  constants.imagesBaseURL + categoryVM.icon;
            let imageUrl  = NSURL(string: imagePath);
            //let imageData = NSData(contentsOfURL: imageUrl!)
            
            dispatch_async(dispatch_get_main_queue(), {
                //if (imageData != nil) {
                //    self.categoryImageView.image = UIImage(data: imageData!)
                //}
                self.categoryImageView.kf_setImageWithURL(imageUrl!)
            });
        })
    }
    
    override func viewDidLoad() {
        print("view loaded", terminator: "");
        //by default call the first server side call using default filter criteria.
        
        //getCategoriesFilterByPopularity Event Handler
        //getCategoriesFilterByNewestPrice Event Handler
        //getCategoriesFilterByLhPrice Event Handler
        //getCategoriesFilterByHlPrice Event Handler
        SwiftEventBus.onMainThread(self, name: "categoryProductFeedSuccess") { result in
            // UI thread
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleGetProductDetailsSuccess(resultDto)
        }
        
        ApiControlller.apiController.getCategoriesFilterByPopularity(Int(categories.id), offSet: pageOffSet)

    }
    
    func handleGetProductDetailsSuccess(result: [PostModel]) {
        print("handling success...", terminator: "")
        print(result, terminator: "")
        if (result.isEmpty) {
            
        } else {
            self.catProducts.appendContentsOf(result)
            self.prodCollectionView.reloadData()
            self.pageOffSet = Int(self.catProducts[self.catProducts.count-1].offSet)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("view disappeared", terminator: "")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0;
        count = self.catProducts.count
        return count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let productViewCell: CustomCatProductViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("catProductViewCell", forIndexPath: indexPath) as! CustomCatProductViewCell
        
        let post = self.catProducts[indexPath.row]
        productViewCell.title.text = post.title
        productViewCell.price.text = "\(constants.currencySymbol) \(String(stringInterpolationSegment: post.price))"
        productViewCell.likeCounter.text = String(post.numLikes)
        //productViewCell.layer.borderWidth = 1
        
        productViewCell.id = post.id
        if(post.isLiked == false){
            productViewCell.likeImg.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            productViewCell.likeFlag = false
        }else {
            productViewCell.likeImg.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            productViewCell.likeFlag = true
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            if (post.hasImage) {
                let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(post.images[0])
                let imageUrl  = NSURL(string: imagePath);
                print(imageUrl)
                //let imageData = NSData(contentsOfURL: imageUrl!)
                dispatch_async(dispatch_get_main_queue(), {
                    productViewCell.productImage.kf_setImageWithURL(imageUrl!)
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
        
        vController.productModel = self.catProducts[indexPath.row]
        ApiControlller.apiController.getProductDetails(String(Int(vController.productModel.id)))
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
            switch(filterType) {
                case 1:
                    ApiControlller.apiController.getCategoriesFilterByHlPrice(Int(categories.id), offSet: pageOffSet)
                case 2:
                    ApiControlller.apiController.getCategoriesFilterByLhPrice(Int(categories.id), offSet: pageOffSet)
                case 3:
                    ApiControlller.apiController.getCategoriesFilterByNewestPrice(Int(categories.id), offSet: pageOffSet)
                case 4:
                    ApiControlller.apiController.getCategoriesFilterByPopularity(Int(categories.id), offSet: pageOffSet)
                default: print("Invalid Selection")
            }
        }
    }
    
    
}