//
//  MessageVM
//  babybox
//
//  Created by Mac on 18/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import ObjectMapper
class MessageVM: BaseArgVM {
    
    var counter: Int = 0
    var messages: [MessageDetailVM] = []
    
    override func mapping(map: ObjectMapper.Map) {
        counter<-map["counter"]
        messages<-map["messages"]
        
    }
}
