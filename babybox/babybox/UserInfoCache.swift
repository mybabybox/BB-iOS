//
//  UserCache.swift
//  babybox
//
//  Created by Mac on 04/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftEventBus

class UserInfoCache {
    
    internal static let USER_INFO = "userInfo"
    internal static var userInfoVM: UserInfoVM? = nil
    
    init() {
        SwiftEventBus.onMainThread(self, name: "userInfoSuccess") { result in
            // UI thread
            print(result.object)
            UserInfoCache.userInfoVM = result.object as? UserInfoVM
            let sharedPref: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            sharedPref.setObject(UserInfoCache.userInfoVM, forKey: UserInfoCache.USER_INFO)
        }
    }
    
    public static func refresh() {
        ApiControlller.apiController.getUserInfo()
    }
    
    public static func getUser() -> UserInfoVM {
        if (userInfoVM == nil) {
            let sharedPref: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            userInfoVM = sharedPref.objectForKey(USER_INFO) as? UserInfoVM
            
        }
        return userInfoVM!
    }
    
    public static func incrementNumProducts() {
        getUser().numProducts++;
    }
    
    public static func decrementNumProducts() {
        getUser().numProducts--;
    }
    
    public static func incrementNumLikes() {
        getUser().numLikes++;
    }
    
    public static func decrementNumLikes() {
        getUser().numLikes--;
    }
    
    public static func clear() {
        let sharedPref: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        sharedPref.setObject(nil, forKey: UserInfoCache.USER_INFO)
    }
    
}