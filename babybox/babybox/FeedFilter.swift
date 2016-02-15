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
        case CATEGORY_NEWEST
        case CATEGORY_PRICE_LOW_HIGH
        case CATEGORY_PRICE_HIGH_LOW
        case USER_POSTED
        case USER_LIKED
        case USER_FOLLOWING
        
        init() {
            self = .HOME_EXPLORE
        }
        
    }
    
    enum FeedProductType {
        case ALL
        case NEW
        case USED
        
        init() {
            self = .ALL
        }
    }
}
