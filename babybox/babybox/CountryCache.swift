//
//  DistrictCache.swift
//  babybox
//
//  Created by Mac on 04/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftEventBus

class CountryCache {
    
    static var countries: [CountryVM]  = []
    
    init() {
    }
    
    static func refresh() {
        self.refresh(nil, failureCallback: nil)
    }
    
    static func refresh(successCallback: (([CountryVM]) -> Void)?, failureCallback: (() -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "getCountriesSuccess") { result in
            self.countries = result.object as! [CountryVM]
            if successCallback != nil {
                successCallback!(self.countries)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "getCountriesFailed") { result in
            if failureCallback != nil {
                failureCallback!()
            }
        }
        
        ApiController.instance.getCountries()
    }
}