//
//  ConversationVM.swift
//  babybox
//
//  Created by Mac on 17/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import ObjectMapper

class ConversationVM: BaseArgVM {
    var id: Int = 0
    var postId: Int = 0
    var postImage: Int = 0
    var postTitle: String = ""
    var postPrice: Int = 0
    var postOwner: Bool?
    var postSold: Bool?
    var userId: Int = 0
    var userName: String = ""
    var lastMessageDate: Double = 0
    var lastMessage: String = ""
    var lastMessageHasImage: Bool?
    var unread: Int = 0
    var order: ConversationOrderVM? = nil
    
    override func mapping(map: ObjectMapper.Map) {
        id<-map["id"]
        postId<-map["postId"]
        postImage<-map["postImage"]
        postTitle<-map["postTitle"]
        postPrice<-map["postPrice"]
        postOwner<-map["postOwner"]
        postSold<-map["postSold"]
        userId<-map["userId"]
        userName<-map["userName"]
        lastMessageDate<-map["lastMessageDate"]
        lastMessage<-map["lastMessage"]
        lastMessageHasImage<-map["lastMessageHasImage"]
        unread<-map["unread"]
        order<-map["order"]
    }
}