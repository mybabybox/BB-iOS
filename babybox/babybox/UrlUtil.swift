//
//  UrlUtil.swift
//  BabyBox
//
//  Created by Keith Lei on 2/25/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import UIKit

class UrlUtil {
    static let ENCODE_CHARSET_UTF8 = "UTF-8"
    
    // NOTE: let str = String(format:"%d , %f, %ld, %@", INT_VALUE, FLOAT_VALUE, DOUBLE_VALUE, STRING_VALUE)
    static let SELLER_URL = Constants.BASE_URL + "/seller/%d"
    static let PRODUCT_URL = Constants.BASE_URL + "/product/%d"
    static let CATEGORY_URL = Constants.BASE_URL + "/category/%d"
    
    static let APPS_DOWNLOAD_URL = "https://goo.gl/BdQeze"
    static let REFERRAL_URL = Constants.BASE_URL + "/signup-code/%@"
    
    static let SELLER_URL_REGEX = ".*/seller/(\\d+)"
    static let PRODUCT_URL_REGEX = ".*/product/(\\d+)"
    static let CATEGORY_URL_REGEX = ".*/category/(\\d+)"
    
    static var sellerName: String = ""
    static var isSellerDeepLink: Bool = false
    static var isProductDeepLink: Bool = false
    static var deepLinkProductId: Int = -1
    
    static let HTTP_PREFIXES = [
        "http://www.",
        "https://www.",
        "http://",
        "https://",
        "www."
    ]

    static func getFullUrl(url: String) -> String {
        if !url.hasPrefix("http") {
            return Constants.BASE_URL + url
        }
        return url
    }
    
    static func createSellerUrl(user: UserVMLite) -> String {
        return String(format: Constants.DEEP_LINK_URL_SCHEME, SELLER_URL, user.id)
    }
    
    static func createProductUrl(post: PostVMLite) -> String {
        return String(format: Constants.DEEP_LINK_URL_SCHEME, PRODUCT_URL, post.id)
    }
    
    static func createCategoryUrl(category: CategoryVM) -> String {
        return String(format: CATEGORY_URL, category.id)
    }
    
    static func createAppsDownloadUrl() -> String {
        return APPS_DOWNLOAD_URL
    }
    
    static func createShortSellerUrl(user: UserVMLite) -> String {
        let url = createSellerUrl(user)
        return "Shop" + ": " + stripHttpPrefix(url)
    }
    
    static func stripHttpPrefix(url: String) -> String {
        for prefix in HTTP_PREFIXES {
            if url.hasPrefix(prefix) {
                return StringUtil.replace(url, from: prefix, to: "")
            }
        }
        return url
    }
    
    static func handleDeepLinkRedirection(viewController: UIViewController, successCallback: ((UserVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        //Check whether the app is opened using notification message
        
        if UrlUtil.isProductDeepLink {
            let vController =  viewController.storyboard!.instantiateViewControllerWithIdentifier("ProductViewController") as! ProductViewController
            let feedItem: PostVMLite = PostVMLite()
            feedItem.id = UrlUtil.deepLinkProductId
            vController.feedItem = feedItem
            vController.hidesBottomBarWhenPushed = true
            viewController.navigationController?.pushViewController(vController, animated: true)
            UrlUtil.isProductDeepLink = false
            UrlUtil.deepLinkProductId = -1
        } else if UrlUtil.isSellerDeepLink {
            UrlUtil.isSellerDeepLink = false
            ApiFacade.getUserByDisplayName(UrlUtil.sellerName, successCallback: successCallback, failureCallback: failureCallback)
        }
    }
    
}