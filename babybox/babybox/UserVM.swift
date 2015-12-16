//
//  User.swift
//  Baby Box
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import ObjectMapper

class UserVM: BaseArgVM {

    var displayName: String = ""
    var id: Int = 0
    var numFollowings: Int = 0
    var numProducts: Int = 0
    var numFollowers: Int = 0
    var numStories: Int = 0
    var numLikes: Int = 0
    var numCollections: Int = 0
    var isFollowing: Bool = false
    
    override func mapping(map: ObjectMapper.Map) {
        super.mapping(map)
        
        displayName<-map["displayName"]
        id<-map["id"]
        numFollowings<-map["numFollowings"]
        numProducts<-map["numProducts"]
        numFollowers<-map["numFollowers"]
        numStories<-map["numStories"]
        numLikes<-map["numLikes"]
        numCollections<-map["numCollections"]
        isFollowing<-map["isFollowing"]
    }
}
