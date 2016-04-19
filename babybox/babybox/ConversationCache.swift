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
    
    static func sort(conversations: [ConversationVM]) -> [ConversationVM] {
        return conversations.sort({ $0.lastMessageDate > $1.lastMessageDate })
    }
    
    static func load(offset: Int64, successCallback: (([ConversationVM]) -> Void)?, failureCallback: ((String) -> Void)?) {
        ApiFacade.getConversations(
            offset,
            successCallback: { conversations in
                if offset == 0 {
                    self.conversations = []
                }

                // add all and sort
                self.conversations.appendContentsOf(conversations)
                self.conversations = sort(self.conversations)

                if successCallback != nil {
                    successCallback!(conversations)
                }
            },
            failureCallback: failureCallback)
    }
    
    static func open(postId: Int, successCallback: ((ConversationVM) -> Void)?, failureCallback: ((error: String) -> Void)?) {
        ApiFacade.openConversation(
            postId,
            successCallback: { conversation in
                // add to first if not exists
                self.openedConversation = conversation
                if !self.conversations.contains({ $0.id == conversation.id }) {
                    self.conversations.insert(conversation, atIndex: 0)
                }
                
                if successCallback != nil {
                    successCallback!(conversation)
                }
            },
            failureCallback: failureCallback)
    }
    
    static func delete(id: Int, successCallback: ((String) -> Void)?, failureCallback: ((error: String) -> Void)?) {
        ApiFacade.deleteConversation(
            id,
            successCallback: { response in
                // remove from conversations
                self.conversations = self.conversations.filter({ $0.id != id })
                
                if successCallback != nil {
                    successCallback!(response)
                }
            },
            failureCallback: failureCallback)
    }
    
    static func update(id: Int, successCallback: ((ConversationVM) -> Void)?, failureCallback: ((error: String) -> Void)?) {
        ApiFacade.getConversation(
            id,
            successCallback: { conversation in
                // remove and add to first
                self.conversations = self.conversations.filter({ $0.id != conversation.id })
                self.conversations.insert(conversation, atIndex: 0)
                
                if successCallback != nil {
                    successCallback!(conversation)
                }
            },
            failureCallback: failureCallback)
    }

    static func clear() {
        conversations = []
        openedConversation = nil
    }
    
    static func updateConversationOrder(conversationId: Int, order: ConversationOrderVM) -> ConversationVM {
        let conversation = getConversation(conversationId);
        if (conversation != nil) {
            conversation!.order = order
        }
        return conversation!
    }
    
    static func getConversation(id: Int) -> ConversationVM? {
        let items = ConversationCache.conversations
        for i in 0...ConversationCache.conversations.count - 1 {
            if items[i].id == id {
                return items[i]
            }
        }
    
        return nil
    }
    
}