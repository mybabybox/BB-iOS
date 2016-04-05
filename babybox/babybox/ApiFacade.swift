//
//  ApiFacade.swift
//  BabyBox
//
//  Created by admin on 02/04/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftEventBus

class ApiFacade {

    static func getPost(id: Int, successCallback: ((PostVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetPost") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("Product may be deleted (ID:\(id))")
                return
            }
            
            if successCallback != nil {
                successCallback!((result.object as? PostVM)!)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetPost") { result in
            if failureCallback != nil {
                var error = "Failed to get product info..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getPost(id)
    }
    
    static func getUser(id: Int, successCallback: ((UserVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetUser") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("User returned is empty")
                return
            }
            
            if successCallback != nil {
                successCallback!((result.object as? UserVM)!)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetUser") { result in
            if failureCallback != nil {
                var error = "Failed to get user..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getUser(id)
    }
    
    static func getMessages(id: Int, offset: Int64, successCallback: ((MessageResponseVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetMessages") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("User returned is empty")
                return
            }
            
            if successCallback != nil {
                successCallback!((result.object as? MessageResponseVM)!)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetMessages") { result in
            if failureCallback != nil {
                var error = "Failed to get messages..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getMessages(id, offset: offset)
    }

}