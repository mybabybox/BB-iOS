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
    private static var districts: [LocationVM]?  = nil;
    
    init() {
        SwiftEventBus.onMainThread(self, name: "districtsSuccess") { result in
            // UI thread
            print(result.object)
            DistrictCache.districts = result.object as? [LocationVM]
            let sharedPref: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            sharedPref.setObject(DistrictCache.districts, forKey: DistrictCache.DISTRICTS)
        }
    }
    
    public static func refresh() {
        ApiControlller.apiController.getDistricts()
    }
    
    public static func getDistricts() -> [LocationVM] {
        if (districts == nil || districts!.count == 0) {
            let sharedPref: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            districts = sharedPref.arrayForKey(DISTRICTS) as? [LocationVM]
        }
        
        return districts!;
    }
    
    public static func clear() {
        let sharedPref: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        sharedPref.setObject(nil, forKey: DISTRICTS)
    }
}