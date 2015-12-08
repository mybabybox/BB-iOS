//
//  HomePageLeftTabViewController.swift
//  Baby Box
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import UIKit
import SwiftEventBus
import AVFoundation
import Kingfisher

class HomePageLeftTabViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var myCategoryCollectionView: UICollectionView!
    var apiController: ApiControlller = ApiControlller()
    
    var categories : [CategoryModel] = []
    var products: [PostModel] = []
    
    override func viewDidAppear(animated: Bool) {
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("loaded HomePageLeftTabViewController", terminator: "")
        var collectionViewLayout = self.myCategoryCollectionView.collectionViewLayout;
        //collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
        
       // self.navigationItem.setHidesBackButton(false, animated:false);
//        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
//        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
//        navigationItem.leftBarButtonItem = backButton
        
        
        //SwiftEventBus.post("getCategories", sender: baseArgVM);
        apiController.getAllCategories();
        apiController.getAllFeedProducts();
        
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedSuccess") { result in
            // UI thread
            let resultDto: [CategoryModel] = result.object as! [CategoryModel]
            self.handleGetCateogriesSuccess(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "allPostsReceivedSuccess") { result in
            // UI thread
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleGetAllProductsuccess(resultDto)
        }
        
    }
    
    func handleGetAllProductsuccess(resultDto: [PostModel]) {
        print("got all products...", terminator: "");
        self.products = resultDto
        dispatch_async(dispatch_get_main_queue(), {
            self.productsCollectionView.reloadData()
            print("reloaded the collection view.", terminator: "")
        })
    }
    
    func handleGetCateogriesSuccess(categories: [CategoryModel]) {
        self.categories = categories;
        
        dispatch_async(dispatch_get_main_queue(), {
            self.myCategoryCollectionView.reloadData();
        })
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("calling this...", terminator: "")
        var count = 0;
        if (self.myCategoryCollectionView == collectionView) {
            count = self.categories.count
        } else if (self.productsCollectionView == collectionView) {
            print("product collection size " + String(self.products.count), terminator: "")
            count = self.products.count
        }
        return count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let displayViewCell: UICollectionViewCell = UICollectionViewCell();
        
        if (self.myCategoryCollectionView == collectionView) {
            let categoryViewCell: CategoryCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("categoryImageViewCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let categoryVM = self.categories[indexPath.row]
                let imagePath =  constants.imagesBaseURL + categoryVM.icon;
                let imageUrl  = NSURL(string: imagePath)
                //print("-----", terminator: "")
                //print(categoryVM.id, terminator: "")
                //let imageData = NSData(contentsOfURL: imageUrl!)
                //print(imageUrl, terminator: "")
                dispatch_async(dispatch_get_main_queue(), {
                    //if (imageData != nil) {
                        
                        //let resource = Resource(downloadURL: imageUrl!, cacheKey: categoryVM.name)
                        //categoryViewCell.categoryIcon.kf_setImageWithResource(resource)
                        categoryViewCell.categoryIcon.kf_setImageWithURL(imageUrl!)
                        //categoryViewCell.categoryIcon.image = UIImage(data: imageData!)
                        categoryViewCell.categoryName.text = categoryVM.name;
                    //}
                });
            })
            return categoryViewCell;
            
        } else if (self.productsCollectionView == collectionView) {
            let productViewCell: ProductCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("productsCollectionViewCell", forIndexPath: indexPath) as! ProductCollectionViewCell
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let post = self.products[indexPath.row]
                
                if (post.hasImage) {
                    let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(post.images[0])
                    let imageUrl  = NSURL(string: imagePath);
                    print(imageUrl)
                    //let imageData = NSData(contentsOfURL: imageUrl!)
                    //print(imageUrl, terminator: "")
                    dispatch_async(dispatch_get_main_queue(), {
                        //if (imageData != nil) {
                        //let resource = Resource(downloadURL: imageUrl!, cacheKey: String(post.id))
                        //productViewCell.productIcon.kf_setImageWithResource(resource)
                            productViewCell.productImg.kf_setImageWithURL(imageUrl!)
                            //productViewCell.productIcon.image = UIImage(data: imageData!)
                        //}
                    });
                }
                productViewCell.productTitle.text = post.title
                productViewCell.productPrice.text = String(stringInterpolationSegment: post.price)
            })
            
            return productViewCell;
        }
        
        print("Nothing found", terminator: "")
        return displayViewCell;
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("in selected view......", terminator: "")
        
        if (self.productsCollectionView == collectionView) {
            //tapped on specific product to go to detail page..
            
            let vController = self.storyboard?.instantiateViewControllerWithIdentifier("myProductView") as! ProductDetailsViewController
            print("User tapped on \(indexPath.row)", terminator: "");
            vController.productModel = self.products[indexPath.row]
            
            apiController.getProductDetails(String(Int(self.products[indexPath.row].id)))
            self.navigationController?.pushViewController(vController, animated: true)
            
            
        } else if(self.myCategoryCollectionView == collectionView) {
            //tapped on specific category item to show list of products within category
            
            let vController = self.storyboard?.instantiateViewControllerWithIdentifier("myCategoryDetailView") as! CategoryDetailsViewController
            
            vController.categories.id = self.categories[indexPath.row].id
            vController.categories.icon = self.categories[indexPath.row].icon
            vController.categories.name = self.categories[indexPath.row].name
            
            self.navigationController?.pushViewController(vController, animated: true)
        }
        
        print("User tapped on \(indexPath.row)", terminator: "");
    }
    
}
