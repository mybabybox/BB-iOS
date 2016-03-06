//
//  ConversationCache.swift
//  babybox
//
//  Created by Mac on 05/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation

class ConversationCache {
    static var conversations: [ConversationVM] = []
    static var openedConversation: ConversationVM? = nil
    
    static func refresh() {
        ApiController.instance.getConversations()
    }
    
    static func setConversions(lConversations: [ConversationVM]) {
        self.conversations = lConversations
    }
    
    /*static func open(lConversations: ConversationVM) {
        self.conversations = lConversations
    }*/
    
}