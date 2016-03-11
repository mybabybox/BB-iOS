//
//  ApiCallEvent.swift
//  Baby Box
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation

class ApiCallEvent { //this is generalized model to make api call...
    var method=""
    var arg = BaseArgVM()
    var resultClass=""
    var apiUrl=""
    var successEventbusName=""
    var failedEventbusName=""
    var body=""
}