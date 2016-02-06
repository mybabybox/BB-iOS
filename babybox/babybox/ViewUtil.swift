//
//  ViewUtil.swift
//  babybox
//
//  Created by Mac on 06/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class ViewUtil {
    
    enum PostConditionType: String {
        case NEW_WITH_TAG = "New(Sealed/with tags)"
        case NEW_WITHOUT_TAG = "New(unsealed/without tags)"
        case USED = "Used"
    }
 
    static func parsePostConditionTypeFromValue(value: String) -> PostConditionType {
        //iterate enum and return the respected value.
        switch (value) {
            case PostConditionType.NEW_WITH_TAG.rawValue:
                return PostConditionType.NEW_WITH_TAG
            case PostConditionType.NEW_WITHOUT_TAG.rawValue:
                return PostConditionType.NEW_WITHOUT_TAG
            default:
                return PostConditionType.USED
        }
    }
}
