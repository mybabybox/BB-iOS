//
//  ActivityVM.swift
//  babybox
//
//  Created by Mac on 17/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import ObjectMapper

class ActivityVM: BaseArgVM {

    var id: Int = 0
    var createdDate: Double = 0
    var activityType: String = ""
    var userIsOwner: Bool = false
    var actor: Int = 0
    var actorImage: Int = 0
    var actorName: String = ""
    var actorType: String = ""
    var target: Int = 0
    var targetImage: Double = 0
    var targetName: String = ""
    var targetType: String = ""
    var viewed: Bool = false
    
    override func mapping(map: ObjectMapper.Map) {
        super.mapping(map)
    
        id<-map["id"]
        createdDate<-map["createdDate"]
        activityType<-map["activityType"]
        userIsOwner<-map["userIsOwner"]
        actor<-map["actor"]
        actorImage<-map["actorImage"]
        actorType<-map["actorType"]
        actorName<-map["actorName"]
        target<-map["target"]
        targetImage<-map["targetImage"]
        targetName<-map["targetName"]
        targetType<-map["targetType"]
        viewed<-map["viewed"]

    }
}