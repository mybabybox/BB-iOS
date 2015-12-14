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

class ViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
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
            if (userNameTxt.text!.isEmpty || passwordTxt.text!.isEmpty) {
                print("enter details....")
                
                let _errorDialog = UIAlertController(title: "Warning Message", message: "Please Enter UserName & Password", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
                _errorDialog.addAction(okAction)
                self.presentViewController(_errorDialog, animated: true, completion: nil)
                return false;
            }
            self.progressIndicator.hidden = false
            self.progressIndicator.startAnimating()
            //apiController.authenticateUser("pitlawarkp@gmail.com", password: "pitlawarkp");
            apiController.authenticateUser(self.userNameTxt.text!, password: self.passwordTxt.text!);
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
        } else {
            ApiControlller.apiController.getUserInfo()
            constants.accessToken = resultDto
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
        //self.performSegueWithIdentifier("clickToLogin", sender: nil)
        //apiController.getUserInfo();
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        self.userNameTxt.delegate = self
        self.passwordTxt.delegate = self
        
        self.isUserLoggedIn = false
        self.progressIndicator.hidden = true
        ApiControlller.init();
        // Do any additional setup after loading the view, typically from a nib.
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedSuccess") { result in
            // UI thread
            print(result.object)
            let resultDto: String = result.object as! String
            print("here got the login result... " + resultDto);
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
        
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("login in progress")
        if (error == nil) {
            print("Login Complete..", terminator: "")
            self.isUserLoggedIn = true
            
            //make API call to authenticate facebook user on server.
            apiController.validateFacebookUser(result.token.tokenString);
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

