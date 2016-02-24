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
                self.showLoginPage()
            } else {
                let userInfo: UserInfoVM = result.object as! UserInfoVM
                self.handleUserInfo(userInfo)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "userInfoFailed") { result in
            self.showLoginPage()
        }
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedSuccess") { result in
            // UI thread
            let sessionId: String = result.object as! String
            self.handleUserLogin(sessionId)
        }
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedFailed") { result in
            // UI thread
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
        
        let sessionId: String? = SharedPreferencesUtil.getInstance().getUserAccessToken(SharedPreferencesUtil.User.ACCESS_TOKEN.rawValue)
        NSLog("sessionId="+String(sessionId))
        
        //Check if FB logged in.
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            ApiController.instance.loginByFacebook(FBSDKAccessToken.currentAccessToken().tokenString)
        } else if (sessionId != nil && sessionId != "nil" && sessionId != "-1") {
            UserInfoCache.refresh(sessionId!)
        } else {
            NSThread.sleepForTimeInterval(constants.SPLASH_SHOW_DURATION)
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
    
    func handleUserInfo(userInfo: UserInfoVM) {
        self.navigationController?.navigationBar.hidden = true
        
        constants.userInfo = userInfo
        if (constants.userInfo.id == -1) {
            SwiftEventBus.unregister(self)
            self.showLoginPage()
        } else {
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
    
    func handleUserLogin(sessionId: String) {
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

    func handleUserLoginFailed(message: String) {
        let _errorDialog = UIAlertController(title: "Error Message", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
        _errorDialog.addAction(okAction)
        self.presentViewController(_errorDialog, animated: true, completion: nil)
        self.showLoginPage()
        //self.performSegueWithIdentifier("clickToLogin", sender: nil)
    }
}
