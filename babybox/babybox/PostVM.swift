//
//  PostVM.swift
//  Baby Box
//
//  Created by Mac on 17/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class PostVM: PostVMLite {
    
    var createdDate: Double = 0
    var updatedDate: Double = 0
    var ownerNumProducts: Int = 0
    var ownerNumFollowers: Int = 0
    var body: String = ""
    var categoryId: Int = 0
    var categoryName: String = ""
    var categoryIcon: String = ""
    var categoryType: String = ""
    var latestComments: [CommentVM] = []
    var isOwner: Bool = false
    var isFollowingOwner: Bool = false
    var deviceType: String = ""
    var ownerLastLogin: Double = 0
    
    override func mapping(map: ObjectMapper.Map) {
        super.mapping(map)
        ownerId<-map["ownerId"]
        createdDate<-map["createdDate"]
        updatedDate<-map["updatedDate"]
        ownerNumProducts<-map["ownerNumProducts"]
        ownerNumFollowers<-map["ownerNumFollowers"]
        body<-map["body"]
        categoryId<-map["categoryId"]
        categoryName<-map["categoryName"]
        categoryIcon<-map["categoryIcon"]
        categoryType<-map["categoryType"]
        latestComments<-map["latestComments"]
        isOwner<-map["isOwner"]
        isFollowingOwner<-map["isFollowingOwner"]
        deviceType<-map["deviceType"]
        ownerLastLogin<-map["ownerLastLogin"]
    }
}