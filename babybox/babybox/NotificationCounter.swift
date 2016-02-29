//
//  NotificationCounter.swift
//  babybox
//
//  Created by Mac on 27/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation

class NotificationCounter {
    
    static var TIMER_INTERVAL: Double = 10 * 60 * 1000;
    
    static var counter: NotificationCounterVM? = nil
    
    static var mInstance: NotificationCounter = NotificationCounter()
    
    init() {
        NSTimer.scheduledTimerWithTimeInterval(NotificationCounter.TIMER_INTERVAL, target: InitialHomeSegmentedController.instance!, selector: "refresh", userInfo: nil, repeats: true)
    }
    
    func refresh() {
        NSLog("NotificationCounter", "refresh")
        ApiController.instance.getNotificationCounter()
    }
    
    func clear() {
        
    }
    
    static func resetActivitiesCount() {
        if (counter != nil) {
            counter!.activitiesCount = 0;
        }
        
        if (InitialHomeSegmentedController.instance != nil) {
            InitialHomeSegmentedController.instance!.refreshNotifications();
        }
    }
    
    static func sameCounter(other: NotificationCounterVM) {
        if (counter != nil) {
            counter!.activitiesCount = 0;
        }
        //refresh the main activity
        if (InitialHomeSegmentedController.instance != nil) {
            InitialHomeSegmentedController.instance!.refreshNotifications();
        }
    }
    

}