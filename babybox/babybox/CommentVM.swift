//
//  CommentVM.swift
//  Baby Box
//
//  Created by Mac on 17/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class CommentVM: BaseArgVM {
    
    var id: Int = 0
    var createdDate: Double = 0
    var ownerId: Int = 0
    var ownerName: String = ""
    var body: String = ""
    var isOwner: Bool = false
    var deviceType: String = ""
    var isNew: Bool = false
    
    override func mapping(map: ObjectMapper.Map) {
        id<-map["id"]
        createdDate<-map["createdDate"]
        ownerId<-map["ownerId"]
        ownerName<-map["ownerName"]
        body<-map["body"]
        isOwner<-map["isOwner"]
        deviceType<-map["deviceType"]
        
    }
}