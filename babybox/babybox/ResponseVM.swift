//
//  ResponseVM.swift
//  BabyBox
//
//  Created by admin on 29/04/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import ObjectMapper

class ResponseVM: BaseArgVM {
    
    var objType: String?
    var objId: Int?
    var userId: Int?
    var success: Bool?
    
    override func mapping(map: ObjectMapper.Map) {
        super.mapping(map)
        
        objType<-map["objType"]
        objId<-map["objId"]
        userId<-map["userId"]
        success<-map["success"]
    }
}