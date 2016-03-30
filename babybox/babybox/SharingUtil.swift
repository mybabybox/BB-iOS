//
//  SharingUtil.swift
//  babybox
//
//  Created by admin on 20/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import FBSDKShareKit

class SharingUtil {
    
    enum SharingType: String {
        case WHATSAPP
        case FACEBOOK
    }
    
    static let SHARING_MESSAGE_NOTE:String = ""
    
    static func shareToWhatsapp(user: UserVM) -> Void {
        let title: String = Constants.SHARING_SELLER_MSG_PREFIX + ViewUtil.LINE_BREAK + user.displayName
        shareTo(title, description: "", url: UrlUtil.createSellerUrl(user), type: SharingType.WHATSAPP, vController: nil)
    }
    
    static func shareToFacebook(user: UserVM, vController: UIViewController) -> Void {
        let title:String  = user.displayName
        let description:String = Constants.SHARING_SELLER_MSG_PREFIX
        shareTo(title, description: description, url: UrlUtil.createSellerUrl(user), type: SharingType.FACEBOOK, vController: vController);
    }
    
    static func shareToWhatsapp(post:PostVM) -> Void {
        let title:String = post.title + " $" + String(Int(post.price)) + ViewUtil.LINE_BREAK
        shareTo(title, description: "", url: UrlUtil.createProductUrl(post), type: SharingType.WHATSAPP, vController: nil);
    }
    
    static func shareToFacebook(post: PostVM, vController: UIViewController) -> Void {
        let title:String = post.title
        let description:String = "$" + String(Int(post.price)) + " " + post.body
        shareTo(title, description: description, url: UrlUtil.createProductUrl(post), type: SharingType.FACEBOOK, vController: vController);
    }
    
    static func shareToWhatsapp(category: CategoryVM) -> Void {
        let title:String = category.name
        shareTo(title, description: "", url: UrlUtil.createCategoryUrl(category), type: SharingType.WHATSAPP, vController: nil);
    }
    
    static func shareToFacebook(category: CategoryVM, vController: UIViewController) -> Void {
        let title: String = category.name
        let description: String = category.description
        shareTo(title, description: description, url: UrlUtil.createCategoryUrl(category), type: SharingType.FACEBOOK, vController: vController);
    }
    
    /**
    * http://www.whatsapp.com/faq/en/iphone/23559013
    * http://www.oodlestechnologies.com/blogs/Sending-WhatsApp-message-through-app-in-Swift
    */
    static func shareTo(title:String, description:String, url:String, type:SharingType, vController: UIViewController?) -> Void {
        switch(type) {
            case SharingType.WHATSAPP:
                shareToWhatsapp(title, description: description, url: url);
            case SharingType.FACEBOOK:
                shareToFacebook(title, description: description, url: url, vController: vController!)
        }
    }
    
    static func shareToWhatsapp(title: String, description: String, url: String) -> Void {
        let urlString = title + url
        let urlStringEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())
        let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded!)")
        
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        } else {
            let errorAlert = UIAlertView(title: "Cannot Send Message", message: "Your device is not able to send WhatsApp messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    static func shareToFacebook(title: String, description: String, url: String, vController: UIViewController) -> Void {
        //.setContentTitle(title)
        //.setContentDescription(description)
        //.setContentUrl(Uri.parse(url))
        
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: url)
        content.contentTitle = title
        content.contentDescription = description
        FBSDKShareDialog.showFromViewController(vController, withContent: content, delegate: nil)
        
    }
    
    static func getSharingTypeName(type: SharingType) -> String {
        switch (type) {
            case .WHATSAPP:
                return "Whatsapp"
            case .FACEBOOK:
                return "Facebook"
        }
    }
}