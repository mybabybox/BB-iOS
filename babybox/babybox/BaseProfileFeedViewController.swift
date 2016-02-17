//
//  BaseProfileFeedViewController.swift
//  babybox
//
//  Created by Mac on 30/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class BaseProfileFeedViewController: CustomNavigationController {
    
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    
    var userId: Int = 0
    var userInfo: UserInfoVM? = nil
    
    var feedLoader: FeedLoader? = nil
    
    var eventsRegistered = false
    
    // to be called by subclass
    func setUserInfo(userInfo: UserInfoVM?) {
        self.userInfo = userInfo
    }

    // to be overriden by subclass
    func registerMoreEvents() {
    }
    
    // must be overriden by subclass
    func reloadDataToView() {
        assert(false, "Must be overriden by subclass")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedLoader = FeedLoader(feedType: FeedFilter.FeedType.USER_POSTED, reloadDataToView: reloadDataToView)
        feedLoader!.setActivityIndicator(activityLoading)
    }
    
    func clearFeedItems() {
        feedLoader?.clearFeedItems()
    }
    
    func unregisterEvents() {
        feedLoader?.unregisterEvents()
        SwiftEventBus.unregister(self)
        eventsRegistered = false
    }
   
    func registerEvents() {
        if (!eventsRegistered) {
            feedLoader?.registerEvents()
            
            registerMoreEvents()
            
            eventsRegistered = true
        }
    }
    
    func loadMoreFeedItems() {
        if let userInfo = self.userInfo {
            feedLoader?.loadMoreFeedItems(userInfo.id)
        }
    }
    
    func reloadFeedItems() {
        if let userInfo = self.userInfo {
            feedLoader?.reloadFeedItems(userInfo.id)
        }
    }
    
    func isTipVisible() -> Bool {
        if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.MY_PROFILE_TIPS)) {
            SharedPreferencesUtil.getInstance().setScreenViewed(SharedPreferencesUtil.Screen.MY_PROFILE_TIPS)
            return true
        } else {
            return false
        }
    }
    
    func getFeedItems() -> [PostModel] {
        if feedLoader != nil {
            return feedLoader!.feedItems
        }
        return []
    }
}
