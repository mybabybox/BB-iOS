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
    @IBOutlet var postTitle: UITextField!
    @IBOutlet weak var prodDescription: UITextView!
    @IBOutlet var pricetxt: UITextField!
    @IBOutlet var categorydropdown: UIButton!
    @IBOutlet var conditionDropDown: UIButton!
    
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
        didSet{
            //textFieldKeyboardType.keyboardType = UIKeyboardType.NumberPad
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewUtil.showActivityLoading(self.activityLoading)
        self.pricetxt.delegate = self
        self.pricetxt.keyboardType = .NumberPad
        
        self.postTitle.delegate = self
        //self.prodDescription.delegate = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        SwiftEventBus.onMainThread(self, name: "postByIdLoadSuccess") { result in
            // UI thread
            SwiftEventBus.unregister("postByIdLoadSuccess")
            if ViewUtil.isEmptyResult(result, message: "Product not found. It may be deleted by seller.", view: self.view) {
                ViewUtil.hideActivityLoading(self.activityLoading)
                return
            }
            self.postItem = result.object as? PostVM
            self.initEditView()
            
        }
        
        SwiftEventBus.onMainThread(self, name: "postByIdLoadFailure") { result in
            // UI thread
            SwiftEventBus.unregister("postByIdLoadSuccess")
            self.view.makeToast(message: "Error getting Post data.")
            ViewUtil.hideActivityLoading(self.activityLoading)
        }
        
        SwiftEventBus.onMainThread(self, name: "editProductSuccess") { result in
            // UI thread
            NSLog("Product Saved Successfully")
            self.view.makeToast(message: "Product Updated Successfully", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            NotificationCounter.mInstance.refresh(self.handleNotificationSuccess, failureCallback: self.handleNotificationError)
            //self.navigationController?.popViewControllerAnimated(true)
        }
        
        SwiftEventBus.onMainThread(self, name: "editProductFailed") { result in
            // UI thread
            NSLog("Product Saved Successfully")
            self.view.makeToast(message: "Error Saving product", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
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
            self.categorydropdown.setTitle(item, forState: .Normal)
        }
        
        self.conditionTypeDropDown.anchorView = conditionDropDown
        self.conditionTypeDropDown.bottomOffset = CGPoint(x: 0, y:conditionDropDown.bounds.height)
        self.conditionTypeDropDown.direction = .Top
        self.categoryOptions.anchorView=categorydropdown
        self.categoryOptions.bottomOffset = CGPoint(x: 0, y:conditionDropDown.bounds.height)
        self.categoryOptions.direction = .Top
        
        let saveProductImg: UIButton = UIButton()
        saveProductImg.setTitle("Save", forState: UIControlState.Normal)
        saveProductImg.addTarget(self, action: "saveProduct:", forControlEvents: UIControlEvents.TouchUpInside)
        saveProductImg.frame = CGRectMake(0, 0, 60, 35)
        let saveProductBarBtn = UIBarButtonItem(customView: saveProductImg)
        self.navigationItem.rightBarButtonItems = [saveProductBarBtn]
        
        ApiController.instance.getPostById(self.postId)
    }
    
    func initEditView() {
        //
        print(self.postItem?.title)
        
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
            let category = CategoryCache.getCategoryByName(categorydropdown.titleLabel!.text!)
            let conditionType = ViewUtil.parsePostConditionTypeFromValue(conditionDropDown.titleLabel!.text!)
            ApiController.instance.editPost(self.postId, title: postTitle.text!, body: prodDescription.text!, catId: category!.id, conditionType: String(conditionType), pricetxt: pricetxt.text!)
        }
    }
    
    func validateSaveForm() -> Bool {
        var isValidated = true
        
        if (self.postTitle.text == nil || self.postTitle.text == "" ) {
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

}
