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
    var id: Double = 0
    var userId: Double = 0
    var activitiesCount: Double = 0
    var conversationsCount: Double = 0
    
    override func mapping(map: ObjectMapper.Map) {
        super.mapping(map)
        
        id<-map["id"]
        userId<-map["userId"]
        activitiesCount<-map["activitiesCount"]
        conversationsCount<-map["conversationsCount"]
    }
    
}