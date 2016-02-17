//
//  FeedType.swift
//  babybox
//
//  Created by Mac on 16/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation

class FeedFilter {

    enum FeedType {
        case HOME_EXPLORE
        case HOME_FOLLOWING
        case CATEGORY_POPULAR
        case CATEGORY_POPULAR_NEW
        case CATEGORY_POPULAR_USED
        case CATEGORY_NEWEST
        case CATEGORY_PRICE_LOW_HIGH
        case CATEGORY_PRICE_HIGH_LOW
        case HASHTAG_POPULAR
        case HASHTAG_POPULAR_NEW
        case HASHTAG_POPULAR_USED
        case HASHTAG_NEWEST
        case HASHTAG_PRICE_LOW_HIGH
        case HASHTAG_PRICE_HIGH_LOW
        case USER_POSTED
        case USER_LIKED
        case USER_FOLLOWINGS
        case USER_FOLLOWERS
        case PRODUCT_LIKES
        case PRODUCT_SUGGEST
        case RECOMMENDED_SELLERS
        case USER_RECOMMENDED_SELLERS
        
        init() {
            self = .HOME_EXPLORE
        }
    }
    
    enum ConditionType {
        case ALL
        case NEW
        case USED
        
        init() {
            self = .ALL
        }
    }
}
