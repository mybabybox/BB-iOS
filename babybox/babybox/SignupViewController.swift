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
    
    override func viewDidAppear(animated: Bool) {
    }
   
    override func viewDidLoad() {

        SwiftEventBus.onMainThread(self, name: "signUpSuccess") { result in
            if ViewUtil.isEmptyResult(result) {
                self.onFailure("No response for sign up. Please try again later.")
            } else {
                self.emailLogin(self.emailText.text!, password: self.passwordText.text!)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "signUpFailed") { result in
            self.onFailure("Email is already registered")
        }
        
        ViewUtil.displayRoundedCornerView(self.signUpBtn, bgColor: Color.PINK)
        
        self.licenseBtn.layer.borderWidth = 1.0
        self.licenseBtn.layer.borderColor = Color.DARK_GRAY.CGColor
        
        self.policyBtn.layer.borderWidth = 1.0
        self.policyBtn.layer.borderColor = Color.DARK_GRAY.CGColor
    }
    
    @IBAction func onSignUp(sender: UIButton) {
        if isValid() {
            ApiController.instance.signUp(emailText.text!, fname: firstNameText.text!, lname: lastNameText.text!,
                password: passwordText.text!, repeatPassword: confirmPasswordText.text!)
            self.isValidForm = true
        }
    }
    
    func isValid() -> Bool {
        var isValidated = true
        
        if (self.firstNameText.text == nil || self.firstNameText.text == "" ) {
            self.view.makeToast(message: "Please fill first name", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        }else if (self.lastNameText.text == nil || self.lastNameText.text == "" ) {
            self.view.makeToast(message: "Please fill last name", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        }else if (self.emailText.text == nil || self.emailText.text == "" ) {
            self.view.makeToast(message: "Please fill email", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        }else if (self.passwordText.text == nil || self.passwordText.text == "" ) {
            self.view.makeToast(message: "Please fill password", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        }else if (self.confirmPasswordText.text == nil || self.confirmPasswordText.text == "" ) {
            self.view.makeToast(message: "Please fill confirm password", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        }else if (self.confirmPasswordText.text != self.passwordText.text ) {
            self.view.makeToast(message: "Please fill password and confirm password same", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        }
        
        return isValidated
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
    /*
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "signUpDetails") {
            if(self.validateSignup()){
                ApiController.instance.signIn(firstNameText.text!, lastNameText: lastNameText.text!,
                    emailText: emailText.text!, passwordText: passwordText.text!, confirmPasswordText: confirmPasswordText.text!)
                self.isValidForm = true
            }
        }
        return self.isValidForm
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*if (segue.identifier == "signUpDetails") {
            if(self.validateSignup()){
                ApiController.instance.signIn(firstNameText.text!, lastNameText: lastNameText.text!,
                    emailText: emailText.text!, passwordText: passwordText.text!, confirmPasswordText: confirmPasswordText.text!)
                self.isValidForm = true
            }
        }*/
    }
}