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
    
    internal static var userInfoVM: UserInfoVM? = nil
    
    init() {
        
    }
    
    public static func refresh() {
        ApiControlller.apiController.getUserInfo()
    }
    
    public static func getUser() -> UserInfoVM {
        if (userInfoVM == nil) {
            //let sharedPref: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            //userInfoVM = sharedPref.objectForKey(USER_INFO) as? UserInfoVM
            userInfoVM = SharedPreferencesUtil.getInstance().getUserInfo()
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
    
}