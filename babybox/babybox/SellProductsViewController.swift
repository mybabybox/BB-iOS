//
//  SellProductsViewController.swift
//  babybox
//
//  Created by Mac on 09/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import ALCameraViewController

class SellProductsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var hrBarHtConstraint: UIView!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var sellingtext: UITextField!
    @IBOutlet weak var collectionViewHtConstraint: NSLayoutConstraint!
    @IBOutlet var categorydropdown: UIButton!
    @IBOutlet var conditionDropDown: UIButton!
    @IBOutlet weak var prodDescription: UITextView!
    @IBOutlet var pricetxt: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let categoryOptions = DropDown()
    let conditionTypeDropDown = DropDown()
    
    var save: String = ""
    var collectionViewCellSize : CGSize?
    var collectionViewInsets : UIEdgeInsets?
    var reuseIdentifier = "CustomCell"
    var imageCollection = [AnyObject]()
    var selectedIndex :Int? = 0
    var selCategory: Int = -1
    let croppingEnabled: Bool = true
    let libraryEnabled: Bool = true
    
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
        self.loadDataSource()
        self.pricetxt.delegate = self
        self.pricetxt.keyboardType = .NumberPad
        
        self.sellingtext.delegate = self
        //self.prodDescription.delegate = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        SwiftEventBus.onMainThread(self, name: "newProductSuccess") { result in
            // UI thread
            NSLog("Product Saved Successfully")
            self.view.makeToast(message: "Product Added Successfully", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            NotificationCounter.mInstance.refresh(self.handleNotificationSuccess, failureCallback: self.handleNotificationError)
            //UserInfoCache.refresh(AppDelegate.getInstance().sessionId!, successCallback: self.handleUserInfoSuccess, failureCallback: self.handleError)
            UserInfoCache.incrementNumProducts()
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        SwiftEventBus.onMainThread(self, name: "newProductFailed") { result in
            // UI thread
            NSLog("Product Saved Successfully")
            self.view.makeToast(message: "Error Saving product", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
        }
        
        initCategoryOptions()
        
        self.conditionTypeDropDown.dataSource = [
            "-Select-",
            ViewUtil.PostConditionType.NEW_WITH_TAG.rawValue,
            ViewUtil.PostConditionType.NEW_WITHOUT_TAG.rawValue,
            ViewUtil.PostConditionType.USED.rawValue
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
        
        /*NSNotificationCenter.defaultCenter().addObserverForName("CroppedImage", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.imageCollection.removeAtIndex(self.selectedIndex!)
            self.imageCollection.insert(notification.object!, atIndex: self.selectedIndex!)
            self.collectionView.reloadData()
        }*/

        self.collectionView.reloadData()
        
        let saveProductImg: UIButton = UIButton()
        saveProductImg.setTitle("Save", forState: UIControlState.Normal)
        saveProductImg.addTarget(self, action: "saveProduct:", forControlEvents: UIControlEvents.TouchUpInside)
        saveProductImg.frame = CGRectMake(0, 0, 60, 35)
        let saveProductBarBtn = UIBarButtonItem(customView: saveProductImg)
        self.navigationItem.rightBarButtonItems = [saveProductBarBtn]
        
    }
        
    func initCategoryOptions() {
        let categories = CategoryCache.categories
        var selCategoryValue = "Choose a Category:"
        var catDataSource : [String] = []
        for (var i = 0; i < categories.count; i++) {
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
        self.imageCollection = ["","","",""]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.imageCollection[indexPath.row] = ""
        self.collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    //MARK: Button Action
    func choosePhotoOption(selectedButton: UIButton){
        let view = selectedButton.superview!
        let cell = view.superview! as! CustomCollectionViewCell
        
        let indexPath = self.collectionView.indexPathForCell(cell)!
        self.imageCollection[indexPath.row] = ""
        self.collectionView.reloadItemsAtIndexPaths([indexPath])
        
        self.selectedIndex = selectedButton.tag
        
        let optionMenu = UIAlertController(title: "Select Photo:", message: "", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let cameraViewController = ALCameraViewController(croppingEnabled: self.croppingEnabled, allowsLibraryAccess: self.libraryEnabled) { (image) -> Void in
                self.imageCollection.removeAtIndex(self.selectedIndex!)
                self.imageCollection.insert(image!, atIndex: self.selectedIndex!)
                self.collectionView.reloadData()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            self.presentViewController(cameraViewController, animated: true, completion: nil)
        })
        let photoGalleryAction = UIAlertAction(title: "Photo Album", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let libraryViewController = ALCameraViewController.imagePickerViewController(self.croppingEnabled) { (image) -> Void in
                self.imageCollection.removeAtIndex(self.selectedIndex!)
                self.imageCollection.insert(image!, atIndex: self.selectedIndex!)
                self.collectionView.reloadData()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.presentViewController(libraryViewController, animated: true, completion: nil)
            
            //self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            optionMenu.addAction(cameraAction)
        }
        optionMenu.addAction(photoGalleryAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    func setCollectionViewSizesInsets() {
        let availableWidthForCells:CGFloat = self.view.bounds.width - 35
        let cellWidth :CGFloat = availableWidthForCells / 4
        collectionViewCellSize = CGSizeMake(cellWidth, cellWidth)
        self.collectionViewHtConstraint.constant = cellWidth + 5
    }
    
    
    // MARK: UIImagePickerControllerDelegate Methods
    
    /*func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let controller = ImageCropViewController.init(image: pickedImage)
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
        dismissViewControllerAnimated(true, completion: nil)
    }*/
    
    /*func handleCroppedImage(notification: NSNotification){
        self.imageCollection.removeAtIndex(selectedIndex!)
        self.imageCollection.insert(notification.object!, atIndex: selectedIndex!)
        self.collectionView.reloadData()
        
    }*/
    
    func saveProduct(sender: AnyObject) {
        if (validateSaveForm()) {
            let category = CategoryCache.getCategoryByName(categorydropdown.titleLabel!.text!)
            let conditionType = ViewUtil.parsePostConditionTypeFromValue(conditionDropDown.titleLabel!.text!)
            ApiController.instance.newProduct(sellingtext.text!, body: prodDescription.text!, catId: category!.id, conditionType: String(conditionType), pricetxt: pricetxt.text!, imageCollection: self.imageCollection)
        }
    }
    
    func validateSaveForm() -> Bool {
        var isValidated = true
        var isImageUploaded = false
        for _image in imageCollection {
            if let _ = _image as? String {
            } else {
                if let image: UIImage? = _image as? UIImage {
                    if (image != nil) {
                        isImageUploaded = true
                        break
                    }
                }
            }
        }
                
        if (!isImageUploaded) {
            self.view.makeToast(message: "Please Upload Photo", duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        } else if (self.sellingtext.text == nil || self.sellingtext.text == "" ) {
            self.view.makeToast(message: "Please fill title", duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        } else if (self.prodDescription.text == nil || self.prodDescription.text == "") {
            self.view.makeToast(message: "Please fill description", duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        } else if (self.pricetxt.text == nil || self.pricetxt.text == "") {
            self.view.makeToast(message: "Please enter a price", duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        } else if (self.conditionDropDown.titleLabel?.text == nil || self.conditionDropDown.titleLabel?.text == "-Select-") {
            self.view.makeToast(message: "Please select condition type", duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        } else if (self.categorydropdown.titleLabel!.text == nil || self.categorydropdown.titleLabel!.text == "Choose a Category:") {
            self.view.makeToast(message: "Please select category", duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        }
        
        return isValidated
    }
    
    /*func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        textField.keyboardType = UIKeyboardType.NumberPad
        return Int(string) != nil
    }*/
    
    func handleNotificationSuccess(notifcationCounter: NotificationCounterVM) {
        
    }
    
    func handleNotificationError(message: String) {
        NSLog(message)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK:- Notification
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            //self.buttomLayoutConstraint = keyboardFrame.size.height
            }) { (completed: Bool) -> Void in
                
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            }) { (completed: Bool) -> Void in
                
        }
    }
}
