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
    
    static func showActivityIndicatory(uiView: UIView, actInd: UIActivityIndicatorView) {
        let container: UIView = UIView()
        container.frame = uiView.frame
        container.center = uiView.center
        
        let v = UIColor(
            red: CGFloat((0xffffff & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((0xffffff & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(0xffffff & 0x0000FF) / 255.0,
            alpha: CGFloat(0.3)
        )
        
        container.backgroundColor = v
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = uiView.center
        let v1 = UIColor(
            red: CGFloat((0xffffff & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((0xffffff & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(0xffffff & 0x0000FF) / 255.0,
            alpha: CGFloat(0.7)
        )
        loadingView.backgroundColor = v1
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        //let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        actInd.center = CGPointMake(loadingView.frame.size.width / 2,
            loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.hidden = false
        actInd.startAnimating()
    }
    
    static func showActivityLoading(activityLoading: UIActivityIndicatorView?) {
        //activityLoading.hidden = false
        activityLoading?.startAnimating()
        NSLog("showActivityLoading")
    }
    
    static func hideActivityLoading(activityLoading: UIActivityIndicatorView?) {
        //activityLoading.hidden = true
        activityLoading?.stopAnimating()
        NSLog("hideActivityLoading")
    }
}
