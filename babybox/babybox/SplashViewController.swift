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
        
        let sessionId = AppDelegate.getInstance().sessionId
        NSLog("sessionId="+String(sessionId))
        
        NSThread.sleepForTimeInterval(Constants.SPLASH_SHOW_DURATION)
        
        if sessionId != nil && sessionId != "nil" && !sessionId!.isEmpty {
            UserInfoCache.refresh(sessionId!, successCallback: handleUserInfoSuccess, failureCallback: handleError)
        } else {
            showLoginPage()
        }
    }
    
    func initNewUser() {
        SwiftEventBus.onMainThread(self, name: "initNewUserSuccess") { result in
            if ViewUtil.isEmptyResult(result) {
                self.handleError("No response for init new user")
            } else {
                //let userInfo: UserVM = result.object as! UserVM
                self.showMainPage()
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "initNewUserFailed") { result in
            self.handleError("Failed to init new user")
        }
        
        ApiController.instance.initNewUser()
    }
    
    func handleUserInfoSuccess(userInfo: UserVM) {
        // user not logged in, redirect to login page
        if userInfo.id == -1 {
            handleError("Cannot find user. Please login again.")
        }

        // new user flow
        if userInfo.newUser {
            if userInfo.displayName.isEmpty {
                self.showSignupDetailPage()
            } else if !userInfo.emailValidated {
                ViewUtil.makeToast("Email is not verified. Please check your email from BabyBox and click verify link.", view: self.view)
                AppDelegate.getInstance().clearUserSession()
                self.showLoginPage()
            } else {
                self.initNewUser()
            }
        }
        // login successful
        else {
            self.showMainPage()
        }
    }
    
    func showMainPage() {
        AppDelegate.getInstance().initUserCaches()
        SwiftEventBus.unregister(self)
        self.performSegueWithIdentifier("homefeed", sender: nil)
    }
    
    func handleError(message: String?) {
        AppDelegate.getInstance().logOut()
        SwiftEventBus.unregister(self)
        if message != nil {
            ViewUtil.showDialog("Login Error", message: message!, view: self)
        }
        self.showLoginPage()
    }
    
    func showLoginPage() {
        /*let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("WelcomeViewController") as! WelcomeViewController
        self.navigationController?.pushViewController(vController, animated: true)
        */
        SwiftEventBus.unregister(self)
        self.navigationController?.navigationBar.hidden = true
        self.performSegueWithIdentifier("loginpage", sender: nil)
    }
    
    func showSignupDetailPage() {
        SwiftEventBus.unregister(self)
        self.navigationController?.navigationBar.hidden = true
        self.performSegueWithIdentifier("showSignUpDetails", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
