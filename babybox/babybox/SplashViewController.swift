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
            UserInfoCache.refresh(sessionId!, successCallback: onSuccessGetUserInfo, failureCallback: onFailure)
        } else {
            showLoginPage()
        }
    }
    
    func initNewUser() {
        ApiFacade.initNewUser(onSuccessInitNewUser, failureCallback: onFailure)
    }
    
    func onSuccessInitNewUser(user: UserVM) {
        self.showMainPage()
    }
    
    func onSuccessGetUserInfo(userInfo: UserVM) {
        // user not logged in, redirect to login page
        if userInfo.id == -1 {
            onFailure("Cannot find user. Please login again.")
        }

        // new user flow
        if userInfo.newUser {
            if userInfo.displayName.isEmpty {
                self.showSignupDetailPage()
            } else if !userInfo.emailValidated {
                ViewUtil.makeToast(NSLocalizedString("verified_email_msg", comment: ""), view: self.view)
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
        //Check Notif registrations.
        ApiFacade.registerAppForNotification()
    }
    
    func onFailure(message: String?) {
        if message != nil {
            ViewUtil.showDialog(NSLocalizedString("login_error", comment: ""), message: message!, view: self,
                handler: { UIAlertAction in
                    self.showLoginPage()
            })
        }
    }
    
    func showLoginPage() {
        AppDelegate.getInstance().logOut()
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
