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
    
    internal static var userInfo: UserVM? = nil
    
    init() {
    }
    
    static func refresh(sessionId: String) {
        AppDelegate.getInstance().sessionId = sessionId
        ApiController.instance.getUserInfo()
    }
    
    static func setUser(userInfo: UserVM) {
        self.userInfo = userInfo
        SharedPreferencesUtil.getInstance().saveUserInfo(userInfo)
    }
    
    static func getUser() -> UserVM {
        if (userInfo == nil) {
            userInfo = SharedPreferencesUtil.getInstance().getUserInfo()
        }
        return userInfo!
    }
    
    static func clear() {
        userInfo = nil
    }
    
    static func incrementNumProducts() {
        getUser().numProducts++
    }
    
    static func decrementNumProducts() {
        getUser().numProducts--
    }
    
    static func incrementNumLikes() {
        getUser().numLikes++
    }
    
    static func decrementNumLikes() {
        getUser().numLikes--
    }
    
}