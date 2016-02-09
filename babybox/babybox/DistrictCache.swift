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
    private static var districts: [LocationVM]?  = [];
    
    init() {
        SwiftEventBus.onMainThread(self, name: "districtsSuccess") { result in
            // UI thread
            print(result.object)
            DistrictCache.districts = result.object as? [LocationVM]
            
        }
    }
    
    static func refresh() {
        ApiControlller.apiController.getDistricts()
    }
    
    static func getDistricts() -> [LocationVM] {
        if (districts == nil || districts!.count == 0) {
            refresh()
        }
        
        return DistrictCache.districts!;
    }
    
}