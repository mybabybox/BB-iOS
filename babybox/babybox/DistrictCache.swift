//
//  DistrictCache.swift
//  babybox
//
//  Created by Mac on 04/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftEventBus

class DistrictCache {
    
    static var districts: [LocationVM]  = []
    
    init() {
    }
    
    static func refresh() {
        self.refresh(nil, failureCallback: nil)
    }
    
    static func refresh(successCallback: (([LocationVM]) -> Void)?, failureCallback: (() -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "getDistrictSuccess") { result in
            self.districts = result.object as! [LocationVM]
            if successCallback != nil {
                successCallback!(self.districts)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "getDistrictFailed") { result in
            if failureCallback != nil {
                failureCallback!()
            }
        }
        
        ApiController.instance.getDistricts()
    }
}