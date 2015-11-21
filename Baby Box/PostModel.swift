//
//  PostModel.swift
//  Baby Box
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//


import Foundation
import UIKit
import ObjectMapper

class PostModel: BaseArgModel {
    var id: Double = 0
    var ownerId: Double = 0
    var ownerName: String = ""
    var title: String = ""
    var price: Double = 0
    var sold: Bool = false
    var postType: String = ""
    var conditionType: String = ""
    var images: [Int] = [];
    var hasImage: Bool = false
    var numLikes: Int = 0
    var numChats: Int = 0
    var numBuys: Int = 0
    var numComments: Int = 0
    var numViews: Int = 0
    var isLiked: Bool = false
    var offSet: Double = 0
    var baseScore: Double = 0
    var timeScore: Double = 0
    
    override func mapping(map: ObjectMapper.Map) {
        //
        id<-map["id"]
        ownerId<-map["ownerId"]
        ownerName<-map["ownerName"]
        title<-map["title"]
        price<-map["price"]
        sold<-map["sold"]
        postType<-map["postType"]
        conditionType<-map["conditionType"]
        images<-map["images"];
        hasImage<-map["hasImage"]
        numLikes<-map["numLikes"]
        numChats<-map["numChats"]
        numBuys<-map["numBuys"]
        numComments<-map["numComments"]
        numViews<-map[""]
        isLiked<-map[""]
        offSet<-map[""]
        baseScore<-map[""]
        timeScore<-map[""]
    }
}