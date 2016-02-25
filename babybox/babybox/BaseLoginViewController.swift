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
            SharedPreferencesUtil.getInstance().setUserSessionId(sessionId)
            UserInfoCache.refresh(sessionId)
            onSuccessLogin()
        } else {
            //authentication failed.. show error message...
            let _errorDialog = UIAlertController(title: "Error Message", message: "Invalid UserName or Password", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
            _errorDialog.addAction(okAction)
            self.presentViewController(_errorDialog, animated: true, completion: nil)
        }
        
        stopLoading()
    }
    
    func handleUserLoginFailed(resultDto: String) {
        startLoading()
        
        self.isUserLoggedIn = false
        let _errorDialog = UIAlertController(title: "Error Message", message: resultDto, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
        _errorDialog.addAction(okAction)
        self.presentViewController(_errorDialog, animated: true, completion: nil)
        //self.performSegueWithIdentifier("clickToLogin", sender: nil)
        
        stopLoading()
    }
    
    func handleUserInfo(userInfo: UserVM) {
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
                self.finish()
            } else {
                let response: String = result.object as! String
                self.handleUserLoginSuccess(response)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedFailed") { result in
            var resultDto = ""
            if result == nil {
                resultDto = "Error Authenticating User"
            } else if result.object is NSString {
                resultDto = result.object as! String
            } else {
                resultDto = "Connection Failure"
            }
            
            self.handleUserLoginFailed(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "userInfoSuccess") { result in
            if ViewUtil.isEmptyResult(result) {
                self.finish()
                self.handleUserLoginFailed("No user returned")
            } else {
                let userInfo: UserVM = result.object as! UserVM
                self.handleUserInfo(userInfo)
            }
        }

        // prepare fb login button
        let fbLoginButton = FBSDKLoginButton()
        self.view.addSubview(fbLoginButton)
        
        fbLoginButton.center = self.view.center
        fbLoginButton.center.y += 150
        fbLoginButton.readPermissions = facebookReadPermissions
        fbLoginButton.delegate = self
    }
    
    func finish() {
        SwiftEventBus.unregister(self)
        AppDelegate.getInstance().logout()
    }
    
    func logError(error: NSError?) {
        
    }
    
    func onSuccessLogin() {
        // register notif
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error == nil) {
            startLoading()
            self.isUserLoggedIn = true
            if (!result.isCancelled) {
                constants.sessionId = result.token.tokenString
                ApiController.instance.loginByFacebook(result.token.tokenString)
            }
            //make API call to authenticate facebook user on server.
            
            //self.performSegueWithIdentifier("clickToLogin", sender: self)
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
}




















