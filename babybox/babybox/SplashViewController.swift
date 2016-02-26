//
//  SplashViewController.swift
//  babybox
//
//  Created by Mac on 27/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import FBSDKCoreKit
import FBSDKLoginKit

class SplashViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        self.navigationController?.navigationBar.hidden = true
        
        SwiftEventBus.onMainThread(self, name: "userInfoSuccess") { result in
            if ViewUtil.isEmptyResult(result) {
                self.handleUserLoginFailed("User is not logged in")
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
        
        let sessionId: String? = SharedPreferencesUtil.getInstance().getUserSessionId(SharedPreferencesUtil.User.SESSION_ID.rawValue)
        NSLog("sessionId="+String(sessionId))
        
        NSThread.sleepForTimeInterval(constants.SPLASH_SHOW_DURATION)
        
        if (sessionId != nil && sessionId != "nil" && !sessionId!.isEmpty) {
            UserInfoCache.refresh(sessionId!)
        } else {
            showLoginPage()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    func handleUserLoginFailed(message: String) {
        ViewUtil.showOKDialog("Login Error", message: message, view: self)
        SwiftEventBus.unregister(self)
        AppDelegate.getInstance().logout()
        self.showLoginPage()
    }

    func handleUserInfoSuccess(userInfo: UserVM) {
        // user not logged in, redirect to login page
        if (userInfo.id == -1) {
            handleUserLoginFailed("Cannot find user. Please login again.")
        }

        // new user flow
        if userInfo.newUser || userInfo.displayName.isEmpty {
            if !userInfo.emailValidated {
                ViewUtil.makeToast("Email is not verified. Please check your email from BabyBox and click verify link.", view: self.view)
                AppDelegate.getInstance().clearUserSession()
                self.showLoginPage()
            } else {
                self.showSignupDetailPage()
            }
        }
        // login successful
        else {
            UserInfoCache.setUser(userInfo)
            AppDelegate.getInstance().initUserCaches()
            self.performSegueWithIdentifier("homefeed", sender: nil)
        }
    }
    
    func showLoginPage() {
        /*let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("LandingPageViewController") as! LandingPageViewController
        self.navigationController?.pushViewController(vController, animated: true)
        */
        SwiftEventBus.unregister(self)
        self.navigationController?.navigationBar.hidden = true
        self.performSegueWithIdentifier("loginpage", sender: nil)
    }
    
    func showSignupDetailPage() {
        
    }
    
    func handleUserLoginSuccess(sessionId: String) {
        if sessionId.isEmpty {
            //authentication failed.. show error message...
            let _errorDialog = UIAlertController(title: "Error Message", message: "Invalid UserName or Password",
                preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
            _errorDialog.addAction(okAction)
            self.presentViewController(_errorDialog, animated: true, completion: nil)
        } else {
            UserInfoCache.refresh(sessionId)
        }
        //make API call to get the user profile data...
        
    }
}
