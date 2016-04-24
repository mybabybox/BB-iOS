//
//  StringUtil.swift
//  BabyBox
//
//  Created by Keith Lei on 2/25/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Foundation

class ValidationUtil {

    static let USER_DISPLAYNAME_MIN_CHAR = 2
    static let USER_DISPLAYNAME_MAX_CHAR = 30
    static let USER_NAME_MAX_CHAR = 20
    
    static let EMAIL_FORMAT_REGEX = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
    static let USER_DISPLAYNAME_FORMAT_REGEX = "^[_A-Za-z0-9]+([\\._A-Za-z0-9]+)*[_A-Za-z0-9]$"
    static let USER_NAME_FORMAT_REGEX = "^[_\\p{L}0-9]+([\\._\\p{L}0-9]+)*$"      // \p{L} matches letter in any language
    
    static let ERROR_EMAIL_REQUIRED = "Email is required"
    static let ERROR_EMAIL_FORMAT = "Email format is not correct"
    static let ERROR_USER_DISPLAYNAME_REQUIRED = "Username is required"
    static let ERROR_USER_DISPLAYNAME_FORMAT = "Username may contain only letters(a-z), numbers(0-9), underscore(_), periods(.) and may not end with a period(.)"
    static let ERROR_USER_DISPLAYNAME_MIN_MAX_CHAR = "Username may be at least 2 characters and at most 30 characters"
    static let ERROR_USER_DISPLAYNAME_NO_SPACE = "Username may not contain space"
    static let ERROR_USER_DISPLAYNAME_PERIODS = "Username may not have 2 periods (.) in a row"
    static let ERROR_USER_NAME_MIN_MAX_CHAR = "Firstname and lastname may be at most 20 characters"
    
    static func isEmailValid(text: String?) -> (Bool, String?) {
        if text == nil {
            return (false, ERROR_EMAIL_REQUIRED)
        }
        
        let text = StringUtil.trim(text!)
        
        // whitespace
        if StringUtil.hasWhitespace(text) {
            return (false, ERROR_EMAIL_FORMAT)
        }
        
        return matchRegex(text, regex: EMAIL_FORMAT_REGEX, errMsg: ERROR_EMAIL_FORMAT)
    }
    
    static func isValidDisplayName(text: String?) -> (Bool, String?) {
        if text == nil {
            return (false, ERROR_USER_DISPLAYNAME_REQUIRED)
        }
        
        let text = StringUtil.trim(text!)
        
        // char 2-30
        if text.characters.count < USER_DISPLAYNAME_MIN_CHAR || text.characters.count > USER_DISPLAYNAME_MAX_CHAR {
            return (false, ERROR_USER_DISPLAYNAME_MIN_MAX_CHAR)
        }
        
        // whitespace
        if StringUtil.hasWhitespace(text) {
            return (false, ERROR_USER_DISPLAYNAME_NO_SPACE)
        }
        
        // .. in a row
        if StringUtil.containsIgnoreCase(text, subStr: "..") {
            return (false, ERROR_USER_DISPLAYNAME_PERIODS)
        }
        
        return matchRegex(text, regex: USER_DISPLAYNAME_FORMAT_REGEX, errMsg: ERROR_USER_DISPLAYNAME_FORMAT)
    }

    static func isValidUserName(text: String?) -> (Bool, String?) {
        let text = StringUtil.trim(text!)
        
        // char max 20
        if text.characters.count > USER_NAME_MAX_CHAR {
            return (false, ERROR_USER_NAME_MIN_MAX_CHAR)
        }
    
        return (true, nil)
    }
    
    static func matchRegex(text: String?, regex: String, errMsg: String) -> (Bool, String?) {
        let text = StringUtil.trim(text!)
        
        // pattern doesn't match so returning false
        if !StringUtil.matchRegex(text, regex: regex) {
            return (false, errMsg)
        }
        
        return (true, nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}