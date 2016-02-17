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
    
    static func parsePostConditionTypeFromType(type: String) -> String {
        
        if (type == String(PostConditionType.USED)) {
            return PostConditionType.USED.rawValue
        } else if (type == String(PostConditionType.NEW_WITHOUT_TAG)) {
            return PostConditionType.NEW_WITHOUT_TAG.rawValue
        } else if (type == String(PostConditionType.NEW_WITH_TAG)) {
            return PostConditionType.NEW_WITH_TAG.rawValue
        } else {
            return ""
        }
    }
    
    
    static func getScreenWidth(view: UIView) -> CGFloat {
        let screenWidth:CGFloat = view.bounds.width
        return screenWidth
    }
    
    static func resetBackButton(navigationItem: UINavigationItem) {
        let backbtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backbtn
    }
    
    static func showActivityLoading(activityLoading: UIActivityIndicatorView) {
        //activityLoading.hidden = false
        activityLoading.startAnimating()
    }
    static func hideActivityLoading(activityLoading: UIActivityIndicatorView) {
        activityLoading.stopAnimating()
        //activityLoading.hidden = true
    }
    
}
