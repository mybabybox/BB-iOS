//
//  NewProductViewController.swift
//  babybox
//
//  Created by Mac on 09/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import QQPlaceholderTextView

class NewProductViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var hrBarHtConstraint: UIView!
    @IBOutlet weak var sellingtext: UITextField!
    @IBOutlet weak var collectionViewHtConstraint: NSLayoutConstraint!
    @IBOutlet weak var prodDescription: UITextView!
    @IBOutlet weak var pricetxt: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryDropDown: UIButton!
    @IBOutlet weak var conditionDropDown: UIButton!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    
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
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
        self.navigationController?.interactivePopGestureRecognizer!.enabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer!.enabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadDataSource()
        self.pricetxt.delegate = self
        self.pricetxt.keyboardType = .NumberPad
        
        self.prodDescription.placeholder = NSLocalizedString("product_desc", comment: "")
        self.prodDescription.isApplyTextFieldStyle = true
        self.prodDescription.layer.borderWidth = 0
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        self.sellingtext.delegate = self
        //self.prodDescription.delegate = self
        
        self.view.backgroundColor = Color.FEED_BG
        
        ViewUtil.setCustomBackButton(self, action: "onBackPressed:")
        
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "newProductSuccess") { result in
            NSLog("New product created successfully")
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            UserInfoCache.incrementNumProducts()
            self.navigationController?.popToRootViewControllerAnimated(true)
            
            // select and refresh my profile tab
            if let myProfileController = CustomTabBarController.selectProfileTab() {
                myProfileController.isRefresh = true
                myProfileController.currentIndex = nil
                myProfileController.feedLoader?.loading = false
                ViewUtil.makeToast(NSLocalizedString("product_listed_msg", comment: ""), view: myProfileController.view)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "newProductFailed") { result in
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            self.view.makeToast(message: NSLocalizedString("error_listing_prod", comment: ""), duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
        }
        
        initCategoryOptions()
        
        initConditionTypes()
        
        self.conditionTypeDropDown.anchorView = conditionDropDown
        self.conditionTypeDropDown.bottomOffset = CGPoint(x: 0, y: conditionDropDown.bounds.height)
        self.conditionTypeDropDown.direction = .Top
        self.categoryOptions.anchorView = categoryDropDown
        self.categoryOptions.bottomOffset = CGPoint(x: 0, y: conditionDropDown.bounds.height)
        self.categoryOptions.direction = .Top
        
        self.setCollectionViewSizesInsets()
        
        self.collectionView.reloadData()
        
        let saveProductImg: UIButton = UIButton()
        saveProductImg.setTitle(NSLocalizedString("save", comment: ""), forState: UIControlState.Normal)
        saveProductImg.addTarget(self, action: "saveProduct:", forControlEvents: UIControlEvents.TouchUpInside)
        saveProductImg.frame = CGRectMake(0, 0, 60, 35)
        let saveProductBarBtn = UIBarButtonItem(customView: saveProductImg)
        self.navigationItem.rightBarButtonItems = [saveProductBarBtn]
    }
        
    func initCategoryOptions() {
        let categories = CategoryCache.categories
        var selCategoryValue = NSLocalizedString("choose_category", comment: "")
        var catDataSource : [String] = []
        for i in 0 ..< categories.count {
            catDataSource.append(categories[i].description)
            if (Int(categories[i].id) == self.selCategory) {
                selCategoryValue = categories[i].description
            }
        }
        
        self.categoryOptions.dataSource = catDataSource
        dispatch_async(dispatch_get_main_queue(), {
            self.categoryOptions.reloadAllComponents()
        })
        
        self.categoryDropDown.setTitle(selCategoryValue, forState: UIControlState.Normal)

        self.categoryOptions.selectionAction = { [unowned self] (index, item) in
            self.categoryDropDown.setTitle(item, forState: .Normal)
        }
    }
    
    func initConditionTypes() {
        self.conditionTypeDropDown.dataSource = [
            ViewUtil.PostConditionType.NEW_WITH_TAG.rawValue,
            ViewUtil.PostConditionType.NEW_WITHOUT_TAG.rawValue,
            ViewUtil.PostConditionType.USED.rawValue
        ]
        
        dispatch_async(dispatch_get_main_queue(), {
            self.conditionTypeDropDown.reloadAllComponents()
        })
        
        self.conditionDropDown.setTitle(NSLocalizedString("select", comment: ""), forState: UIControlState.Normal)
        
        self.conditionTypeDropDown.selectionAction = { [unowned self] (index, item) in
            self.conditionDropDown.setTitle(item, forState: .Normal)
        }
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
        if self.imageCollection[indexPath.row].isKindOfClass(UIImage) {
            let image = self.imageCollection[indexPath.row] as! UIImage
            cell.imageHolder.setBackgroundImage(image, forState: UIControlState.Normal)
        } else {
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
        
        let optionMenu = UIAlertController(title: NSLocalizedString("select_photo", comment: ""), message: "", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("camera", comment: ""), style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let cameraViewController = ALCameraViewController(croppingEnabled: self.croppingEnabled, allowsLibraryAccess: self.libraryEnabled) { (image) -> Void in
                if (image != nil) {
                    self.imageCollection.removeAtIndex(self.selectedIndex!)
                    self.imageCollection.insert(image!.retainOrientation(), atIndex: self.selectedIndex!)
                    self.collectionView.reloadData()
                    
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            self.presentViewController(cameraViewController, animated: true, completion: nil)
        })
        let photoGalleryAction = UIAlertAction(title: "Photo Album", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let libraryViewController = ALCameraViewController.imagePickerViewController(self.croppingEnabled) { (image) -> Void in
                if (image != nil) {
                    self.imageCollection.removeAtIndex(self.selectedIndex!)
                    self.imageCollection.insert(image!.retainOrientation(), atIndex: self.selectedIndex!)
                    self.collectionView.reloadData()
                    
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.presentViewController(libraryViewController, animated: true, completion: nil)
            
            //self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: {
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
    
    func saveProduct(sender: AnyObject) {
        if (isValid()) {
            ViewUtil.showGrayOutView(self, activityLoading: self.activityLoading)
            let category = CategoryCache.getCategoryByName(categoryDropDown.titleLabel!.text!)
            let conditionType = ViewUtil.parsePostConditionTypeFromValue(conditionDropDown.titleLabel!.text!)
            ApiController.instance.newPost(StringUtil.trim(sellingtext.text), body: StringUtil.trim(prodDescription.text), catId: category!.id, conditionType: String(conditionType), pricetxt: StringUtil.trim(pricetxt.text), imageCollection: self.imageCollection)
        }
    }
    
    func isValid() -> Bool {
        var valid = true
        
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
                
        if !isImageUploaded {
            self.view.makeToast(message: NSLocalizedString("upload_photo", comment: ""), duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        } else if StringUtil.trim(self.sellingtext.text).isEmpty {
            self.view.makeToast(message: NSLocalizedString("fill_title", comment: ""), duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        } else if StringUtil.trim(self.prodDescription.text).isEmpty {
            self.view.makeToast(message: NSLocalizedString("fill_desc", comment: ""), duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        } else if StringUtil.trim(self.pricetxt.text).isEmpty {
            self.view.makeToast(message: NSLocalizedString("fill_price", comment: ""), duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        } else if !ViewUtil.isDropDownSelected(self.conditionTypeDropDown) {
            self.view.makeToast(message: NSLocalizedString("fill_condition", comment: ""), duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        } else if !ViewUtil.isDropDownSelected(self.categoryOptions) {
            self.view.makeToast(message: NSLocalizedString("fill_category", comment: ""), duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        }
        return valid
    }
    
    func handleNotificationSuccess(notifcationCounter: NotificationCounterVM) {
        
    }
    
    func handleNotificationError(message: String) {
        NSLog(message)
    }
    
    func onBackPressed(sender: UIBarButtonItem) {
        NSLog("on back pressed.")
        
        let _confirmDialog = UIAlertController(title: NSLocalizedString("discard_changes", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Default, handler: nil)
        
        let confirmAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popViewControllerAnimated(true)
        })
        
        _confirmDialog.addAction(okAction)
        _confirmDialog.addAction(confirmAction)
        self.presentViewController(_confirmDialog, animated: true, completion: nil)
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
        let _: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
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
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
