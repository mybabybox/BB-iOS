//
//  CategoryModel.swift
//  Baby Box
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import ObjectMapper

class CategoryModel: BaseArgModel {
    
    var id: Double = 0;
    var icon: String = "";
    var name: String = "";
    var description: String = "";
    var categoryType: String = "";
    var seq: Int = 0;
    
    override func mapping(map: ObjectMapper.Map) {
        id<-map["id"];
        icon<-map["icon"]
        name<-map["name"]
        description<-map["description"]
        categoryType<-map["categoryType"];
        seq<-map["seq"];
    }
    
}