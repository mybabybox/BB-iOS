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
    
    static func refresh(successCallback: (([LocationVM]) -> Void)?, failureCallback: ((error: String) -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "getDistrictsSuccess") { result in
            SwiftEventBus.unregister(self)
            
            if ViewUtil.isEmptyResult(result) {
                failureCallback!(error: "Districts returned is empty")
                return
            }
            
            self.districts = result.object as! [LocationVM]
            if successCallback != nil {
                successCallback!(self.districts)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "getDistrictsFailed") { result in
            SwiftEventBus.unregister(self)
            
            if failureCallback != nil {
                var error = "Failed to get districts..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error: error)
            }
        }
        
        ApiController.instance.getDistricts()
    }
    
    static func getDistrictByName(name: String) -> LocationVM? {
        for index in 0...DistrictCache.districts.count {
            if (DistrictCache.districts[index].name == name) {
                return DistrictCache.districts[index]
            }
        }
        return nil
    }
}