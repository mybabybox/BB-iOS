//
//  MessageVM
//  babybox
//
//  Created by Mac on 18/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import ObjectMapper
class MessageVM: BaseArgVM {
    
    /*var id: Double = 0
    var createdDate: Double = 0
    var senderId: Double = 0
    var senderName = ""
    var receiverId:Double = 0
    var preceiverName = ""
    var body = ""
    var system = false
    var hasImage = false
    var image: Int = 0*/
    
    var counter: Int = 0
    var messages: [MessageDetailVM] = []
    
    override func mapping(map: ObjectMapper.Map) {
        counter<-map["counter"]
        messages<-map["messages"]
        
        /*id<-map["id"]
        createdDate<-map["createdDate"];
        senderId<-map["senderId"];
        senderName<-map["senderName"];
        body<-map["body"];
        hasImage<-map["hasImage"];
        image<-map["image"];
        system<-map["system"];*/
        
    }
}
