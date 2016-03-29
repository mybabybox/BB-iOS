//
//  Constants.swift
//  Baby Box
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    static let APP_NAME = "BabyBox"
    
    static let BASE_URL = "http://119.81.228.91"
    static let BASE_IMAGE_URL = "http://119.81.228.91"
    
    static let DEVICE_TYPE = "IOS";
    static let CURRENCY_SYMBOL = "$"
    
    static let HTTP_STATUS_OK = 200;
    static let HTTP_STATUS_BAD_REQUEST = 400;
    
    static let SPLASH_SHOW_DURATION = 0.5
    static let FEED_LOAD_SCROLL_THRESHOLD = CGFloat(50.0)
    static let SHOW_HIDE_BAR_SCROLL_DISTANCE = CGFloat(5.0)
    static let MAIN_BOTTOM_BAR_ALPHA = 0.9
    
    static let FEED_ITEM_SIDE_SPACING = CGFloat(10)
    static let FEED_ITEM_LINE_SPACING = CGFloat(10)
    static let MESSAGE_IMAGE_WIDTH = CGFloat(0.65)
    
    static let ACTIVITY_FIRST_POST = "Congratulations! You are now a BabyBox seller! Your first product has been listed:\r\n"
    static let ACTIVITY_NEW_POST = "New product listed:\r\n"
    static let ACTIVITY_COMMENTED = "commented on product:\n"
    static let ACTIVITY_LIKED = "liked your product."
    static let ACTIVITY_FOLLOWED = "started following you."
    static let ACTIVITY_SOLD = "already sold."
    static let ACTIVITY_GAME_BADGE = "Congratulations! You got a new badge:\r\n"
    static let SHARING_SELLER_MSG_PREFIX: String = "Check out BabyBox Seller"
    
    static let NO_FOLLOWINGS = "~ No Followings ~"
    static let NO_FOLLOWERS = "~ No Followers ~"
}