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

class CommentModel: BaseArgModel {
    
    var id: Int = 0
    var createdDate: Int = 0
    var ownerId: Int = 0
    var ownerName: String = ""
    var body: String = ""
    var isOwner: Bool = false
    var deviceType: String = ""
    
    override func mapping(map: ObjectMapper.Map) {
        print("mapping", terminator: "");
        id<-map["id"]
        createdDate<-map["createdDate"]
        ownerId<-map["ownerId"]
        ownerName<-map["ownerName"]
        body<-map["body"]
        isOwner<-map["isOwner"]
        deviceType<-map["deviceType"]
        
    }
}