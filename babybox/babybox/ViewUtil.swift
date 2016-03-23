//
//  ViewUtil.swift
//  babybox
//
//  Created by Mac on 06/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class ViewUtil {
    
    static let SHOW_TOAST_DURATION_SHORT = 1.0
    static let SHOW_TOAST_DURATION_LONG = 1.5
    static let DEFAULT_TOAST_POSITION = HRToastPositionCenter
    static let HTML_LINE_BREAK: String = "<br>"
    
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
    
    static func showActivityIndicator(uiView: UIView, actInd: UIActivityIndicatorView) {
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
        actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        actInd.center = CGPointMake(loadingView.frame.size.width / 2,
            loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.hidden = false
        actInd.startAnimating()
    }

    static func showDialog(title: String, message: String, view: UIViewController) {
        let dialog = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        dialog.addAction(okAction)
        view.presentViewController(dialog, animated: true, completion: nil)
    }
    
    static func makeToast(message: String, view: UIView) {
        view.makeToast(message: message, duration: SHOW_TOAST_DURATION_SHORT, position: DEFAULT_TOAST_POSITION)
    }
    
    static func isEmptyResult(result: NSNotification?) -> Bool {
        return isEmptyResult(result, message: nil, view: nil)
    }
    
    static func isEmptyResult(result: NSNotification?, message: String?, view: UIView?) -> Bool {
        if result == nil || result!.isEqual("") {
            if message != nil && view != nil {
                makeToast(message!, view: view!)
            }
            return true
        }
        if result!.object is String {
            let str = result!.object as! String
            if str.isEmpty {
                if message != nil && view != nil {
                    makeToast(message!, view: view!)
                }
                return true
            }
        }
        return false
    }
    
    static func showActivityLoading(activityLoading: UIActivityIndicatorView?) {
        activityLoading?.hidden = false
        activityLoading?.startAnimating()
        NSLog("showActivityLoading")
    }
    
    static func hideActivityLoading(activityLoading: UIActivityIndicatorView?) {
        activityLoading?.hidden = true
        activityLoading?.stopAnimating()
        NSLog("hideActivityLoading")
    }
    
    static func initActivityIndicator(activityIndicator: UIActivityIndicatorView) -> UIActivityIndicatorView {
        //activityIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5)
        /*
        activityIndicator.clipsToBounds = false
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.layer.cornerRadius = 10
        */
        return activityIndicator
    }
    
    static func selectFollowButtonStyleLite(button: UIButton) {
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        button.layer.borderColor = UIColor.grayColor().CGColor
        button.setTitle("Following", forState: UIControlState.Normal)
    }
    
    static func unselectFollowButtonStyleLite(button: UIButton) {
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.setTitleColor(ImageUtil.UIColorFromRGB(0xFF76A4), forState: UIControlState.Normal)
        button.layer.borderColor = ImageUtil.UIColorFromRGB(0xFF76A4).CGColor
        button.setTitle("Follow", forState: UIControlState.Normal)
    }
    
    static func refreshNotifications(uiTabbar: UITabBar, navigationItem: UINavigationItem) {
        let tabBarItem = (uiTabbar.items![2]) as UITabBarItem
        if (NotificationCounter.counter!.activitiesCount > 0) {
            let aCount = (NotificationCounter.counter!.activitiesCount) as Int
            tabBarItem.badgeValue = String(aCount)
        } else {
            tabBarItem.badgeValue = nil
        }
        let chatNavItem = navigationItem.rightBarButtonItems?[1] as? ENMBadgedBarButtonItem
        
        if (NotificationCounter.counter!.conversationsCount > 0) {
            let cCount = (NotificationCounter.counter!.conversationsCount) as Int
            chatNavItem?.badgeValue = String(cCount)
        } else {
            chatNavItem?.badgeValue = ""
        }
    }
    
    static func copyToClipboard(text: String) -> Void {
        UIPasteboard.generalPasteboard().string = text
    }
    
}
