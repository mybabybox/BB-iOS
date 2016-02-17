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
            if (result != nil || !result.isEqual("")) {
                let resultDto: UserInfoVM = result.object as! UserInfoVM
                self.handleUserInfo_(resultDto)
            } else {
                self.showLoginPage()
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "userInfoFailed") { result in
            self.showLoginPage()
        }
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedSuccess") { result in
            // UI thread
            let resultDto: String = result.object as! String
            self.handleUserLogin(resultDto)
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
            
            self.handleUserLoginFailed(resultDto)
        }
        
        let sessionId: String? = SharedPreferencesUtil.getInstance().getUserAccessToken(SharedPreferencesUtil.User.ACCESS_TOKEN.rawValue)
        NSLog("sessionId="+String(sessionId))
        
        //Check if FB logged in.
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            ApiControlller.apiController.loginByFacebook(FBSDKAccessToken.currentAccessToken().tokenString)
        } else if ( sessionId != nil && sessionId != "nil" && sessionId != "-1") {
            constants.accessToken = sessionId!
            UserInfoCache.refresh()
            
        } else {
            NSThread.sleepForTimeInterval(0.3)
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
    
    func handleUserInfo_(resultDto: UserInfoVM?) {
        if (resultDto != nil) {
            self.navigationController?.navigationBar.hidden = true
            
            constants.accessToken = SharedPreferencesUtil.getInstance().getUserAccessToken(SharedPreferencesUtil.User.ACCESS_TOKEN.rawValue)
            constants.userInfo = resultDto!
            if (constants.userInfo.id == -1) {
                SwiftEventBus.unregister(self)
                self.showLoginPage()
            } else {
                self.performSegueWithIdentifier("homefeed", sender: nil)
            }
        } else {
            self.showLoginPage()
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
    
    func handleUserLogin(resultDto: String) {
        if resultDto.isEmpty {
            //authentication failed.. show error message...
            let _errorDialog = UIAlertController(title: "Error Message", message: "Invalid UserName or Password",
                preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
            _errorDialog.addAction(okAction)
            self.presentViewController(_errorDialog, animated: true, completion: nil)
        } else {
            constants.accessToken = resultDto
            SharedPreferencesUtil.getInstance().setUserAccessToken(resultDto)
            UserInfoCache.refresh()
        }
        //make API call to get the user profile data...
        
    }

    func handleUserLoginFailed(resultDto: String) {
        
        let _errorDialog = UIAlertController(title: "Error Message", message: resultDto, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
        _errorDialog.addAction(okAction)
        self.presentViewController(_errorDialog, animated: true, completion: nil)
        self.showLoginPage()
        //self.performSegueWithIdentifier("clickToLogin", sender: nil)
    }
}
