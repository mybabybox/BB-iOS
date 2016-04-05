//
//  AppDelegate.swift
//  babybox
//
//  Created by Mac on 05/12/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //App launch code
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        let didFinish = FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //Optionally add to ensure your credentials are valid:
        FBSDKLoginManager.renewSystemCredentials { (result:ACAccountCredentialRenewResult, error:NSError!) -> Void in

        }
        return didFinish
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        //Even though the Facebook SDK can make this determinitaion on its own,
        //let's make sure that the facebook SDK only sees urls intended for it,
        //facebook has enough info already!
        let isFacebookURL = url.scheme.hasPrefix("fb\(FBSDKSettings.appID())") && url.host == "authorize"
        if isFacebookURL {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        return false
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        
        initStaticCaches()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // custom
    
    private var _sessionId: String? = nil
        
    var sessionId: String? {
        set {
            _sessionId = newValue
            SharedPreferencesUtil.getInstance().setUserSessionId(_sessionId!)
        }
        get {
            if _sessionId == nil {
                _sessionId = SharedPreferencesUtil.getInstance().getUserSessionId()
            }
            return _sessionId
        }
    }
    
    static func getInstance() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
   
    func initStaticCaches() {
        DistrictCache.refresh()
        CountryCache.refresh()
        CategoryCache.refresh()
        ImageUtil.setMaxCachePeriod(3)
        ViewUtil.initDefaultAppearance()
    }
    
    func initUserCaches() {
        //NotificationCounter.mInstance.refresh()
        //ConversationCache.refresh()
    }
    
    func clearAll() {
        clearUserSession()
        clearPreferences()
    }
    
    func clearPreferences() {
        SharedPreferencesUtil.getInstance().clearAll()
    }
    
    func clearUserCaches() {
        NotificationCounter.clear()
        UserInfoCache.clear()
    }
    
    func clearUserSession() {
        clearUserCaches()
        self.sessionId = ""
    }
    
    func logOut() {
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKLoginManager().logOut()
        }
        clearAll()
    }
}

