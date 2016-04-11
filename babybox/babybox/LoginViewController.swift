//
//  ViewController.swift
//  babybox
//
//  Created by Mac on 05/12/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: BaseLoginViewController, UITextFieldDelegate {
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
        
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userNameTxt.delegate = self
        self.passwordTxt.delegate = self
        
        ViewUtil.displayRoundedCornerView(self.loginButton, bgColor: Color.PINK)
    }
    
    @IBAction func onEmailLogin(sender: UIButton) {
        if (userNameTxt.text!.isEmpty || passwordTxt.text!.isEmpty) {
            let _errorDialog = UIAlertController(title: "Login", message: "Please enter email & password", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            _errorDialog.addAction(okAction)
            self.presentViewController(_errorDialog, animated: true, completion: nil)
        }
        
        startLoading()
        emailLogin(self.userNameTxt.text!, password: self.passwordTxt.text!)
    }
    
    @IBAction func onClickBackButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (identifier == "gotoforgotpassword") {
            return true
        } else if (identifier == "showSignupView") {
            return true
        }
        
        return self.isUserLoggedIn        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool { // called when 'return' key pressed. return NO to ignore.
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onForgetPasswordClick(sender: AnyObject) {
        NSLog("Forget pasword click")
    }
    
    @IBAction func onSignUpClick(sender: AnyObject) {
         NSLog("Sign up click")
    }
    
    override func startLoading() {
        super.startLoading()
        
        ViewUtil.showActivityLoading(self.progressIndicator)
        self.loginButton.enabled = false
        self.loginButton.alpha = 0.75
    }
    
    override func stopLoading() {
        super.stopLoading()
        
        ViewUtil.hideActivityLoading(self.progressIndicator)
        self.loginButton.enabled = true
        self.loginButton.alpha = 1.0
    }
}

