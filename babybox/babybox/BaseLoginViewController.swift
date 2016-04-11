//
//  BaseLoginViewController.swift
//  BabyBox
//
//  Created by Keith Lei on 2/25/16.
//  Copyright © 2016 Mac. All rights reserved.
//


import UIKit
import FBSDKLoginKit
import SwiftEventBus

class BaseLoginViewController: UIViewController {
    
    var isUserLoggedIn = false

    let facebookReadPermissions = ["public_profile", "email", "user_friends"]
    // Other options: "user_about_me", "user_birthday", "user_hometown", "user_likes", "user_interests", "user_photos", "friends_photos", "friends_hometown", "friends_location", "friends_education_history"
    
    func onSuccessLogin(sessionId: String) {
        startLoading()
        
        if !sessionId.isEmpty {
            self.isUserLoggedIn = true
            AppDelegate.getInstance().sessionId = sessionId
            
            // call subclass
            postLogin()
            
            SwiftEventBus.unregister(self)
        } else {
            //authentication failed.. show error message...
            let _errorDialog = UIAlertController(title: "Error Message", message: "Invalid UserName or Password", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            _errorDialog.addAction(okAction)
            self.presentViewController(_errorDialog, animated: true, completion: nil)
        }
        
        stopLoading()
    }
    
    func onFailure(message: String?) {
        startLoading()
        
        self.isUserLoggedIn = false
        AppDelegate.getInstance().logOut()
        if message != nil {
            ViewUtil.showDialog("Login Error", message: message!, view: self)
        }
        
        stopLoading()
    }
    
    func postLogin() {
        // register notif
        
        //self.performSegueWithIdentifier("clickToLogin", sender: nil)
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("SplashViewController")
        vController?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vController!, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopLoading()
        
        self.isUserLoggedIn = false
        
        self.navigationController?.toolbarHidden = true
        self.navigationController?.navigationBarHidden = true
        
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedSuccess") { result in
            if ViewUtil.isEmptyResult(result) {
                self.onFailure("User is not logged in")
            } else {
                let response: String = result.object as! String
                self.onSuccessLogin(response)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedFailed") { result in
            var message = ""
            if result.object is NSString {
                message = result.object as! String
            }
            
            if message.isEmpty {
                message = "Failed to authenticate user"
            }
            self.onFailure(message)
        }
        
        // prepare fb login button
        //let fbLoginButton = FBSDKLoginButton()
        //self.view.addSubview(fbLoginButton)
        
        //fbLoginButton.center = self.view.center
        //fbLoginButton.center.y += 150
        //fbLoginButton.readPermissions = facebookReadPermissions
        //fbLoginButton.delegate = self
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error == nil) {
            if (!result.isCancelled) {
                fbLogin(result.token.tokenString, userId: result.token.userID)
            }
        } else {
            NSLog(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        NSLog("User Logged out")
    }
    
    func emailLogin(email: String, password: String) {
        self.view.alpha = 0.75
        AppDelegate.getInstance().logOut()
        ApiController.instance.loginByEmail(email, password: password)
    }
    
    func fbLogin(access_token: String, userId: String) {
        self.view.alpha = 0.75
        AppDelegate.getInstance().logOut()
        ApiController.instance.loginByFacebook(access_token)
    }
    
    @IBAction func fbLoginClick(sender: AnyObject) {
        self.fbNativeLogin(self.fbLogin, failureBlock: self.onFailure)
    }
    
    func fbNativeLogin(successBlock: (token: String, userId: String) -> (), failureBlock: (String?) -> ()) {
        startLoading()
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKLoginManager().logOut()
        }
        
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.SystemAccount
        fbLoginManager.logInWithReadPermissions(self.facebookReadPermissions, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                //According to Facebook:
                //Errors will rarely occur in the typical login flow because the login dialog
                //presented by Facebook via single sign on will guide the users to resolve any errors.
                
                // Process error
                FBSDKLoginManager().logOut()
                failureBlock(error.localizedDescription)
            } else if result.isCancelled {
                // Handle cancellations
                FBSDKLoginManager().logOut()
                failureBlock("Login is cancelled")
            } else {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                var allPermsGranted = true
                
                //result.grantedPermissions returns an array of _NSCFString pointers
                let grantedPermissions = result.grantedPermissions
                for permission in self.facebookReadPermissions {
                    if !grantedPermissions.contains(permission) {
                        allPermsGranted = false
                        break
                    }
                }
                
                if allPermsGranted {
                    let fbToken = result.token.tokenString
                    let fbUserID = result.token.userID
                    NSLog("fbNativeLogin: access_token="+fbToken)
                    successBlock(token: fbToken, userId: fbUserID)
                } else {
                    //The user did not grant all permissions requested
                    //Discover which permissions are granted
                    //and if you can live without the declined ones
                    
                    failureBlock("Facebook permissions not granted")
                }
            }
            
            self.stopLoading()
        })
    }
    
    func startLoading() {
        self.view.alpha = 0.75
        // to be implemented in subclass
    }
    
    func stopLoading() {
        self.view.alpha = 1.0
        // to be implemented in subclass
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
