//
//  CommentVM.swift
//  Baby Box
//
//  Created by Mac on 18/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import ObjectMapper

class CommentVM: RequestVM {
    var postId: Int = 0
    var body: String = ""
    
    override func mapping(map: ObjectMapper.Map) {
        postId<-map["postId"]
        body<-map["body"]
    }
}