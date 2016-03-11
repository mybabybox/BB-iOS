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
    
    private static let DISTRICTS = "districts"
    private static var districts: [LocationVM]?  = []
    
    init() {
        SwiftEventBus.onMainThread(self, name: "getDistrictSuccess") { result in
            // UI thread
            DistrictCache.districts = result.object as? [LocationVM]
        }
    }
    
    static func refresh() {
        ApiController.instance.getAllDistricts()
    }
    
    static func getDistricts() -> [LocationVM] {
        if (districts == nil || districts!.count == 0) {
            //refresh()
        }
        
        return DistrictCache.districts!
    }
    
    static func setDistrict(locations: [LocationVM]) {
        DistrictCache.districts = locations
    }
    
}