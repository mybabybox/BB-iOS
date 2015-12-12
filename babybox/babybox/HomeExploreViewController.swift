//
//  ViewController.swift
//  GallerySwiftApp
//
//  Created by Apple on 11/12/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit
import SwiftEventBus
import Kingfisher

class HomeExploreViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var reuseIdentifier = "CellType1"
    
    var pageOffSet: Int = 0
    var apiController: ApiControlller = ApiControlller()
    var currentIndex = 0
    var categories : [CategoryModel] = []
    var products: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
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
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    print(imageUrl)
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
                cell.productPrice.text = String(stringInterpolationSegment: post.price)
            })
            
            //cell.prodImageIns.addTarget(self, action: "ImagePressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeImageIns.addTarget(self, action: "HeartPressed:", forControlEvents: UIControlEvents.TouchUpInside)
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
            
            reusableView = headerView
        }
        return reusableView!
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (collectionView.tag == 2){
            return CGSize(width: 96, height: 96)
        }else{
            return CGSize(width: 132, height: 170)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (collectionView.tag == 2){
            return CGSizeZero
        }else{
            return CGSizeMake(self.view.frame.width, 225.0)
        }
    }
    
    func HeartPressed(button: UIButton){
        let message = String(format:"Selected Cell: %d", button.tag)
        let alertController = UIAlertController(title: "Heart Pressed", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func ImagePressed(button: UIButton){
        let message = String(format:"Selected Cell: %d", button.tag)
        let alertController = UIAlertController(title: "ImagePressed", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
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
        print("got all products...", terminator: "");
        self.products = resultDto
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
            print("reloaded the collection view.", terminator: "")
        })
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

