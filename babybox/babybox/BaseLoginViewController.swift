//
//  BaseLoginViewController.swift
//  BabyBox
//
//  Created by Keith Lei on 2/25/16.
//  Copyright © 2016 Mac. All rights reserved.
//


import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftEventBus

class BaseLoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var isUserLoggedIn = false

    let facebookReadPermissions = ["public_profile", "email", "user_friends"]
    // Other options: "user_about_me", "user_birthday", "user_hometown", "user_likes", "user_interests", "user_photos", "friends_photos", "friends_hometown", "friends_location", "friends_education_history"

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleUserLoginSuccess(sessionId: String) {
        startLoading()
        
        if !sessionId.isEmpty {
            self.isUserLoggedIn = true
            SharedPreferencesUtil.getInstance().setUserSessionId(sessionId)
            UserInfoCache.refresh(sessionId)
            onSuccessLogin()
        } else {
            //authentication failed.. show error message...
            let _errorDialog = UIAlertController(title: "Error Message", message: "Invalid UserName or Password", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            _errorDialog.addAction(okAction)
            self.presentViewController(_errorDialog, animated: true, completion: nil)
        }
        
        stopLoading()
    }
    
    func handleUserLoginFailed(message: String) {
        startLoading()
        
        self.isUserLoggedIn = false
        ViewUtil.showOKDialog("Login Error", message: message, view: self)
        //self.performSegueWithIdentifier("clickToLogin", sender: nil)
        AppDelegate.getInstance().logout()
        
        stopLoading()
    }
    
    func handleUserInfoSuccess(userInfo: UserVM) {
        // user not logged in, redirect to login page
        if (userInfo.id == -1) {
            self.handleUserLoginFailed("User is not logged in")
        }
        
        startLoading()
        
        self.isUserLoggedIn = true
        UserInfoCache.setUser(userInfo)
        SwiftEventBus.unregister(self)
        self.performSegueWithIdentifier("clickToLogin", sender: nil)
        
        stopLoading()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopLoading()
        
        self.isUserLoggedIn = false
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedSuccess") { result in
            if ViewUtil.isEmptyResult(result) {
                self.handleUserLoginFailed("User is not logged in")
            } else {
                let response: String = result.object as! String
                self.handleUserLoginSuccess(response)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedFailed") { result in
            var message = ""
            if result == nil {
                message = "Error Authenticating User"
            } else if result.object is NSString {
                message = result.object as! String
            } else {
                message = "Connection Failure"
            }
            
            self.handleUserLoginFailed(message)
        }
        
        SwiftEventBus.onMainThread(self, name: "userInfoSuccess") { result in
            if ViewUtil.isEmptyResult(result) {
                self.handleUserLoginFailed("No user returned")
            } else {
                let userInfo: UserVM = result.object as! UserVM
                self.handleUserInfoSuccess(userInfo)
            }
        }

        SwiftEventBus.onMainThread(self, name: "userInfoFailed") { result in
            var message = ""
            if result == nil {
                message = "User is not logged in"
            } else if result.object is NSString {
                message = result.object as! String
            } else {
                message = "Connection Failure"
            }
            
            self.handleUserLoginFailed(message)
        }
        
        // prepare fb login button
        //let fbLoginButton = FBSDKLoginButton()
        //self.view.addSubview(fbLoginButton)
        
        //fbLoginButton.center = self.view.center
        //fbLoginButton.center.y += 150
        //fbLoginButton.readPermissions = facebookReadPermissions
        //fbLoginButton.delegate = self
    }
    
    func logError(error: NSError?) {
        
    }
    
    func onSuccessLogin() {
        self.isUserLoggedIn = true
        // register notif
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error == nil) {
            if (!result.isCancelled) {
                fbLoginSuccess(result.token.tokenString, userId: result.token.userID)
            }
        } else {
            NSLog(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        NSLog("User Logged out")
    }
    
    func fbLoginSuccess(access_token: String, userId: String) {
        NSLog("fbLogin: access_token="+access_token)
        ApiController.instance.loginByFacebook(access_token)
    }
    
    func fbLogin(successBlock: (token: String, userId: String) -> (), failureBlock: (NSError?) -> ()) {
        /*
        if FBSDKAccessToken.currentAccessToken() != nil {
            //For debugging, when we want to ensure that facebook login always happens
            //FBSDKLoginManager().logOut()
            //Otherwise do:
            return
        }
        */
        
        FBSDKLoginManager().logInWithReadPermissions(self.facebookReadPermissions, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                //According to Facebook:
                //Errors will rarely occur in the typical login flow because the login dialog
                //presented by Facebook via single sign on will guide the users to resolve any errors.
                
                // Process error
                FBSDKLoginManager().logOut()
                failureBlock(error)
            } else if result.isCancelled {
                // Handle cancellations
                FBSDKLoginManager().logOut()
                failureBlock(nil)
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
                    
                    successBlock(token: fbToken, userId: fbUserID)
                } else {
                    //The user did not grant all permissions requested
                    //Discover which permissions are granted
                    //and if you can live without the declined ones
                    
                    failureBlock(nil)
                }
            }
        })
    }
    
    func startLoading() {
        // to be implemented in subclass
    }
    
    func stopLoading() {
        // to be implemented in subclass
    }
    
    
    @IBAction func fbLoginClick(sender: AnyObject) {
        self.view.alpha = 0.75
        FBSDKLoginManager().logInWithReadPermissions(self.facebookReadPermissions, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                //According to Facebook:
                //Errors will rarely occur in the typical login flow because the login dialog
                //presented by Facebook via single sign on will guide the users to resolve any errors.
                self.view.alpha = 1.0
                // Process error
                FBSDKLoginManager().logOut()
                //failureBlock(error)
            } else if result.isCancelled {
                // Handle cancellations
                self.view.alpha = 1.0
                FBSDKLoginManager().logOut()
                //failureBlock(nil)
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
                    self.fbLoginSuccess(result.token.tokenString, userId: result.token.userID)
                    
                    //successBlock(token: fbToken, userId: fbUserID)
                } else {
                    //The user did not grant all permissions requested
                    //Discover which permissions are granted
                    //and if you can live without the declined ones
                    self.view.alpha = 1.0
                    //failureBlock(nil)
                }
            }
        })
        
    }
}




















