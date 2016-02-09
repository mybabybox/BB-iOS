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

class SignupViewController: FbLoginViewController {
    
    
    @IBOutlet weak var firstNametxtWidth: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var policyBtn: UIButton!
    @IBOutlet weak var licenseBtn: UIButton!
    var isLicenseDisplay = true
    var isPolicyDisplay = true
    var categories : [CategoryModel] = []
    var isValidForm: Bool = false
    
    @IBOutlet weak var firstNameText: UITextField!
    
    @IBOutlet weak var lastNameText: UITextField!

    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
       @IBOutlet weak var confirmPasswordText: UITextField!
    
   
    @IBOutlet var signUp: UIButton!
    override func viewDidAppear(animated: Bool) {
        //self.navigationController?.navigationBar.hidden = true
        
    }
   
    override func viewDidLoad() {
        self.licenseBtn.layer.borderWidth = 1.0
        self.licenseBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        self.policyBtn.layer.borderWidth = 1.0
        self.policyBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        
        self.firstNameText.backgroundColor = UIColor.clearColor()
        self.lastNameText.backgroundColor = UIColor.clearColor()
        self.passwordText.backgroundColor = UIColor.clearColor()
        self.emailText.backgroundColor = UIColor.clearColor()
        self.confirmPasswordText.backgroundColor = UIColor.clearColor()
        
        ImageUtil.imageUtil.displayCornerView(self.firstNameText)
        ImageUtil.imageUtil.displayCornerView(self.lastNameText)
        ImageUtil.imageUtil.displayCornerView(self.passwordText)
        ImageUtil.imageUtil.displayCornerView(self.emailText)
        ImageUtil.imageUtil.displayCornerView(self.confirmPasswordText)
        ImageUtil.imageUtil.displayCornerView(self.signUp)
        
        DistrictCache.refresh()
        
        let availableWidthForButtons:CGFloat = self.view.bounds.width - 100
        let buttonWidth :CGFloat = availableWidthForButtons / 2
        
        self.firstNametxtWidth.constant = buttonWidth
        self.widthConstraint.constant = buttonWidth

    }
    
    override func viewDidDisappear(animated: Bool) {
        //self.navigationController?.navigationBar.hidden = true
    }
    
    @IBAction func onSignup(sender: AnyObject) {
        if(validateSignup()){
            ApiControlller.apiController.signIn(firstNameText.text!, lastNameText: lastNameText.text!,
                emailText: emailText.text!, passwordText: passwordText.text!, confirmPasswordText: confirmPasswordText.text!);
            self.isValidForm = true;
            //self.performSegueWithIdentifier("signinInfo", sender: nil)
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("SignupDetailViewController") as! SignupDetailViewController
            self.navigationController?.pushViewController(vController, animated: true)
            
        }
    }
    
    func handleGetCateogriesSuccess(categories: [CategoryModel]) {
        self.categories = categories;
       
    }
    
    func validateSignup() -> Bool {
        var isValidated = true
        
        if (self.firstNameText.text == nil || self.firstNameText.text == "" ) {
            self.view.makeToast(message: "Please fill first name", duration: 1.5, position: "bottom")
            isValidated = false
        }else if (self.lastNameText.text == nil || self.lastNameText.text == "" ) {
            self.view.makeToast(message: "Please fill last name", duration: 1.5, position: "bottom")
            isValidated = false
        }else if (self.emailText.text == nil || self.emailText.text == "" ) {
            self.view.makeToast(message: "Please fill email", duration: 1.5, position: "bottom")
            isValidated = false
        }else if (self.passwordText.text == nil || self.passwordText.text == "" ) {
            self.view.makeToast(message: "Please fill password", duration: 1.5, position: "bottom")
            isValidated = false
        }else if (self.confirmPasswordText.text == nil || self.confirmPasswordText.text == "" ) {
            self.view.makeToast(message: "Please fill confirm password", duration: 1.5, position: "bottom")
            isValidated = false
        }else if (self.confirmPasswordText.text != self.passwordText.text ) {
            self.view.makeToast(message: "Please fill password and confirm password same", duration: 1.5, position: "bottom")
            isValidated = false
        }
        
        return isValidated
    }
    
    @IBAction func onClickLicenseBtn(sender: AnyObject) {
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
    
    @IBAction func onClickPolicyBtm(sender: AnyObject) {
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
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return self.isValidForm
    }

    
    @IBAction func onSignInByfb(sender: AnyObject) {
        /*print("onSignInByfb")
        var fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["public_profile"], fromViewController: self) {
            (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            
            if (error != nil) {
                NSLog("User Logged In.")
                print(result)
            } else if (result.isCancelled) {
                   NSLog("User Cancelled")
            } else {
                NSLog("User Not Logged In.")
            }
        }*/
        self.loginWithFacebook()
    }

}