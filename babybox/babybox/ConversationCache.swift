//
//  ConversationCache.swift
//  babybox
//
//  Created by Mac on 05/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftEventBus

class ConversationCache {
    
    static var conversations: [ConversationVM] = []
    
    static var openedConversation: ConversationVM? = nil
    
    init() {
    }
    
    static func sort(var conversations: [ConversationVM]) {
        conversations.sortInPlace({ $0.lastMessageDate > $1.lastMessageDate })
    }
    
    static func load(offset: Int64, successCallback: (([ConversationVM]) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "getConversationsSuccess") { result in
            SwiftEventBus.unregister(self)
            
            if offset == 0 {
                self.conversations = []
            }
            
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("Conversations returned is empty")
                return
            }
            
            // add all and sort
            let conversations = result.object as! [ConversationVM]
            self.conversations.appendContentsOf(conversations)
            sort(self.conversations)
            
            if successCallback != nil {
                successCallback!(conversations)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "getConversationsFailed") { result in
            SwiftEventBus.unregister(self)
            
            if failureCallback != nil {
                var error = "Failed to get conversations..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getConversations(offset)
    }
    
    static func open(postId: Int, successCallback: ((ConversationVM) -> Void)?, failureCallback: ((error: String) -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "openConversationSuccess") { result in
            SwiftEventBus.unregister(self)
            
            if ViewUtil.isEmptyResult(result) {
                failureCallback!(error: "Conversation returned is empty")
                return
            }
            
            // add to first if not exists
            let conversation = result.object as! ConversationVM
            self.openedConversation = conversation
            if !self.conversations.contains({ $0.id == conversation.id }) {
                self.conversations.insert(conversation, atIndex: 0)
            }
            
            if successCallback != nil {
                successCallback!(conversation)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "openConversationFailed") { result in
            SwiftEventBus.unregister(self)
            
            if failureCallback != nil {
                var error = "Failed to open conversation with postId=" + String(postId)
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error: error)
            }
        }
        
        ApiController.instance.openConversation(postId)
    }
    
    static func delete(id: Int, successCallback: ((String) -> Void)?, failureCallback: ((error: String) -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "deleteConversationSuccess") { result in
            SwiftEventBus.unregister(self)
            
            //Apis does not return any api hence this condition is getting success and calling failure method 
            //in target instead of calling success. 
            //Need to discuss with Keith...
            /*if ViewUtil.isEmptyResult(result) {
                failureCallback!(error: "Response returned is empty")
                return
            }*/
            
            // remove from conversations
            self.conversations = self.conversations.filter({ $0.id != id })

            let response = result.object as! String
            if successCallback != nil {
                successCallback!(response)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "deleteConversationFailed") { result in
            SwiftEventBus.unregister(self)
            
            if failureCallback != nil {
                var error = "Failed to delete conversation with id=" + String(id)
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error: error)
            }
        }
        
        ApiController.instance.deleteConversation(id)
    }
    
    static func update(id: Int, successCallback: ((ConversationVM) -> Void)?, failureCallback: ((error: String) -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "getConversationSuccess") { result in
            SwiftEventBus.unregister(self)
            
            if ViewUtil.isEmptyResult(result) {
                failureCallback!(error: "Conversation returned is empty")
                return
            }
            
            // remove and add to first
            let conversation = result.object as! ConversationVM
            self.conversations = self.conversations.filter({ $0.id != conversation.id })
            self.conversations.insert(conversation, atIndex: 0)
            
            if successCallback != nil {
                successCallback!(conversation)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "getConversationFailed") { result in
            SwiftEventBus.unregister(self)
            
            if failureCallback != nil {
                var error = "Failed to get conversation with id=" + String(id)
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error: error)
            }
        }
        
        ApiController.instance.getConversation(id)
    }

    static func clear() {
        conversations = []
        openedConversation = nil
    }
}