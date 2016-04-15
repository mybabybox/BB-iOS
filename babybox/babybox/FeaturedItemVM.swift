//
//  FeaturedItemVM.swift
//  BabyBox
//
//  Created by admin on 15/04/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import ObjectMapper

class FeaturedItemVM: BaseArgVM {
    
    var id: Int = 0
    var createdDate: Double = 0
    var itemType: String = ""
    var name: String = ""
    var description: String = ""
    var image: String = ""
    var seq: Int = 0
    var destinationType = ""
    var destinationObjId:Double = 0
    var destinationObjName = ""

    
    override func mapping(map: ObjectMapper.Map) {
        super.mapping(map)
        
        id<-map["id"]
        createdDate<-map["createdDate"]
        itemType<-map["itemType"]
        name<-map["name"]
        description<-map["description"]
        image<-map["image"]
        seq<-map["seq"]
        destinationType<-map["destinationType"]
        destinationObjId<-map["destinationObjId"]
        destinationObjName<-map["destinationObjName"]
    }
}