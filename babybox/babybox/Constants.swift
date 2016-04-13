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
    
    // sizes
    static let GENERAL_SPACING = CGFloat(10)
    static let HOME_HEADER_ITEMS_MARGIN_TOTAL = CGFloat(12)     // 3 each
    static let CATEGORY_HEADER_HEIGHT = CGFloat(150)
    static let PROFILE_HEADER_HEIGHT = CGFloat(190)
    static let FEED_ITEM_SIDE_SPACING = CGFloat(7)
    static let FEED_ITEM_LINE_SPACING = CGFloat(7)
    static let FEED_ITEM_DETAILS_HEIGHT = CGFloat(35)
    static let SELLER_FEED_ITEM_DETAILS_HEIGHT = CGFloat(70)
    static let MESSAGE_IMAGE_WIDTH = CGFloat(0.65)
    static let MESSAGE_LOAD_MORE_BTN_HEIGHT = CGFloat(0)
    
    // strings
    static let ACTIVITY_FIRST_POST = "You are now a BabyBox seller! Your first product has been listed:\n"
    static let ACTIVITY_NEW_POST = "New product listed:\n"
    static let ACTIVITY_COMMENTED = "commented on product:\n"
    static let ACTIVITY_LIKED = "liked your product."
    static let ACTIVITY_FOLLOWED = "started following you."
    static let ACTIVITY_SOLD = "already sold."
    static let ACTIVITY_GAME_BADGE = "Congratulations! You got a new badge:\n"
    static let SHARING_SELLER_MSG_PREFIX: String = "Check out BabyBox Seller"
    
    static let SETTING_EMAIL_NOTIF_NEW_PRODUCT = "Product listed"
    static let SETTING_EMAIL_NOTIF_NEW_CHAT = "New chat"
    static let SETTING_EMAIL_NOTIF_NEW_COMMENT = "New comment on your products"
    static let SETTING_EMAIL_NOTIF_NEW_PROMOTIONS = "New promotions"
    static let SETTING_PUSH_NOTIF_NEW_CHAT = "New chat"
    static let SETTING_PUSH_NOTIF_NEW_COMMENT = "New comment on your products"
    static let SETTING_PUSH_NOTIF_NEW_FOLLOW = "New follower"
    static let SETTING_PUSH_NOTIF_NEW_FEEDBACK = "New review"
    static let SETTING_PUSH_NOTIF_NEW_PROMOTIONS = "New promotions"
    
    static let NO_FOLLOWINGS = "~ No Followings ~"
    static let NO_FOLLOWERS = "~ No Followers ~"
    
    static let NO_POSTS = "~~ No posts ~~"
    static let NO_LIKES = "~~ No Likes ~~"
    
    static let CONVERSATION_MESSAGE_COUNT = 20;
    
    static let PRODUCT_SOLD_TEXT = "This item has been sold"
    static let PRODUCT_SOLD_CONFIRM_TEXT = "Confirm product has been sold?\nYou will no longer receive chats and orders for this product"
    
    static let DELETE_COMMENT_TEXT = "Delete comment?"
    
    static let DEEP_LINK_URL_SCHEME = "babybox://"
}