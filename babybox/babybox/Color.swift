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
    
    static let CLEAR: UIColor = UIColor.clearColor()
    static let WHITE: UIColor = UIColor.whiteColor()
    static let BLACK: UIColor = UIColor.blackColor()
    static let RED: UIColor = UIColor.redColor()
    static let GRAY: UIColor = UIColor.grayColor()
    static let LIGHT_GRAY: UIColor = UIColor.lightGrayColor()
    static let DARK_GRAY: UIColor = UIColor.darkGrayColor()
    static let PINK: UIColor = Color.fromRGB(0xFF76A4)
    
    static let MENU_BAR_BG: UIColor = Color.fromRGB(0xFCFAF8)
    static let IMAGE_LOAD_BG: UIColor = Color.fromRGB(0xFFF2EF)
    static let CHAT_YOU: UIColor = Color.fromRGB(0xDCF8C6)
    static let CHAT_ME: UIColor = Color.fromRGB(0xFFFFFF)
    
    
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