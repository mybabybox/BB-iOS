//
//  LocationVM.swift
//  Baby Box
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import ObjectMapper

class LocationVM: BaseArgVM {
    var id: Int = 0
    var type: String = ""
    var name: String = ""
    var displayName: String = ""
    
    override func mapping(map: ObjectMapper.Map) {
        id<-map["id"]
        type<-map["type"]
        name<-map["name"]
        displayName<-map["displayName"]
    }
}