//
//  CountryCache.swift
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
    
    static func refresh(successCallback: (([CountryVM]) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "getCountriesSuccess") { result in
            SwiftEventBus.unregister(self)
            
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("Countries returned is empty")
                return
            }
            
            self.countries = result.object as! [CountryVM]
            if successCallback != nil {
                successCallback!(self.countries)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "getCountriesFailed") { result in
            SwiftEventBus.unregister(self)
            
            if failureCallback != nil {
                var error = "Failed to get countries..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getCountries()
    }
}