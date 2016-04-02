//
//  ProductInfoHelper.swift
//  BabyBox
//
//  Created by admin on 02/04/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftEventBus

class ProductInfoHelper {

    static func getPostById(postId: Int, successCallback: ((PostVM) -> Void)?, failureCallback: ((String?) -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "postByIdLoadSuccess") { result in
            SwiftEventBus.unregister(self)
            
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("Product info returned is empty")
                return
            }
            
            if successCallback != nil {
                successCallback!((result.object as? PostVM)!)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "postByIdLoadFailed") { result in
            SwiftEventBus.unregister(self)
            
            if failureCallback != nil {
                var error = "Failed to get product info..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getPostById(postId)
    }
    
}