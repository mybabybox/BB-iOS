//
//  SharedPreferencesUtil.swift
//  babybox
//
//  Created by Mac on 19/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation

class SharedPreferencesUtil {
    
    enum Screen: String {
        case HOME_TAB = "HOME_TAB"
        case SEARCH_TAB = "SEARCH_TAB"
        case PROFILE_TAB = "PROFILE_TAB"
        case HOME_EXPLORE_TIPS = "HOME_EXPLORE_TIPS"
        case HOME_TRENDING_TIPS = "HOME_TRENDING_TIPS"
        case HOME_FOLLOWING_TIPS = "HOME_FOLLOWING_TIPS"
        case CATEGORY_TIPS = "CATEGORY_TIPS"
        case MY_PROFILE_TIPS = "MY_PROFILE_TIPS"
    }
    
    enum User: String {
        case ACCESS_TOKEN = "accessToken"
        case USER_INFO = "userInfo"
    }
    private static let sharedPreferencesUtil = SharedPreferencesUtil()
    var prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    static func getInstance() -> SharedPreferencesUtil {
        return sharedPreferencesUtil
    }
    
    func isScreenViewed(screen: Screen) -> Bool {
        print(self.prefs.objectForKey(screen.rawValue))
        if (self.prefs.objectForKey(screen.rawValue) == nil) {
            return false
        } else {
            return self.prefs.objectForKey(screen.rawValue) as! Bool
        }
      
    }
    
    func setScreenViewed(screen: Screen) {
        self.prefs.setBool(true, forKey: screen.rawValue)
    }
    
    func setUserAccessToken(accessToken: String) {
        self.prefs.setValue(accessToken, forKey: User.ACCESS_TOKEN.rawValue)
    }
    
    func getUserAccessToken(accessToken: String) -> String {
        return String(self.prefs.valueForKey(User.ACCESS_TOKEN.rawValue))
    }
    
    func saveUserInfo(userInfo: UserInfoVM) {
        self.prefs.setValue(userInfo, forKey: User.USER_INFO.rawValue)
    }
    
    func getUserInfo() -> UserInfoVM {
        return self.prefs.valueForKey(User.USER_INFO.rawValue) as! UserInfoVM
    }
    
}