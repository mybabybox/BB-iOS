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
import SwiftEventBus

class LoginViewController: BaseLoginViewController, UITextFieldDelegate {
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBAction func onBackButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.toolbar.hidden = true
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.toolbar.hidden = true
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false

        self.userNameTxt.delegate = self
        self.passwordTxt.delegate = self
        
        let color = ImageUtil.UIColorFromRGB(0xFF76A4).CGColor
        //self.loginButton.layer.cornerRadius = 5
        //self.loginButton.layer.borderWidth = 1
        self.loginButton.layer.borderColor = color
        ImageUtil.displayButtonRoundBorder(self.loginButton)
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.userNameTxt.layer.borderWidth = 0
        self.passwordTxt.layer.borderWidth = 0
        self.userNameTxt.layer.borderColor = UIColor.whiteColor().CGColor
        self.passwordTxt.layer.borderColor = UIColor.whiteColor().CGColor
        
        /*
        let uImageView = UIImageView()
        uImageView.image = UIImage(named: "login_user")
        uImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        self.userNameTxt.addSubview(uImageView)
        */
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "clickToLogin" {
            if (userNameTxt.text!.isEmpty || passwordTxt.text!.isEmpty) {
                let _errorDialog = UIAlertController(title: "Warning Message", message: "Please Enter UserName & Password", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                _errorDialog.addAction(okAction)
                self.presentViewController(_errorDialog, animated: true, completion: nil)
                return false
            }
            
            startLoading()
            ApiController.instance.loginByEmail(self.userNameTxt.text!, password: self.passwordTxt.text!)
            return false
        } else if (identifier == "gotoforgotpassword") {
            return true
        } else if (identifier == "showSignupView") {
            self.navigationController?.navigationBar.hidden = false
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
        ViewUtil.showActivityLoading(self.progressIndicator)
        self.loginButton.enabled = false
        self.loginButton.alpha = 0.75
        //self.fbButton.enabled = false
        //self.fbButton.alpha = 0.75
    }
    
    override func stopLoading() {
        ViewUtil.hideActivityLoading(self.progressIndicator)
        self.loginButton.enabled = true
        self.loginButton.alpha = 1.0
        //self.fbButton.enabled = true
        //self.fbButton.alpha = 1.0
    }
}

