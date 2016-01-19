//
//  SellProductsViewController.swift
//  babybox
//
//  Created by Mac on 09/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class SellProductsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var actionButton: UIButton!
    let conditionTypeDropDown = DropDown()
    @IBOutlet var sellingtext: UITextField!
    var categories : [CategoryModel] = []
    
    var save:String = "";
    
    @IBOutlet var categotytext: UITextField!
   
    @IBOutlet var setpricetxt: UITextField!
    @IBOutlet var conditiontxt: UITextField!
    @IBOutlet var categorydropdown: UIButton!
    @IBOutlet var selectdropdown: UIButton!
    @IBOutlet var actionButton1: UIButton!
    @IBOutlet var categorytxt: NSLayoutConstraint!
    let categoryOptions = DropDown()
    @IBOutlet var pricetxt: UITextField!
    @IBOutlet var producttxt: UITextField!
    var collectionViewCellSize : CGSize?
    var collectionViewInsets : UIEdgeInsets?
    var reuseIdentifier = "CustomCell"
    var imageCollection = [AnyObject]()
    var selectedIndex :Int?
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    
    var keyboardType: UIKeyboardType {
        get{
            return textFieldKeyboardType.keyboardType
        }
        set{
            if newValue != UIKeyboardType.NumberPad{
                self.keyboardType = UIKeyboardType.NumberPad
            }
        }
    }
    
    @IBOutlet weak var textFieldKeyboardType: UITextField!{
        didSet{
            textFieldKeyboardType.keyboardType = UIKeyboardType.NumberPad
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.loadDataSource()
        setCollectionViewSizesInsets();
            
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        ApiControlller.apiController.getAllCategories();
        
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedSuccess") { result in
            // UI thread
            let resultDto: [CategoryModel] = result.object as! [CategoryModel]
            self.handleGetCateogriesSuccess(resultDto)
        }
        
        self.conditionTypeDropDown.dataSource = [
            "-Select-",
            "New(Sealed/with tags)",
            "New(unsealed/without tags)",
            "Used"
        ]
        
        self.conditionTypeDropDown.selectionAction = { [unowned self] (index, item) in
            self.actionButton.setTitle(item, forState: .Normal)
        }
        
        self.categoryOptions.selectionAction = { [unowned self] (index, item) in
            self.actionButton1.setTitle(item, forState: .Normal)
        }
        
        self.conditionTypeDropDown.anchorView = actionButton
        self.conditionTypeDropDown.bottomOffset = CGPoint(x: 0, y:actionButton.bounds.height)
        self.conditionTypeDropDown.direction = .Top
        self.categoryOptions.anchorView=actionButton1
        self.categoryOptions.bottomOffset = CGPoint(x: 0, y:actionButton.bounds.height)
        self.categoryOptions.direction = .Top
        
        
        NSNotificationCenter.defaultCenter().addObserverForName("CroppedImage", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.imageCollection.removeAtIndex(self.selectedIndex!)
            self.imageCollection.insert(notification.object!, atIndex: self.selectedIndex!)
            self.collectionView.reloadData()
        }

        self.collectionView.reloadData()
        
    }
        
    func handleGetCateogriesSuccess(categories: [CategoryModel]) {
        self.categories = categories;
        var x : [String] = []
        for (var i = 0 ; i < categories.count ; i++) {
            x.append(categories[i].description)
        }
        
        self.categoryOptions.dataSource = x
        dispatch_async(dispatch_get_main_queue(), {
            self.categoryOptions.reloadAllComponents()
        })

    }

    @IBAction func ShoworDismiss(sender: AnyObject) {
        
        if self.conditionTypeDropDown.hidden {
            self.conditionTypeDropDown.show()
        } else {
            self.conditionTypeDropDown.hide()
        }
    }

    @IBAction func categorySellDropDown(sender: AnyObject) {
        
        if self.categoryOptions.hidden {
            self.categoryOptions.show()
        } else {
            self.categoryOptions.hide()
        }
    }
    
    @IBOutlet var sssss: UIButton!
    func loadDataSource(){
        self.imageCollection = ["cat_toys","cat_utils","cat_toys","cat_toys"];
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        
        ApiControlller.apiController.savesell(producttxt.text!,sellingtext: sellingtext.text!, ActionButton1: (categorydropdown.titleLabel?.text!)!,ActionButton: (selectdropdown.titleLabel?.text!)!,setpricetxt: setpricetxt.text!);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
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
            let image = UIImage(named:"cat_toys")
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
        
        SRWebClient.POST("Your Url to upload image")
            .data(self.imageCollection, fieldName: "Your Key to link Image", data: nil)
            .send({(response:AnyObject!, status:Int) -> Void in
            },failure:{(error:NSError!) -> Void in
                    print(error)
            })
    }
    
    func setCollectionViewSizesInsets() {
        let availableWidthForCells:CGFloat = self.view.bounds.width - 15
        let cellWidth :CGFloat = availableWidthForCells / 4
        let cellHeight = cellWidth * 4/3
        collectionViewCellSize = CGSizeMake(cellWidth, 750)
    }
        
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
             let controller = ImageCropViewController.init(image: pickedImage)
            self.navigationController?.pushViewController(controller, animated: true)

            self.imageCollection.removeAtIndex(selectedIndex!)
            self.imageCollection.insert(pickedImage, atIndex: selectedIndex!)
        }
        self.collectionView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func handleCroppedImage(notification: NSNotification){
        self.imageCollection.removeAtIndex(selectedIndex!)
        self.imageCollection.insert(notification.object!, atIndex: selectedIndex!)
        self.collectionView.reloadData()
        
    }

}
