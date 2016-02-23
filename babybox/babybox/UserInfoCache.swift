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
    
    static func refresh(sessionId: String) {
        SharedPreferencesUtil.getInstance().setUserAccessToken(sessionId)
        constants.accessToken = sessionId
        ApiControlller.apiController.getUserInfo()
    }
    
    static func getUser() -> UserInfoVM {
        if (userInfoVM == nil) {
            //let sharedPref: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            //userInfoVM = sharedPref.objectForKey(USER_INFO) as? UserInfoVM
            userInfoVM = SharedPreferencesUtil.getInstance().getUserInfo()
        }
        return userInfoVM!
    }
    
    static func incrementNumProducts() {
        getUser().numProducts++;
    }
    
    static func decrementNumProducts() {
        getUser().numProducts--;
    }
    
    static func incrementNumLikes() {
        getUser().numLikes++;
    }
    
    static func decrementNumLikes() {
        getUser().numLikes--;
    }
    
}