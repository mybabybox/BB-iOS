//
//  SellProductsViewController.swift
//  babybox
//
//  Created by Mac on 09/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class SellProductsViewController: UIViewController, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var hrBarHtConstraint: UIView!
    @IBOutlet var actionButton: UIButton!
    let conditionTypeDropDown = DropDown()
    @IBOutlet var sellingtext: UITextField!
    var categories : [CategoryModel] = []
    
    var save:String = "";
    
    @IBOutlet weak var collectionViewHtConstraint: NSLayoutConstraint!
    @IBOutlet var categorydropdown: UIButton!
    @IBOutlet var conditionDropDown: UIButton!
    
    @IBOutlet weak var prodDescription: UITextView!
    let categoryOptions = DropDown()
    @IBOutlet var pricetxt: UITextField!
    var collectionViewCellSize : CGSize?
    var collectionViewInsets : UIEdgeInsets?
    var reuseIdentifier = "CustomCell"
    var imageCollection = [AnyObject]()
    var selectedIndex :Int?
    @IBOutlet weak var collectionView: UICollectionView!
    var selCategory: Int = -1
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

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        ApiControlller.apiController.getAllCategories();
        
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedSuccess") { result in
            // UI thread
            let resultDto: [CategoryModel] = result.object as! [CategoryModel]
            self.handleGetCateogriesSuccess(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "productSavedSuccess") { result in
            // UI thread
            NSLog("Product Saved Successfully")
            self.view.makeToast(message: "Product Added Successfully", duration: 1.0, position: "bottom")
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        SwiftEventBus.onMainThread(self, name: "productSavedFailed") { result in
            // UI thread
            NSLog("Product Saved Successfully")
            self.view.makeToast(message: "Error Saving product", duration: 0.5, position: "bottom")
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
            self.categorydropdown.setTitle(item, forState: .Normal)
        }
        
        self.conditionTypeDropDown.anchorView = actionButton
        self.conditionTypeDropDown.bottomOffset = CGPoint(x: 0, y:actionButton.bounds.height)
        self.conditionTypeDropDown.direction = .Top
        self.categoryOptions.anchorView=categorydropdown
        self.categoryOptions.bottomOffset = CGPoint(x: 0, y:actionButton.bounds.height)
        self.categoryOptions.direction = .Top
        
        self.setCollectionViewSizesInsets()
        
        NSNotificationCenter.defaultCenter().addObserverForName("CroppedImage", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.imageCollection.removeAtIndex(self.selectedIndex!)
            self.imageCollection.insert(notification.object!, atIndex: self.selectedIndex!)
            self.collectionView.reloadData()
        }

        self.collectionView.reloadData()
        
        let saveProductImg: UIButton = UIButton()
        saveProductImg.setTitle("Save", forState: UIControlState.Normal)
        saveProductImg.addTarget(self, action: "saveProduct:", forControlEvents: UIControlEvents.TouchUpInside)
        saveProductImg.frame = CGRectMake(0, 0, 60, 35)
        let saveProductBarBtn = UIBarButtonItem(customView: saveProductImg)
        self.navigationItem.rightBarButtonItems = [saveProductBarBtn]
        
    }
        
    func handleGetCateogriesSuccess(categories: [CategoryModel]) {
        self.categories = categories;
        var selCategoryValue = "Choose a Category:"
        var catDataSource : [String] = []
        for (var i = 0 ; i < categories.count ; i++) {
            catDataSource.append(categories[i].description)
            if (Int(categories[i].id) == self.selCategory) {
                selCategoryValue = categories[i].description
            }
        }
        
        self.categoryOptions.dataSource = catDataSource
        dispatch_async(dispatch_get_main_queue(), {
            self.categoryOptions.reloadAllComponents()
        })
        
        self.categorydropdown.setTitle(selCategoryValue, forState: UIControlState.Normal)
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
    
    func loadDataSource(){
        self.imageCollection = ["","","",""];
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            let image = UIImage(named:"img_camera")
            cell.imageHolder.setBackgroundImage(image, forState: UIControlState.Normal)
        }
        
        cell.imageHolder.tag = indexPath.row
        cell.imageHolder.addTarget(self, action:"choosePhotoOption:" , forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let _ = collectionViewCellSize {
            return collectionViewCellSize!
        }
        return CGSizeZero
    }
    
    
    //MARK: Button Action
    func choosePhotoOption(selectedButton: UIButton) {
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
            
            self.navigationController!.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoGalleryAction)
        optionMenu.addAction(cancelAction)
        self.navigationController!.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    func setCollectionViewSizesInsets() {
        let availableWidthForCells:CGFloat = self.view.bounds.width - 35
        let cellWidth :CGFloat = availableWidthForCells / 4
        collectionViewCellSize = CGSizeMake(cellWidth, cellWidth)
        self.collectionViewHtConstraint.constant = cellWidth + 5
    }
        
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
             let controller = ImageCropViewController.init(image: pickedImage)
            self.navigationController?.pushViewController(controller, animated: true)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleCroppedImage(notification: NSNotification) {
        self.imageCollection.removeAtIndex(selectedIndex!)
        self.imageCollection.insert(notification.object!, atIndex: selectedIndex!)
        self.collectionView.reloadData()
    }
    
    
    func saveProduct(sender: AnyObject) {
        
        //Validate whether all values are selected by user...
        var selCategoryId: String = ""
        //iterate through categories to get the selected category as only name are shown in dropdown.
        for category in self.categories as [CategoryModel] {
            if (category.description == (categorydropdown.titleLabel?.text!)!) {
                selCategoryId = String(category.id)
            }
        }
        
        if (validateSaveForm()) {
            ApiControlller.apiController.saveSellProduct(prodDescription.text!,sellingtext: sellingtext.text!, categoryId: selCategoryId,conditionType: (conditionDropDown.titleLabel?.text!)!, pricetxt: pricetxt.text!, imageCollection: self.imageCollection);
        }
    }
    
    func validateSaveForm() -> Bool {
        var isValidated = true
        var isImageUploaded = false
        for _image in imageCollection {
            if let str = _image as? String {
            } else {
                if let image: UIImage? = _image as? UIImage {
                    if (image != nil) {
                        isImageUploaded = true
                        break
                    }
                }
            }
        }
        
        print(self.conditionDropDown.titleLabel?.text)
        print(self.categorydropdown.titleLabel!.text)
        
        if (!isImageUploaded) {
            self.view.makeToast(message: "Please Upload Photo", duration: 1.5, position: "bottom")
            isValidated = false
        } else if (self.sellingtext.text == nil || self.sellingtext.text == "" ) {
            self.view.makeToast(message: "Please fill title", duration: 1.5, position: "bottom")
            isValidated = false
        } else if (self.prodDescription.text == nil || self.prodDescription.text == "") {
            self.view.makeToast(message: "Please fill description", duration: 1.5, position: "bottom")
            isValidated = false
        } else if (self.pricetxt.text == nil || self.pricetxt.text == "") {
            self.view.makeToast(message: "Please enter a price", duration: 1.5, position: "bottom")
            isValidated = false
        } else if (self.conditionDropDown.titleLabel?.text == nil || self.conditionDropDown.titleLabel?.text == "-Select-") {
            self.view.makeToast(message: "Please select condition type", duration: 1.5, position: "bottom")
            isValidated = false
        } else if (self.categorydropdown.titleLabel!.text == nil || self.categorydropdown.titleLabel!.text == "Choose a Category:") {
            self.view.makeToast(message: "Please select category", duration: 1.5, position: "bottom")
            isValidated = false
        }
        
        return isValidated
    }

}
