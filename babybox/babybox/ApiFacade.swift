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
                failureCallback!(NSLocalizedString("not_logged_in", comment: ""))
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
                failureCallback!(NSLocalizedString("not_logged_in", comment: ""))
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
                    if error.isEmpty {
                        error = result.object as! String
                    } else {
                        error = NSLocalizedString("email_pwd_incorrect", comment: "")
                    }
                    
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
                failureCallback!(NSLocalizedString("signup_no_response", comment: ""))
                return
             }
            
            if successCallback != nil {
                successCallback!(result.object as! String)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureSignUp") { result in
            if failureCallback != nil {
                let error = NSLocalizedString("signup_email_exists", comment: "")
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
                failureCallback!(NSLocalizedString("signup_no_response", comment: ""))
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! String)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureSaveSignUpInfo") { result in
            if failureCallback != nil {
                let error = NSLocalizedString("signup_user_exists", comment: "")
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
    
    static func newComment(postId: Int, commentText: String, successCallback: ((ResponseVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessNewComment") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("New comment returned is empty")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! ResponseVM)
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
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("Comments returned is empty")
                return
            }

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
    
    static func getProductConversations(postId: Int, successCallback: (([ConversationVM]) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetProductConversations") { result in
            if successCallback != nil {
                successCallback!(result.object as! [ConversationVM])
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetProductConversations") { result in
            if failureCallback != nil {
                var error = "Failed to get conversations..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getPostConversations(postId)
    }
    
    static func getConversations(offset: Int64, successCallback: (([ConversationVM]) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetConversations") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("Conversations returned is empty")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! [ConversationVM])
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetConversations") { result in
            if failureCallback != nil {
                var error = "Failed to get conversations (Offset:\(String(offset)))"
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getConversations(offset)
    }

    static func getConversation(id: Int, successCallback: ((ConversationVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetConversation") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("Conversation returned is empty")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! ConversationVM)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetConversation") { result in
            if failureCallback != nil {
                var error = "Failed to get conversation (ID:\(String(id)))"
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getConversation(id)
    }

    static func openConversation(postId: Int, successCallback: ((ConversationVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessOpenConversation") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("Conversation returned is empty")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! ConversationVM)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureOpenConversation") { result in
            if failureCallback != nil {
                var error = "Failed to open conversation (Post:\(String(postId)))"
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.openConversation(postId)
    }

    static func deleteConversation(id: Int, successCallback: ((String) -> Void)?, failureCallback: ((error: String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessDeleteConversation") { result in
            let response = result.object as! String
            if successCallback != nil {
                successCallback!(response)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureDeleteConversation") { result in
            if failureCallback != nil {
                var error = "Failed to delete conversation (ID:\(String(id)))"
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error: error)
            }
        }
        
        ApiController.instance.deleteConversation(id)
    }
    
    static func getUserFollowingFollowers(userId: Int, offset: Int64, optionType: String, successCallback: (([UserVMLite]) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetFollowingFollowers") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("No following / followers items")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! [UserVMLite])
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetFollowingFollowers") { result in
            if failureCallback != nil {
                var error = "Failed to get following / followers items..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        switch optionType {
            case "followingCalls":
                ApiController.instance.getUserFollowings(userId, offset: offset)
            case "followersCall":
                ApiController.instance.getUserFollowers(userId, offset: offset)
            default: break
        }
    }
    
    static func getUserActivities(offset: Int64, successCallback: (([ActivityVM]) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessGetActivities") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("No activities items")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! [ActivityVM])
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureGetActivities") { result in
            if failureCallback != nil {
                var error = "Failed to get  items..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getUserActivities(offset)
    }
    
    static func newConversationOrder(conversationId: Int, offeredPrice: Double, successCallback: ((ConversationOrderVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessNewConversationOrder") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("No activities items")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! ConversationOrderVM)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureNewConversationOrder") { result in
            if failureCallback != nil {
                var error = "Failed to create conversation..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.newConversationOrder(conversationId, offeredPrice: offeredPrice)
    }
    
    static func cancelConversationOrder(conversationId: Int, successCallback: ((ConversationOrderVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessCancelConversationOrder") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("No activities items")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! ConversationOrderVM)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureCancelConversationOrder") { result in
            if failureCallback != nil {
                var error = "Failed to create conversation..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.cancelConversationOrder(conversationId)
    }
    
    
    static func acceptConversationOrder(conversationId: Int, successCallback: ((ConversationOrderVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessAcceptConversationOrder") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("No activities items")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! ConversationOrderVM)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureAcceptConversationOrder") { result in
            if failureCallback != nil {
                var error = "Failed to create conversation..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        ApiController.instance.acceptConversationOrder(conversationId)
    }
    
    static func declineConversationOrder(conversationId: Int, successCallback: ((ConversationOrderVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.unregister(self)
        
        SwiftEventBus.onMainThread(self, name: "onSuccessDeclineConversationOrder") { result in
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("No activities items")
                return
            }
            
            if successCallback != nil {
                successCallback!(result.object as! ConversationOrderVM)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailureDeclineConversationOrder") { result in
            if failureCallback != nil {
                var error = "Failed to create conversation..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.declineConversationOrder(conversationId)
    }
    
}