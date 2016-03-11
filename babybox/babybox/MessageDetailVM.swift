//
//  MessageDetailVM.swift
//  babybox
//
//  Created by Mac on 18/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import ObjectMapper

class MessageDetailVM: BaseArgVM {
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
        createdDate<-map["createdDate"]
        senderId<-map["senderId"]
        senderName<-map["senderName"]
        body<-map["body"]
        hasImage<-map["hasImage"]
        image<-map["image"]
        system<-map["system"]
    }
}