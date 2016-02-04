//
//  SignupViewController.swift
//  babybox
//
//  Created by Mac on 02/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    
    @IBOutlet weak var policyBtn: UIButton!
    @IBOutlet weak var licenseBtn: UIButton!
    var isLicenseDisplay = true
    var isPolicyDisplay = true
    
    @IBOutlet weak var firstNameText: UITextField!
    
    @IBOutlet weak var lastNameText: UITextField!

    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
       @IBOutlet weak var confirmPasswordText: UITextField!
    
   
    @IBOutlet var signUp: UIButton!
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
    }
   
    override func viewDidLoad() {
        self.navigationController?.navigationBar.hidden = false
        self.licenseBtn.layer.borderWidth = 1.0
        self.licenseBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        self.policyBtn.layer.borderWidth = 1.0
        self.policyBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        
        let color = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF76A4).CGColor
        self.firstNameText.backgroundColor = UIColor.clearColor()
        self.firstNameText.layer.cornerRadius = 3
        self.firstNameText.layer.borderWidth = 1
        self.firstNameText.layer.borderColor = color
        self.lastNameText.backgroundColor = UIColor.clearColor()
        self.lastNameText.layer.cornerRadius = 3
        self.lastNameText.layer.borderWidth = 1
        self.lastNameText.layer.borderColor = color
        self.passwordText.backgroundColor = UIColor.clearColor()
        self.passwordText.layer.cornerRadius = 3
        self.passwordText.layer.borderWidth = 1
        self.passwordText.layer.borderColor = color
        self.emailText.backgroundColor = UIColor.clearColor()
        self.emailText.layer.cornerRadius = 3
        self.emailText.layer.borderWidth = 1
        self.emailText.layer.borderColor = color
        self.confirmPasswordText.backgroundColor = UIColor.clearColor()
        self.confirmPasswordText.layer.cornerRadius = 3
        self.confirmPasswordText.layer.borderWidth = 1
        self.confirmPasswordText.layer.borderColor = color
        self.signUp.layer.cornerRadius = 3
        self.signUp.layer.borderWidth = 1
        self.signUp.layer.borderColor = color
        
       /* let cb = Checkbox(frame: CGRect(x: 20, y: 100, width: 50, height: 50))
        cb.borderColor = UIColor.redColor()
        cb.borderWidth = 3
        cb.checkColor = UIColor.redColor()
        cb.checkWidth = 3
        view.addSubview(cb)*/

    }
    
    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    @IBAction func onSignup(sender: AnyObject) {
        if(validateSignup()){
            
        }
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
    
    
}