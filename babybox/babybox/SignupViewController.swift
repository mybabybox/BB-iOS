//
//  SignupViewController.swift
//  babybox
//
//  Created by Mac on 02/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import FBSDKCoreKit
import FBSDKLoginKit

class SignupViewController: BaseLoginViewController {
    
    @IBOutlet weak var policyBtn: UIButton!
    @IBOutlet weak var licenseBtn: UIButton!
    
    var isLicenseDisplay = true
    var isPolicyDisplay = true
    var categories : [CategoryVM] = []
    var isValidForm: Bool = false
    
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
   
    override func viewDidLoad() {

        ViewUtil.displayRoundedCornerView(self.signUpBtn, bgColor: Color.PINK)
        
        self.licenseBtn.layer.borderWidth = 1.0
        self.licenseBtn.layer.borderColor = Color.DARK_GRAY.CGColor
        
        self.policyBtn.layer.borderWidth = 1.0
        self.policyBtn.layer.borderColor = Color.DARK_GRAY.CGColor
    }
    
    @IBAction func onSignUp(sender: UIButton) {
        if isValid() {
            self.isValidForm = true
            ApiFacade.signUp(emailText.text!, fname: firstNameText.text!, lname: lastNameText.text!,
                password: passwordText.text!, repeatPassword: confirmPasswordText.text!,
                successCallback: onSuccessSignUp, failureCallback: onFailure)
        }
    }
    
    func onSuccessSignUp(response: String) {
        self.emailLogin(self.emailText.text!, password: self.passwordText.text!)
    }
    
    func isValid() -> Bool {
        var valid = true
        if StringUtil.trim(self.firstNameText.text).isEmpty {
            self.view.makeToast(message: "Please fill first name", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        } else if StringUtil.trim(self.lastNameText.text).isEmpty {
            self.view.makeToast(message: "Please fill last name", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        } else if StringUtil.trim(self.emailText.text).isEmpty {
            self.view.makeToast(message: "Please fill email", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        }else if StringUtil.trim(self.passwordText.text).isEmpty {
            self.view.makeToast(message: "Please fill password", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        } else if StringUtil.trim(self.confirmPasswordText.text).isEmpty {
            self.view.makeToast(message: "Please fill confirm password", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        } else if self.confirmPasswordText.text != self.passwordText.text {
            self.view.makeToast(message: "Please fill password and confirm password same", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            valid = false
        }
        return valid
    }
    
    @IBAction func onClickBackButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickPrivacyCheckbox(sender: AnyObject) {
        isLicenseDisplay = !isLicenseDisplay
        if (isLicenseDisplay) {
            //show another controller
            self.licenseBtn.setImage(UIImage(named: "ic_accept"), forState: UIControlState.Normal)
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("LicenseViewController") as! LicenseViewController
            self.navigationController?.pushViewController(vController, animated: true)
            
        } else {
            //change the image to show unselected.
            self.licenseBtn.setImage(UIImage(named: ""), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func onClickTermsCheckbox(sender: UIButton) {
        isPolicyDisplay = !isPolicyDisplay
        if (isPolicyDisplay) {
            //show another controller
            self.policyBtn.setImage(UIImage(named: "ic_accept"), forState: UIControlState.Normal)
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("LicenseViewController") as! LicenseViewController
            self.navigationController?.pushViewController(vController, animated: true)
        } else {
            //change the image to show unselected.
            self.policyBtn.setImage(UIImage(named: ""), forState: UIControlState.Normal)
        }
    }
    
    //MARK Segue handling methods.
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
    }
}