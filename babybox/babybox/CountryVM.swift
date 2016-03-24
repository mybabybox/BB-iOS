//
//  CountryVM
//  Baby Box
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import ObjectMapper

class CountryVM: BaseArgVM {
    var id: Int = 0
    var name: String = ""
    var code: String = ""
    var icon: String = ""
    var seq: Int = 0
    
    override func mapping(map: ObjectMapper.Map) {
        id<-map["id"]
        name<-map["name"]
        code<-map["code"]
        icon<-map["icon"]
        seq<-map["seq"]
    }
}