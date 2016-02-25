//
//  UrlUtil.swift
//  BabyBox
//
//  Created by Keith Lei on 2/25/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation

class UrlUtil {
    static let ENCODE_CHARSET_UTF8 = "UTF-8"
    
    // NOTE: let str = String(format:"%d , %f, %ld, %@", INT_VALUE, FLOAT_VALUE, DOUBLE_VALUE, STRING_VALUE);
    static let SELLER_URL = constants.kBaseServerURL + "/seller/%d"
    static let PRODUCT_URL = constants.kBaseServerURL + "/product/%d"
    static let CATEGORY_URL = constants.kBaseServerURL + "/category/%d"
    
    static let APPS_DOWNLOAD_URL = "https://goo.gl/BdQeze";
    static let REFERRAL_URL = constants.kBaseServerURL + "/signup-code/%@";
    
    static let SELLER_URL_REGEX = ".*/seller/(\\d+)";
    static let PRODUCT_URL_REGEX = ".*/product/(\\d+)";
    static let CATEGORY_URL_REGEX = ".*/category/(\\d+)";
    
    static let HTTP_PREFIXES = [
        "http://www.",
        "https://www.",
        "http://",
        "https://",
        "www."
    ]

    static func getFullUrl(url: String) -> String {
        if !url.hasPrefix("http") {
            return constants.kBaseServerURL + url
        }
        return url
    }
    
    static func createSellerUrl(user: UserVM) -> String {
        return String(format: SELLER_URL, user.id);
    }
    
    static func createProductUrl(post: PostModel) -> String {
        return String(format: PRODUCT_URL, post.id);
    }
    
    static func createCategoryUrl(category: CategoryVM) -> String {
        return String(format: CATEGORY_URL, category.id);
    }
    
    static func createAppsDownloadUrl() -> String {
        return APPS_DOWNLOAD_URL;
    }
    
    static func createShortSellerUrl(user: UserVM) -> String {
        let url = createSellerUrl(user);
        return "Shop" + ": " + stripHttpPrefix(url);
    }
    
    static func stripHttpPrefix(url: String) -> String {
        for prefix in HTTP_PREFIXES {
            if url.hasPrefix(prefix) {
                return StringUtil.replace(url, from: prefix, to: "");
            }
        }
        return url;
    }
    
    
    
    
    
    
    
}