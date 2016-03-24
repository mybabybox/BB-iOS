//
//  NotificationCounterVM.swift
//  babybox
//
//  Created by Mac on 26/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import ObjectMapper

class NotificationCounterVM: BaseArgVM {
    var id: Int = 0
    var userId: Int = 0
    var activitiesCount: Int = 0
    var conversationsCount: Int = 0
    
    override func mapping(map: ObjectMapper.Map) {
        super.mapping(map)
        
        id<-map["id"]
        userId<-map["userId"]
        activitiesCount<-map["activitiesCount"]
        conversationsCount<-map["conversationsCount"]
    }
    
}