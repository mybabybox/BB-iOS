//
//  NotificationCounter.swift
//  babybox
//
//  Created by Mac on 27/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftEventBus

class NotificationCounter {
    
    static var TIMER_INTERVAL: Double = 10 * 60 * 1000
    
    static var counter: NotificationCounterVM? = nil
    
    static var mInstance: NotificationCounter = NotificationCounter()
    
    init() {
    }
    
    /*func refresh() {
        NSLog("NotificationCounter", "refresh")
        ApiController.instance.getNotificationCounter()
    }*/
    
    func refresh(successCallback: ((NotificationCounterVM) -> Void)?, failureCallback: ((String) -> Void)?) {
        
        SwiftEventBus.onMainThread(self, name: "loadNotificationSuccess") { result in
            SwiftEventBus.unregister(self)
            
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("failed to get notifications!")
                return
            }
            
            NotificationCounter.counter = result.object as? NotificationCounterVM
            if successCallback != nil {
                successCallback!(NotificationCounter.counter!)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "loadNotificationFailure") { result in
            SwiftEventBus.unregister(self)
            
            if failureCallback != nil {
                var error = "failed to get notifications"
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getNotificationCounter()
    }
    
    func clear() {
        
    }
    
    static func resetActivitiesCount() {
        if (counter != nil) {
            counter!.activitiesCount = 0
        }
        
        //if (HomeFeedViewController.instance != nil) {
        //    HomeFeedViewController.instance!.refreshNotifications()
        //}
    }
    
    static func sameCounter(other: NotificationCounterVM) {
        if (counter != nil) {
            counter!.activitiesCount = 0
        }
        //refresh the main activity
        //if (HomeFeedViewController.instance != nil) {
        //    HomeFeedViewController.instance!.refreshNotifications()
        //}
    }
    

}