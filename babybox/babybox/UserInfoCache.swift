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
    
    static var userInfo: UserVM? = nil
    
    init() {
    }

    static func refresh(sessionId: String) {
        refresh(sessionId, successCallback: nil, failureCallback: nil)
    }
    
    static func refresh(sessionId: String, successCallback: ((UserVM) -> Void)?, failureCallback: ((error: String) -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "userInfoSuccess") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!(error: "User returned is empty")
                return
            }
            
            self.userInfo = result.object as? UserVM
            if successCallback != nil {
                successCallback!(self.userInfo!)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "userInfoFailed") { result in
            if failureCallback != nil {
                var error = "Failed to get user info..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error: error)
            }
        }

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