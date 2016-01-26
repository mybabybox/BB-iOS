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

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    @IBAction func onBackButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    var isUserLoggedIn = false
    let apiController =  ApiControlller();
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var userNameTxt: UITextField!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "clickToLogin" {
            self.signInButton.enabled = false
            self.signInButton.alpha = 0.75
            if (userNameTxt.text!.isEmpty || passwordTxt.text!.isEmpty) {
                let _errorDialog = UIAlertController(title: "Warning Message", message: "Please Enter UserName & Password", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
                _errorDialog.addAction(okAction)
                self.presentViewController(_errorDialog, animated: true, completion: nil)
                self.signInButton.enabled = true
                self.signInButton.alpha = 1.0
                return false;
            }
            self.progressIndicator.hidden = false
            self.progressIndicator.startAnimating()
            apiController.authenticateUser("pitlawarkp@gmail.com", password: "pitlawarkp");
            //apiController.authenticateUser(self.userNameTxt.text!, password: self.passwordTxt.text!);
            return false
        } else if (identifier == "gotoforgotpassword") {
            return true
        }
        return self.isUserLoggedIn
        
    }
    
    func handleUserLogin(resultDto: String) {
        
        
        if resultDto.isEmpty {
            //authentication failed.. show error message...
            let _errorDialog = UIAlertController(title: "Error Message", message: "Invalid UserName or Password", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
            _errorDialog.addAction(okAction)
            self.presentViewController(_errorDialog, animated: true, completion: nil)
            self.progressIndicator.hidden = true
            self.progressIndicator.stopAnimating()
            self.signInButton.enabled = true
            self.signInButton.alpha = 1.0
        } else {
            constants.accessToken = resultDto
            ApiControlller.apiController.getUserInfo()
        }
        //make API call to get the user profile data... 
        
    }
    
    func handleUserInfo(resultDto: UserInfoVM) {
        self.isUserLoggedIn = true
        self.progressIndicator.hidden = true
        self.progressIndicator.stopAnimating()
        constants.userInfo = resultDto
        self.performSegueWithIdentifier("clickToLogin", sender: nil)
        
    }
    
    func handleUserLoginFailed(resultDto: String) {
        self.isUserLoggedIn = false
        self.progressIndicator.hidden = true
        progressIndicator.stopAnimating()
        
        let _errorDialog = UIAlertController(title: "Error Message", message: resultDto, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
        _errorDialog.addAction(okAction)
        self.presentViewController(_errorDialog, animated: true, completion: nil)
        self.signInButton.enabled = true
        self.signInButton.alpha = 1.0
        //self.performSegueWithIdentifier("clickToLogin", sender: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signInButton.enabled = true
        self.signInButton.alpha = 1.0
        self.navigationController?.toolbar.hidden = true
        //self.navigationController?.navigationBar.hidden = true
        self.userNameTxt.delegate = self
        self.passwordTxt.delegate = self
        
        self.isUserLoggedIn = false
        self.progressIndicator.hidden = true
        
        let color = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF76A4).CGColor
        self.signInButton.layer.cornerRadius = 5
        self.signInButton.layer.borderWidth = 1
        self.signInButton.layer.borderColor = color
        
        ApiControlller.init();
        // Do any additional setup after loading the view, typically from a nib.
        
        self.userNameTxt.layer.borderWidth = 0
        self.passwordTxt.layer.borderWidth = 0
        self.userNameTxt.layer.borderColor = UIColor.whiteColor().CGColor
        self.passwordTxt.layer.borderColor = UIColor.whiteColor().CGColor
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedSuccess") { result in
            // UI thread
            let resultDto: String = result.object as! String
            self.handleUserLogin(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "userInfoSuccess") { result in
            // UI thread
            print(result.object)
            let resultDto: UserInfoVM = result.object as! UserInfoVM
            self.handleUserInfo(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedFailed") { result in
            // UI thread
            var resultDto = ""
            if result == nil {
                resultDto = "Error Authenticating User"
            } else if result.object is NSString {
                resultDto = result.object as! String
            } else {
                resultDto = "Connection Failure"
            }
            
            //if let result.object is NSString {
            // /   resultDto = result.object as! String
            //} else {
            //    resultDto = "Connection Failure"
            //}
            
            self.handleUserLoginFailed(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "getUserLoggedUserInfo") { result in
            // UI thread
            let resultDto: UserInfoVM = result.object as! UserInfoVM
            print(resultDto);
        }
        //print(FBSDKAccessToken.currentAccessToken())
        if(FBSDKAccessToken.currentAccessToken() == nil) {
            
            let loginButton=FBSDKLoginButton()
            self.view.addSubview(loginButton)
            
            loginButton.center=self.view.center
            //loginButton.center.x = signInButton.center.x
            loginButton.center.y = signInButton.center.y + 150
            loginButton.readPermissions=["public_profile","email","user_friends"]
            loginButton.delegate=self
        }
        else{
            
            self.progressIndicator.hidden = true
            progressIndicator.stopAnimating()
            apiController.validateFacebookUser(FBSDKAccessToken.currentAccessToken().tokenString);
            print("Logged in..")
        }
        
        let uImageView = UIImageView()
        uImageView.image = UIImage(named: "login_user")
        userNameTxt.leftViewMode = UITextFieldViewMode.Always
        userNameTxt.leftView = uImageView;
        uImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        self.view.addSubview(uImageView)
        
        let pImageView = UIImageView()
        pImageView.image = UIImage(named: "login_lock")
        passwordTxt.leftViewMode = UITextFieldViewMode.Always
        passwordTxt.leftView = pImageView;
        pImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        self.view.addSubview(pImageView)
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (error == nil) {
            self.isUserLoggedIn = true
            if (!result.isCancelled) {
                constants.accessToken = result.token.tokenString
                self.apiController.validateFacebookUser(result.token.tokenString)
            }
            //make API call to authenticate facebook user on server.
            
            //self.performSegueWithIdentifier("clickToFacebookLogin", sender: self)
        } else {
            print(error.localizedDescription, terminator: "")
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged out..", terminator: "")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        print("return key is pressed")
        return true;
    }
    
    /*func textFieldShouldReturn(textField: UITextField) -> Bool {
        return false
    }*/
    
    @IBAction func onForgetPasswordClick(sender: AnyObject) {
        print("Forget pasword click");
    }
    
    @IBAction func onSignUpClick(sender: AnyObject) {
         print("Sign up click");
    }
    
    
    
}

