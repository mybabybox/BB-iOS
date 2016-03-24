//
//  NSDateExtension.swift
//  babybox
//
//  Created by Mac on 18/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation

//
//  NSDate+Extension.swift
//  Tasty
//
//  Created by Vitaliy Kuzmenko on 17/10/14.
//  http://github.com/vitkuzmenko
//  Copyright (c) 2014 Vitaliy Kuz'menko. All rights reserved.
//

import Foundation

func NSDateTimeAgoLocalizedStrings(key: String) -> String {
    let resourcePath: String?
    
    if let frameworkBundle = NSBundle(identifier: "com.kevinlawler.NSDateTimeAgo") {
        // Load from Framework
        resourcePath = frameworkBundle.resourcePath
    } else {
        // Load from Main Bundle
        resourcePath = NSBundle.mainBundle().resourcePath
    }
    
    if resourcePath == nil {
        return ""
    }
    
    let path = NSURL(fileURLWithPath: resourcePath!).URLByAppendingPathComponent("NSDateTimeAgo.bundle")
    guard let bundle = NSBundle(URL: path) else {
        return ""
    }
    
    return NSLocalizedString(key, tableName: "NSDateTimeAgo", bundle: bundle, comment: "")
}

extension NSDate {
    
    // shows 1 or two letter abbreviation for units.
    // does not include 'ago' text ... just {value}{unit-abbreviation}
    // does not include interim summary options such as 'Just now'
    public var timeAgoSimple: String {
        let components = self.dateComponents()
        
        if components.year > 0 {
            return stringFromFormat("%%d%@yr", withValue: components.year)
        }
        
        if components.month > 0 {
            return stringFromFormat("%%d%@mo", withValue: components.month)
        }
        
        // TODO: localize for other calanders
        if components.day >= 7 {
            let value = components.day/7
            return stringFromFormat("%%d%@w", withValue: value)
        }
        
        if components.day > 0 {
            return stringFromFormat("%%d%@d", withValue: components.day)
        }
        
        if components.hour > 0 {
            return stringFromFormat("%%d%@h", withValue: components.hour)
        }
        
        if components.minute > 0 {
            return stringFromFormat("%%d%@m", withValue: components.minute)
        }
        
        if components.second > 0 {
            return stringFromFormat("%%d%@s", withValue: components.second )
        }
        
        return ""
    }
    
    public var timeAgo: String {
        let components = self.dateComponents()
        
        if components.year > 0 {
            if components.year < 2 {
                return "Last year"
            } else {
                return stringFromFormat("years ago", withValue: components.year)
            }
        }
        
        if components.month > 0 {
            if components.month < 2 {
                return "Last month"
            } else {
                return stringFromFormat("months ago", withValue: components.month)
            }
        }
        
        // TODO: localize for other calanders
        if components.day >= 7 {
            let week = components.day/7
            if week < 2 {
                return "7 days ago"
            } else {
                return stringFromFormat("weeks ago", withValue: week)
            }
        }
        
        if components.day > 0 {
            if components.day < 2 {
                return "Yesterday"
            } else  {
                return stringFromFormat("days ago", withValue: components.day)
            }
        }
        
        if components.hour > 0 {
            if components.hour < 2 {
                return "An hour ago"
            } else  {
                return stringFromFormat("hours ago", withValue: components.hour)
            }
        }
        
        if components.minute > 0 {
            if components.minute < 2 {
                return "1min ago"
            } else {
                return stringFromFormat("mins ago", withValue: components.minute)
            }
        }
        
        if components.second > 0 {
            if components.second < 5 {
                return "moments ago"
            } else {
                return stringFromFormat("seconds ago", withValue: components.second)
                //return String(components.second + " seconds ago"
            }
        }
        print(components.second)
        if components.second <= 0 {
            return "moments ago"
        }
        
        return ""
    }
    
    private func dateComponents() -> NSDateComponents {
        let calander = NSCalendar.currentCalendar()
        return calander.components([.Second, .Minute, .Hour, .Day, .Month, .Year], fromDate: self, toDate: NSDate(), options: [])
    }
    
    private func stringFromFormat(format: String, withValue value: Int) -> String {
        let localeFormat = String(value) + format //String(format: format, value)
        //return String(format: NSDateTimeAgoLocalizedStrings(localeFormat), value)
        return localeFormat
    }
    
    private func getLocaleFormatUnderscoresWithValue(value: Double) -> String {
        guard let localeCode = NSLocale.preferredLanguages().first else {
            return ""
        }
        
        // Russian (ru) and Ukrainian (uk)
        if localeCode == "ru" || localeCode == "uk" {
            let XY = Int(floor(value)) % 100
            let Y = Int(floor(value)) % 10
            
            if Y == 0 || Y > 4 || (XY > 10 && XY < 15) {
                return ""
            }
            
            if Y > 1 && Y < 5 && (XY < 10 || XY > 20) {
                return "_"
            }
            
            if Y == 1 && XY != 11 {
                return "__"
            }
        }
        
        return ""
    }
    
}

