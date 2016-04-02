//
//  EditProductViewController.swift
//  babybox
//
//  Created by admin on 19/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class EditProductViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var postTitle: UITextField!
    @IBOutlet weak var prodDescription: UITextView!
    @IBOutlet weak var pricetxt: UITextField!
    @IBOutlet weak var categoryDropDown: UIButton!
    @IBOutlet weak var conditionDropDown: UIButton!
    @IBOutlet weak var deletePostBtn: UIButton!
    
    var postId: Int = 0
    var postItem: PostVM? = nil
    let categoryOptions = DropDown()
    let conditionTypeDropDown = DropDown()
    
    var save: String = ""
    var selectedIndex :Int?
    var selCategory: Int = -1
    
    var keyboardType: UIKeyboardType {
        get{
            return textFieldKeyboardType.keyboardType
        }
        set{
            if newValue != UIKeyboardType.NumberPad {
                self.keyboardType = UIKeyboardType.NumberPad
            }
        }
    }
    
    @IBOutlet weak var textFieldKeyboardType: UITextField!{
        didSet {
            //textFieldKeyboardType.keyboardType = UIKeyboardType.NumberPad
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewUtil.displayRoundedCornerView(self.deletePostBtn, bgColor: Color.GRAY)
        
        self.pricetxt.delegate = self
        self.pricetxt.keyboardType = .NumberPad
        
        self.postTitle.delegate = self
        //self.prodDescription.delegate = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "editProductSuccess") { result in
            NSLog("Product edited successfully")
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        SwiftEventBus.onMainThread(self, name: "editProductFailed") { result in
            self.view.makeToast(message: "Error when editing product", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
        }
        
        SwiftEventBus.onMainThread(self, name: "deletePostSuccess") { result in
            NSLog("Product deleted successfully")
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            UserInfoCache.decrementNumProducts()
            self.navigationController?.popToRootViewControllerAnimated(true)
                        
            // select and refresh my profile tab
            if let myProfileController = CustomTabBarController.selectProfileTab() {
                myProfileController.isRefresh = true
                myProfileController.currentIndex = nil
                myProfileController.feedLoader?.loading = false
                ViewUtil.makeToast("Congratulations! Product has been listed.", view: myProfileController.view)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "deletePostFailure") { result in
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            self.view.makeToast(message: "Error when deleting product")
        }
        
        self.conditionTypeDropDown.dataSource = [
            "-Select-",
            ViewUtil.PostConditionType.NEW_WITH_TAG.rawValue,
            ViewUtil.PostConditionType.NEW_WITHOUT_TAG.rawValue,
            ViewUtil.PostConditionType.USED.rawValue
        ]
        
        self.conditionTypeDropDown.selectionAction = { [unowned self] (index, item) in
            self.conditionDropDown.setTitle(item, forState: .Normal)
        }
        
        self.categoryOptions.selectionAction = { [unowned self] (index, item) in
            self.categoryDropDown.setTitle(item, forState: .Normal)
        }
        
        self.conditionTypeDropDown.anchorView = conditionDropDown
        self.conditionTypeDropDown.bottomOffset = CGPoint(x: 0, y:conditionDropDown.bounds.height)
        self.conditionTypeDropDown.direction = .Top
        self.categoryOptions.anchorView = categoryDropDown
        self.categoryOptions.bottomOffset = CGPoint(x: 0, y:conditionDropDown.bounds.height)
        self.categoryOptions.direction = .Top
        
        let saveProductImg: UIButton = UIButton()
        saveProductImg.setTitle("Save", forState: UIControlState.Normal)
        saveProductImg.addTarget(self, action: "saveProduct:", forControlEvents: UIControlEvents.TouchUpInside)
        saveProductImg.frame = CGRectMake(0, 0, 60, 35)
        let saveProductBarBtn = UIBarButtonItem(customView: saveProductImg)
        self.navigationItem.rightBarButtonItems = [saveProductBarBtn]
        
        ViewUtil.showActivityLoading(self.activityLoading)
        ApiFacade.getPost(self.postId, successCallback: onSuccessGetPost, failureCallback: onFailureGetPost)
        
    }
    
    func initEditView() {
        NSLog("Edit \((self.postItem?.title)!)")
        
        self.postTitle.text = self.postItem?.title
        self.prodDescription.text = self.postItem?.body
        self.pricetxt.text = String(Int((self.postItem?.price)!))
        self.selCategory = (self.postItem?.categoryId)!
        initCategoryOptions()
        
        let conditionLbl = ViewUtil.parsePostConditionTypeFromType((self.postItem?.conditionType)!)
        self.conditionDropDown.setTitle(conditionLbl, forState: UIControlState.Normal)
        
        ViewUtil.hideActivityLoading(self.activityLoading)
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
        
        self.categoryDropDown.setTitle(selCategoryValue, forState: UIControlState.Normal)
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
    
    func saveProduct(sender: AnyObject) {
        if (self.postItem == nil) {
            return
        }
        
        if (validateSaveForm()) {
            ViewUtil.showGrayOutView(self, activityLoading: self.activityLoading)
            let category = CategoryCache.getCategoryByName(categoryDropDown.titleLabel!.text!)
            let conditionType = ViewUtil.parsePostConditionTypeFromValue(conditionDropDown.titleLabel!.text!)
            ApiController.instance.editPost(self.postId, title: ViewUtil.trim(postTitle.text!), body: ViewUtil.trim(prodDescription.text!), catId: category!.id, conditionType: String(conditionType), pricetxt: ViewUtil.trim(pricetxt.text!))
        }
    }
    
    func validateSaveForm() -> Bool {
        var isValidated = true
        
        if self.postTitle.text == nil || ViewUtil.trim(self.postTitle.text!).isEmpty {
            self.view.makeToast(message: "Please fill title", duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        } else if self.prodDescription.text == nil || ViewUtil.trim(self.prodDescription.text!).isEmpty {
            self.view.makeToast(message: "Please fill description", duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        } else if self.pricetxt.text == nil || ViewUtil.trim(self.pricetxt.text!).isEmpty {
            self.view.makeToast(message: "Please enter a price", duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        } else if self.conditionDropDown.titleLabel?.text == nil || self.conditionDropDown.titleLabel?.text == "-Select-" {
            self.view.makeToast(message: "Please select condition type", duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        } else if self.categoryDropDown.titleLabel!.text == nil || self.categoryDropDown.titleLabel!.text == "Choose a Category:" {
            self.view.makeToast(message: "Please select category", duration: ViewUtil.SHOW_TOAST_DURATION_LONG, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        }
        
        return isValidated
    }
    
    func handleNotificationSuccess(notifcationCounter: NotificationCounterVM) {
        
    }
    
    func handleNotificationError(message: String) {
        NSLog(message)
    }
    
    @IBAction func deletePost(sender: AnyObject) {
        let _confirmDialog = UIAlertController(title: "Delete Product", message: "Are you sure to delete?", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil)
        
        let confirmAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            ViewUtil.showGrayOutView(self, activityLoading: self.activityLoading)
            ApiController.instance.deletePost(self.postId)
        })
        
        _confirmDialog.addAction(okAction)
        _confirmDialog.addAction(confirmAction)
        self.presentViewController(_confirmDialog, animated: true, completion: nil)
    }
    
    func onSuccessGetPost(post: PostVM) {
        ViewUtil.hideActivityLoading(self.activityLoading)
        self.postItem = post
        self.initEditView()
    }
    
    func onFailureGetPost(error: String) -> Void {
        self.view.makeToast(message: "Error getting Product.")
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
}
