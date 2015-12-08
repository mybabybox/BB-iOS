//
//  ResponseVM.swift
//  Baby Box
//
//  Created by Mac on 06/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import ObjectMapper

class ResponseVM: BaseArgVM {
    var response = ""
    
    var method="";
    var arg=BaseArgVM();
    var resultClass = "";
   // var result=ResultDto();
    var successEventbusName="";
    var failedEventbusName="";
    
    override func mapping(map: ObjectMapper.Map) {
    }
}