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
        super.mapping(map)
        id<-map["id"]
        emailNewPost<-map["emailNewPost"]
        emailNewConversation<-map["emailNewConversation"]
        emailNewComment<-map["emailNewComment"]
        emailNewPromotion<-map["emailNewPromotion"]
        pushNewConversion<-map["pushNewConversion"]
        pushNewComment<-map["pushNewComment"]
        pushNewFollow<-map["pushNewFollow"]
        pushNewFeedback<-map["pushNewFeedback"]
        pushNewPromotions<-map["pushNewPromotions"]
        systemAndroidVersion<-map["systemAndroidVersion"]
        systemIosVersion<-map["systemIosVersion"]
    }
}