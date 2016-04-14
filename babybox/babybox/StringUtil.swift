//
//  StringUtil.swift
//  BabyBox
//
//  Created by Keith Lei on 2/25/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation

class StringUtil {
    
    static func trim(str: String?) -> String {
        return trim(str, charSet: NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    static func trim(str: String?, charSet: NSCharacterSet) -> String {
        if let _ = str {
            return str!.stringByTrimmingCharactersInSet(charSet)
        }
        return ""
    }
    
    static func replace(str: String, from: String, to: String) -> String {
        return str.stringByReplacingOccurrencesOfString(from, withString: to, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    static func encode(url: String) -> String {
        return url.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
    }
    
    static func toEncodedData(param: String) -> NSData {
        return param.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
}