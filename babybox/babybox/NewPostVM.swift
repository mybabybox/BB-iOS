//
//  SellVM.swift
//  BabyBox
//
//  Created by Anshul Gupta on 1/8/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import ObjectMapper


class NewPostVM: BaseArgVM {
    
    var id: Int = 0
    var createdDate: Int = 0
    var senderId: Int = 0
    var senderName: String = ""
    var body: String = ""
    var hasImage: Bool = false
    var image: Int = 0
    var system: Bool = false
    
    override func mapping(map: ObjectMapper.Map) {
        id<-map["id"]
        createdDate<-map["createdDate"];
        senderId<-map["senderId"];
        senderName<-map["senderName"];
        body<-map["body"];
        hasImage<-map["hasImage"];
        image<-map["image"];
        system<-map["system"];
        
    }

}
