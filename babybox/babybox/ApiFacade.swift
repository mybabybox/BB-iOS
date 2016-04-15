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

    static let HOME_SLIDER_ITEM_TYPE = "HOME_SLIDER"
    
    static func loginByFacebook(authToken: String, successCallback: ((String) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessLoginByFacebook") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("User is not logged in")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! String)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureLoginByFacebook") { result in
            if failureCallback != nil {
                var error = "Failed to login by facebook..."
                if result.object is NSString {
                    error = result.object as! String
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.loginByFacebook(authToken)
    }
    
    static func loginByEmail(userName: String, password: String, successCallback: ((String) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessLoginByEmail") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("User is not logged in")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! String)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureLoginByEmail") { result in
            if failureCallback != nil {
                var error = "Failed to login by email..."
                if result.object is NSString {
                    error = result.object as! String
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.loginByEmail(userName, password: password)
    }
    
    static func signUp(email: String, fname: String, lname: String, password: String, repeatPassword: String,
                       successCallback: ((String) -> Void)?, failureCallback: ((String) -> Void)?) {
        
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessSignUp") { result in
             if ViewUtil.isEmptyResult(result) {
                failureCallback!("No response for sign up. Please try again later.")
                return
             }
            
            if successCallback != nil {
                successCallback!(result.object as! String)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureSignUp") { result in
            if failureCallback != nil {
                let error = "Email is already registered. Please try another email or sign up with Facebook."
                /*
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                */
                failureCallback!(error)
            }
        }
        
        ApiController.instance.signUp(email, fname: fname, lname: lname, password: password, repeatPassword: repeatPassword)
    }
    
    static func saveSignUpInfo(displayName: String, locationId: Int,
                               successCallback: ((String) -> Void)?, failureCallback: ((String) -> Void)?) {
        
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessSaveSignUpInfo") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("No response for sign up. Please try again later.")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! String)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureSaveSignUpInfo") { result in
            if failureCallback != nil {
                let error = "Username already exists. Please try another one."
                /*
                 if result.object is NSString {
                 error += "\n"+(result.object as! String)
                 }
                 */
                failureCallback!(error)
            }
        }
        
        ApiController.instance.saveSignUpInfo(displayName, locationId: locationId)
    }
    
    static func initNewUser(successCallback: ((UserVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetUser") { result in
            /*
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("User returned is empty")
                return
            }
            */
            
            if successCallback != nil {
                successCallback!(result.object as! UserVM)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetUser") { result in
            if failureCallback != nil {
                var error = "Failed to initialize new user..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.initNewUser()
    }

    static func getUser(id: Int, successCallback: ((UserVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetUser") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("User returned is empty")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! UserVM)
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

    static func getUserByDisplayName(displayName: String, successCallback: ((UserVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetUserByDisplayName") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("User returned is empty")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! UserVM)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetUserByDisplayName") { result in
            if failureCallback != nil {
                var error = "Failed to get user by name..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getUserByDisplayName(displayName)
    }

    static func getPost(id: Int, successCallback: ((PostVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetPost") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("Product may be deleted (ID:\(id))")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! PostVM)
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
    
    static func getMessages(id: Int, offset: Int64, successCallback: ((MessageResponseVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetMessages") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("User returned is empty")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! MessageResponseVM)
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
    
    static func newMessage(conversationId: Int, message: String, image: UIImage?, system: Bool, successCallback: ((String) -> Void)?, failureCallback: ((String) -> Void)?) {
    
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessNewMessage") { result in
            if successCallback != nil {
                if result.object is NSString {
                    successCallback!(result.object as! String)
                } else {
                    successCallback!("")
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureNewMessage") { result in
            if failureCallback != nil {
                var error = "Failed to send message..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.newMessage(conversationId, message: message, image: image, system: system)
    }
    
    static func newComment(postId: Int, commentText: String, successCallback: ((String) -> Void)?, failureCallback: ((String) -> Void)?) {
        
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessNewComment") { result in
            if successCallback != nil {
                if result.object is NSString {
                    successCallback!(result.object as! String)
                } else {
                    successCallback!("")
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureNewComment") { result in
            if failureCallback != nil {
                var error = "Failed to post comment..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.newComment(postId, comment: commentText)
    }
    
    static func getComments(postId: Int, offset: Int64, successCallback: (([CommentVM]) -> Void)?, failureCallback: ((String) -> Void)?) {
        
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetComments") { result in
            if successCallback != nil {
                successCallback!(result.object as! [CommentVM])
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetComments") { result in
            if failureCallback != nil {
                var error = "Failed to get comments..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getComments(postId, offset: offset)
    }
    
    static func deleteComment(commentId: Int, successCallback: ((String) -> Void)?, failureCallback: ((String) -> Void)?) {
        
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessDeleteComment") { result in
            if successCallback != nil {
                successCallback!(result.object as! String)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureDeleteComment") { result in
            if failureCallback != nil {
                var error = "Failed to get comments..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.deleteComment(commentId)
    }

    static func getHomeSliderFeaturedItems(successCallback: (([FeaturedItemVM]) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetFeaturedItems") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("No Featured items")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! [FeaturedItemVM])
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetFeaturedItems") { result in
            if failureCallback != nil {
                var error = "Failed to get featured items..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getFeaturedItems(HOME_SLIDER_ITEM_TYPE)
    }
    
    //static func registerAppForNotification(successCallback: ((String) -> Void)?, failureCallback: ((String) -> Void)?) {
    static func registerAppForNotification() {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessRegisterAppNotification") { result in
            //AppDelegate.getInstance().apnsDeviceToken = result.object as? String
            ApiController.instance.saveApnsNotifToken()
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureRegisterAppNotification") { result in
            var error = "Failed to register for notification..."
            if result.object is NSString {
                error += "\n"+(result.object as! String)
            }
        }
        
        AppDelegate.getInstance().registerForPushNotifications()
        
    }

}