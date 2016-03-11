//
//  SellerVM.swift
//  babybox
//
//  Created by Mac on 01/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import ObjectMapper

class SellerVM: UserVMLite {
    
    var aboutMe: String = ""
    var posts: [PostVMLite] = []
    var numMoreProducts = 0
    
    override func mapping(map: ObjectMapper.Map) {
        super.mapping(map)
        
        aboutMe<-map["aboutMe"]
        posts<-map["posts"]
        numMoreProducts<-map["numMoreProducts"]
    }
}