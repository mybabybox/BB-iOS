//
//  Color.swift
//  babybox
//
//  Created by Mac on 05/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Kingfisher

class Color {
    // Base colors
    static let CLEAR: UIColor = UIColor.clearColor()
    static let WHITE: UIColor = UIColor.whiteColor()
    static let BLACK: UIColor = UIColor.blackColor()
    static let RED: UIColor = UIColor.redColor()
    static let GRAY: UIColor = Color.fromRGB(0x888888)
    static let LIGHT_GRAY: UIColor = Color.fromRGB(0xBBBBBB)
    static let LIGHT_GRAY_2: UIColor = Color.fromRGB(0xDDDDDD)
    static let LIGHT_GRAY_3: UIColor = Color.fromRGB(0xF6F6F6)
    static let DARK_GRAY: UIColor = Color.fromRGB(0x555555)
    static let DARK_GRAY_2: UIColor = Color.fromRGB(0x222222)
    static let DARK_GRAY_3: UIColor = Color.fromRGB(0x111111)
    static let PINK: UIColor = Color.fromRGB(0xFF76A4)
    
    static let LIGHT_PINK: UIColor = Color.fromRGB(0xFF99B8)
    static let LIGHT_PINK_2: UIColor = Color.fromRGB(0xFFC7D2)
    static let LIGHT_PINK_3: UIColor = Color.fromRGB(0xFFEAED)
    static let LIGHT_PINK_4: UIColor = Color.fromRGB(0xFFF2EF)
    
    // Theme colors
    static let MENU_BAR_BG: UIColor = Color.fromRGB(0xFCFAF8)
    static let IMAGE_LOAD_BG: UIColor = Color.fromRGB(0xFFF2EF)
    static let VIEW_BG: UIColor = Color.fromRGB(0xF6F6F6)
    static let FEED_BG: UIColor = Color.fromRGB(0xF5F8FA)
    static let FEED_ITEM_BORDER: UIColor = LIGHT_GRAY_2
    static let CHAT_ME: UIColor = Color.fromRGB(0xDCF8C6)
    static let CHAT_YOU: UIColor = Color.fromRGB(0xFFFFFF)
    
    // Utils
    static func fromRGB(rgbValue: UInt) -> UIColor {
        return fromRGB(rgbValue, alpha: 1.0)
    }
    
    static func fromRGB(rgbValue: UInt, alpha: Double) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}