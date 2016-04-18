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
    
    static let BASE_URL = "http://www.baby-box.com.hk"
    static let BASE_IMAGE_URL = "http://www.baby-box.com.hk"
    
    //static let BASE_URL = "http://119.81.228.91"
    //static let BASE_IMAGE_URL = "http://119.81.228.91"
    
    //static let BASE_URL = "http://192.168.1.116:9000"
    //static let BASE_IMAGE_URL = "http://192.168.1.116:9000"
    
    static let DEEP_LINK_URL_SCHEME = "babybox://"
    
    static let DEVICE_TYPE = "IOS";
    static let CURRENCY_SYMBOL = "$"
    
    static let HTTP_STATUS_OK = 200;
    static let HTTP_STATUS_BAD_REQUEST = 400;
    
    static let SPLASH_SHOW_DURATION = 0.5
    static let FEED_LOAD_SCROLL_THRESHOLD = CGFloat(50.0)
    static let SHOW_HIDE_BAR_SCROLL_DISTANCE = CGFloat(5.0)
    static let MAIN_BOTTOM_BAR_ALPHA = 0.9
    static let BANNER_REFRESH_TIME_INTERVAL = 5.0
    
    // sizes
    static let DEFAULT_BUTTON_CORNER_RADIUS = CGFloat(7)
    static let DEFAULT_CIRCLE_RADIUS = CGFloat(25)
    static let DEFAULT_CORNER_RADIUS = CGFloat(5)
    static let DEFAULT_SPACING = CGFloat(10)
    static let HOME_BANNER_WIDTH_HEIGHT_RATIO = CGFloat(3)
    static let HOME_HEADER_ITEMS_MARGIN_TOTAL = CGFloat(12)     // 3 each x 4
    static let CATEGORY_HEADER_HEIGHT = CGFloat(150)
    static let PROFILE_HEADER_HEIGHT = CGFloat(190)
    static let FEED_ITEM_CORNER_RADIUS = CGFloat(0)
    static let FEED_ITEM_SIDE_SPACING = CGFloat(12)
    static let FEED_ITEM_LINE_SPACING = CGFloat(12)
    static let FEED_ITEM_DETAILS_HEIGHT = CGFloat(35)
    static let SELLER_FEED_ITEM_DETAILS_HEIGHT = CGFloat(70)
    static let MESSAGE_BUBBLE_CORNER_RADIUS = CGFloat(5)
    static let MESSAGE_IMAGE_WIDTH = CGFloat(0.65)
    static let MESSAGE_LOAD_MORE_BTN_HEIGHT = CGFloat(0)
    static let IMAGE_RESIZE_DIMENSION = CGFloat(640)
    static let NO_ITEM_TIP_TEXT_CELL_HEIGHT = CGFloat(70)
    static let HOME_BANNER_VIEW_HEIGHT = CGFloat(100)
    
    // strings
    static let ACTIVITY_FIRST_POST = NSLocalizedString("now_seller", comment: "") //"You are now a BabyBox seller! Your first product has been listed:\n"
    static let ACTIVITY_NEW_POST = NSLocalizedString("new_product", comment: "") // "New product listed:\n"
    static let ACTIVITY_COMMENTED = NSLocalizedString("product_commented", comment: "") // "commented on product:\n"
    static let ACTIVITY_LIKED = NSLocalizedString("product_liked", comment: "") //"liked your product."
    static let ACTIVITY_FOLLOWED = NSLocalizedString("started_following", comment: "") //"started following you."
    static let ACTIVITY_SOLD = NSLocalizedString("sold", comment: "") //"already sold."
    static let ACTIVITY_GAME_BADGE = NSLocalizedString("new_badge_msg", comment: "") // "Congratulations! You got a new badge:\n"
    static let SHARING_SELLER_MSG_PREFIX: String = NSLocalizedString("notif_checkout_msg", comment: "") //"Check out BabyBox Seller"
    
    static let SETTING_EMAIL_NOTIF_NEW_PRODUCT = NSLocalizedString("product_listed", comment: "") //"Product listed"
    static let SETTING_EMAIL_NOTIF_NEW_CHAT = NSLocalizedString("new_chat", comment: "") //"New chat"
    static let SETTING_EMAIL_NOTIF_NEW_COMMENT = NSLocalizedString("new_comment", comment: "") //"New comment on your products"
    static let SETTING_EMAIL_NOTIF_NEW_PROMOTIONS = NSLocalizedString("new_promotions", comment: "") //"New promotions"
    static let SETTING_PUSH_NOTIF_NEW_CHAT = NSLocalizedString("new_chat", comment: "") //"New chat"
    static let SETTING_PUSH_NOTIF_NEW_COMMENT = NSLocalizedString("new_comment", comment: "") //"New comment on your products"
    static let SETTING_PUSH_NOTIF_NEW_FOLLOW = NSLocalizedString("new_follower", comment: "") //"New follower"
    static let SETTING_PUSH_NOTIF_NEW_FEEDBACK = NSLocalizedString("new_review", comment: "") //"New review"
    static let SETTING_PUSH_NOTIF_NEW_PROMOTIONS = NSLocalizedString("new_promotions", comment: "") //"New promotions"
    
    static let NO_FOLLOWINGS = NSLocalizedString("no_followings", comment: "") //"~ No Followings ~"
    static let NO_FOLLOWERS = NSLocalizedString("no_followers", comment: "") //
    
    static let NO_POSTS = NSLocalizedString("no_posts", comment: "") //"~~ No posts ~~"
    static let NO_LIKES = NSLocalizedString("no_likes", comment: "") // "~~ No Likes ~~"
    
    static let CONVERSATION_MESSAGE_COUNT = 20;
    
    static let PRODUCT_SOLD_TEXT = NSLocalizedString("product_sold", comment: "") // "This item has been sold"
    static let PRODUCT_SOLD_CONFIRM_TEXT = NSLocalizedString("confirm_sold", comment: "")
    //"Confirm product has been sold?\nYou will no longer receive chats and orders for this product"
    
    static let DELETE_COMMENT_TEXT = NSLocalizedString("delete_comment", comment: "") //"Delete comment?"
    
    static let PM_ORDER_CANCELLED = NSLocalizedString("pm_order_cancelled", comment: "") //"Order cancelled"
    static let PM_ORDER_ACCEPTED_FOR_BUYER = NSLocalizedString("pm_order_accepted_for_buyer", comment: "") //"Seller has accepted your order"
    static let PM_ORDER_DECLINED_FOR_BUYER = NSLocalizedString("pm_order_declined_for_buyer", comment: "") //"Seller declined your order"
    
    static let PM_ORDER_ACCEPTED_FOR_SELLER = NSLocalizedString("pm_order_accepted_for_seller", comment: "") //"Order has been accepted"
    static let PM_ORDER_DECLINED_FOR_SELLER = NSLocalizedString("pm_order_declined_for_seller", comment: "") //"Order has been declined"
    
    static let NO_PRODUCT_TEXT = NSLocalizedString("no_product_text", comment: "") //"~ No Products ~"
    static let NO_FOLLOWING_TEXT = NSLocalizedString("no_following_text", comment: "") //"~ No Followings ~"
}