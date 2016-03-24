//
//  SettingVM.swift
//  Baby Box
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import ObjectMapper

class SettingVM: BaseArgVM {

    var id: Int = 0
    var emailNewPost: Bool = false
    var emailNewConversation: Bool = false
    var emailNewComment: Bool = false
    var emailNewPromotion: Bool = false
    var pushNewConversion: Bool = false
    var pushNewComment: Bool = false
    var pushNewFollow: Bool = false
    var pushNewFeedback: Bool = false
    var pushNewPromotions: Bool = false
    var systemAndroidVersion: String =  ""
    var systemIosVersion: String = ""
    
    override func mapping(map: ObjectMapper.Map) {
        id<-map["id"]
        emailNewPost<-map["aboutMe"]
        emailNewConversation<-map["firstName"]
        emailNewComment<-map["firstName"]
        emailNewPromotion<-map["firstName"]
        pushNewConversion<-map["firstName"]
        pushNewComment<-map["firstName"]
        pushNewFollow<-map["firstName"]
        pushNewFeedback<-map["firstName"]
        pushNewPromotions<-map["firstName"]
        systemAndroidVersion<-map["firstName"]
        systemIosVersion<-map["firstName"]
    }
}