//
//  UIApplication+NetworkIndicator.swift
//  Baby Box
//
//  Created by Mac on 07/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation

private var networkActivityCount = 0

extension UIApplication{
    
    func startNetworkActivity() {
        networkActivityCount++
        networkActivityIndicatorVisible = true
    }
    
    func stopNetworkActivity() {
        if networkActivityCount < 1 {
            return;
        }
        
        if --networkActivityCount == 0 {
            networkActivityIndicatorVisible = false
        }
    }
    
}