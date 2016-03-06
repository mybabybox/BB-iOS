//
//  ConversationOrderVM.swift
//  babybox
//
//  Created by Mac on 05/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import ObjectMapper

class ConversationOrderVM: BaseArgVM {
    
    var id = 0
    var createdDate: Double? = nil
    var updatedDate: Double? = nil
    var conversationId: Int = 0
    var userId = 0
    var userName = ""
    var offeredPrice: Double? = nil
    var cancelled = false
    var cancelDate: Double? = nil
    var accepted = false
    var acceptDate: Double? = nil
    var declined = false
    var declineDate: Double? = nil
    var active = false
    var closed = false
    
    override func mapping(map: ObjectMapper.Map) {
        
        id<-map["id"]
        createdDate<-map["createdDate"]
        updatedDate<-map["updatedDate"]
        conversationId<-map["conversationId"]
        userId<-map["userId"]
        userName<-map["userName"]
        offeredPrice<-map["offeredPrice"]
        cancelled<-map["cancelled"]
        cancelDate<-map["cancelDate"]
        accepted<-map["accepted"]
        acceptDate<-map["acceptDate"]
        declined<-map["declined"]
        declineDate<-map["declineDate"]
        active<-map["active"]
        closed<-map["closed"]
        
    }
}