//
//  SellProductsViewController.swift
//  babybox
//
//  Created by Mac on 09/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

class SellProductsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var collectionViewCellSize : CGSize?
    var collectionViewInsets : UIEdgeInsets?
    var reuseIdentifier = "CustomCell"
    var imageCollection = [AnyObject]()
    var selectedIndex :Int?
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    
        override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.loadDataSource()
        self.collectionView.reloadData()
            
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
            
    }
    
    func loadDataSource(){
        self.imageCollection = ["","","",""];
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageCollection.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CustomCollectionViewCell
        if(self.imageCollection[indexPath.row].isKindOfClass(UIImage)){
            let image = self.imageCollection[indexPath.row] as! UIImage
            cell.imageHolder.setBackgroundImage(image, forState: UIControlState.Normal)
        }else{
            let image = UIImage(named:"placeHolder")
            cell.imageHolder.setBackgroundImage(image, forState: UIControlState.Normal)
        }
        cell.imageHolder.tag = indexPath.row
        cell.imageHolder.addTarget(self, action:"choosePhotoOption:" , forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    //MARK: Button Action
    func choosePhotoOption(selectedButton: UIButton){
        self.selectedIndex = selectedButton.tag
        let optionMenu = UIAlertController(title: nil, message: "Take Photo:", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .Camera
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let photoGalleryAction = UIAlertAction(title: "Photo Album", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoGalleryAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    @IBAction func btnImageUpload(sender: AnyObject) {
        
        let mutableImageCollection = NSMutableArray(array: self.imageCollection)
        mutableImageCollection.removeObject("")
        self.imageCollection.removeAll(keepCapacity: true)
        self.imageCollection = mutableImageCollection as [AnyObject]
        
        /*SRWebClient.POST("Your Url to upload image")
            .data(self.imageCollection, fieldName: "Your Key to link Image", data: nil)
            .send({(response:AnyObject!, status:Int) -> Void in
                print(response)
                },failure:{(error:NSError!) -> Void in
                    print(error)
            })*/
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageCollection.removeAtIndex(selectedIndex!)
            self.imageCollection.insert(pickedImage, atIndex: selectedIndex!)
        }
        self.collectionView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }

}
