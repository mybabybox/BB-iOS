//
//  BaseArgModel.swift
//  Baby Box
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseArgModel: Mappable {
    
    required init?(_ map: Map){
    };
    required init(){
    }
    
    class func newInstance( map: ObjectMapper.Map) ->Mappable?{
        let result=BaseArgModel()
        result.mapping(map)
        return  result
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        
    }
}