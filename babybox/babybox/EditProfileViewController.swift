//
//  EditProfileViewController.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class EditProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    var userId = -1
    
    
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var editScrollView: UIScrollView!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var aboutMe: UITextView!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var fbLoginIcon: UIImageView!
    @IBOutlet weak var location: UIButton!
    
    @IBOutlet weak var mbLoginIcon: UIImageView!
    @IBOutlet weak var submitBtn: UIButton!
    let locationDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewUtil.showActivityLoading(self.activityLoading)
        SwiftEventBus.unregister(self)
        SwiftEventBus.onMainThread(self, name: "onEditInfoSuccess") { result in
            NSLog("User info updated successfully")
            UserInfoCache.refresh(AppDelegate.getInstance().sessionId!)
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            
            self.navigationController?.popViewControllerAnimated(true)
            
            if let myProfileController = CustomTabBarController.getProfileTab() {
                myProfileController.isRefresh = true
                myProfileController.currentIndex = nil
                myProfileController.feedLoader?.loading = false
            }
            
        }
        
        SwiftEventBus.onMainThread(self, name: "onEditInfoFailed") { result in
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            self.view.makeToast(message: "Error updating user info", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        var uiGesture = UITapGestureRecognizer(target: self, action: "scrollViewTouched")
        editScrollView.addGestureRecognizer(uiGesture)
        
        self.initializeEditComponents()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeEditComponents() {
        
        let userInfo = UserInfoCache.getUser()
        ViewUtil.displayRoundedCornerView(self.submitBtn, bgColor: Color.PINK)
        if (userInfo!.isFBLogin) {
            self.fbLoginIcon.hidden = false
        } else {
            self.mbLoginIcon.hidden = false
        }
        self.email.text = userInfo?.email
        ViewUtil.displayCornerTextView(self.email)
        self.displayName.delegate = self
        self.displayName.text = userInfo?.displayName
        ViewUtil.displayCornerTextView(self.displayName)
        self.firstName.delegate = self
        self.firstName.text = userInfo?.firstName
        ViewUtil.displayCornerTextView(self.firstName)
        self.lastName.delegate = self
        self.lastName.text = userInfo?.lastName
        ViewUtil.displayCornerTextView(self.lastName)
        self.aboutMe.delegate = self
        self.aboutMe.text = userInfo?.aboutMe
        ViewUtil.displayCornerTextView(self.aboutMe)
        ViewUtil.displayCornerTextView(self.location)
        initializeLocationDropDown((userInfo?.location.id)!)
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.editScrollView.contentSize.height += keyboardSize.height
    }
    
    @IBAction func ShoworDismiss(sender: AnyObject) {
        if self.locationDropDown.hidden {
            self.locationDropDown.show()
        } else {
            self.locationDropDown.hide()
        }
    }
    
    @IBAction func onClickSubmitBtn(sender: UIButton) {
        if isValid() {
            ViewUtil.showGrayOutView(self, activityLoading: self.activityLoading)
            let location = DistrictCache.getDistrictByName(self.location.titleLabel!.text!)
            let editUserInfoVM = EditUserInfoVM(email: self.email.text!, aboutMe: self.aboutMe.text, displayName: self.displayName.text!,
                firstName: self.firstName.text!, lastName: self.lastName.text!, location: (location?.id)!)
            
            ApiController.instance.editUserInfo(editUserInfoVM)
        }
    }
    
    func initializeLocationDropDown(locationId: Int) {
        var locs: [String] = []
        var selLocationValue = "Select a Location:"
        for (_, element) in DistrictCache.districts.enumerate() {
            if element.id == locationId {
                selLocationValue = element.displayName
            }
            locs.append(element.displayName)
        }
        
        self.locationDropDown.dataSource = locs
        
        self.locationDropDown.selectionAction = { [unowned self] (index, item) in
            self.location.setTitle(item, forState: .Normal)
        }
        
        self.locationDropDown.anchorView = self.location
        self.locationDropDown.bottomOffset = CGPoint(x: 0, y: self.location.bounds.height)
        self.locationDropDown.direction = .Top
        self.location.setTitle(selLocationValue, forState: UIControlState.Normal)
        
    }
    
    func isValid() -> Bool {
        var isValidated = true
        
        if (self.location.titleLabel?.text == nil || self.location.titleLabel?.text == "- Select -") {
            self.view.makeToast(message: "Please select location", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        }
        return isValidated
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.editScrollView.contentSize.height = self.contentView.frame.height
    }
    
    func scrollViewTouched() {
        self.view.endEditing(true)
    }

}
