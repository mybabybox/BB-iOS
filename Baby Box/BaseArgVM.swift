//
//  BaseArgVM.swift
//  Baby Box
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseArgVM: Mappable {
    
    required init?(_ map: Map){
    };
    required init(){
    }
    
    class func newInstance( map: ObjectMapper.Map) ->Mappable?{
        
        let result=BaseArgVM()
        result.mapping(map)
        return  result
        
    }
    
    func mapping(map: ObjectMapper.Map) {
    
    }
}