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
    
    var pageOffSet: Int = 0
    //@IBOutlet weak var productViewCell: ProductCollectionViewCell!
    @IBOutlet weak var poductImage: UIImageView!
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var myCategoryCollectionView: UICollectionView!
    var apiController: ApiControlller = ApiControlller()
    var currentIndex = 0
    var categories : [CategoryModel] = []
    var products: [PostModel] = []
    
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
        //sellProductsViewController
        
        /*let sellViewController = self.storyboard?.instantiateViewControllerWithIdentifier("sellProductsViewController") as? SellProductsViewController
        print(sellViewController)
        self.presentViewController(sellViewController!, animated: true, completion: nil)
        */
        self.performSegueWithIdentifier("sellProductView", sender: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        //self.navigationItem.rightBarButtonItem = getSellButton()
        self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.rightBarButtonItem = getSellButton()
        print("loaded HomePageLeftTabViewController", terminator: "")
        
        let layer:CALayer = self.productsCollectionView.layer
        layer.shadowOffset = CGSizeMake(1,1)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.8
        layer.shadowColor = UIColor.grayColor().CGColor
        
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
        self.currentIndex = indexPath.row
        
        if (self.productsCollectionView == collectionView) {
            //tapped on specific product to go to detail page..
            
            /*let vController = self.storyboard?.instantiateViewControllerWithIdentifier("myProductView") as! ProductDetailsViewController
            print("User tapped on \(indexPath.row)", terminator: "");
            vController.productModel = self.products[indexPath.row]
            
            apiController.getProductDetails(String(Int(self.products[indexPath.row].id)))
            self.navigationController?.pushViewController(vController, animated: true)*/
            self.performSegueWithIdentifier("gotoproductdetail", sender: nil)
            
        } else if(self.myCategoryCollectionView == collectionView) {
            //tapped on specific category item to show list of products within category
            
            /*let vController = self.storyboard?.instantiateViewControllerWithIdentifier("myCategoryDetailView") as! CategoryDetailsViewController
            
            vController.categories.id = self.categories[indexPath.row].id
            vController.categories.icon = self.categories[indexPath.row].icon
            vController.categories.name = self.categories[indexPath.row].name
            
            self.navigationController?.pushViewController(vController, animated: true)*/
            self.performSegueWithIdentifier("gotocatogorydetails", sender: nil)
        }
        
        print("User tapped on \(indexPath.row)", terminator: "");
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //var vController = segue.destinationViewController
        var identifier = segue.identifier
        let navigationController = segue.destinationViewController as! UINavigationController
        if (identifier == "gotocatogorydetails") {
            
            let vController = navigationController.viewControllers.first as! CategoryDetailsViewController
            vController.categories.id = self.categories[self.currentIndex].id
            vController.categories.icon = self.categories[self.currentIndex].icon
            vController.categories.name = self.categories[self.currentIndex].name
        } else if (identifier == "gotoproductdetail") {
            let vController = navigationController.viewControllers.first as! ProductDetailsViewController
            vController.productModel = self.products[self.currentIndex]
            
            apiController.getProductDetails(String(Int(self.products[self.currentIndex].id)))
        }
        
    }
    
}
