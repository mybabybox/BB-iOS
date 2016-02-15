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
    
    var userId: Int = 0
    var userInfo: UserInfoVM? = nil
    
    var userPostedFeedLoader: FeedLoader? = nil
    var userLikedFeedLoader: FeedLoader? = nil
    
    var feedFilter: FeedFilter.FeedType? = FeedFilter.FeedType.USER_POSTED
    
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

    func clearFeedItems() {
        userPostedFeedLoader?.clearFeedItems()
        userLikedFeedLoader?.clearFeedItems()
    }
    
    func unregisterEvents() {
        SwiftEventBus.unregister(self)
        eventsRegistered = false
    }
   
    func registerEvents() {
        if (!eventsRegistered) {
            userPostedFeedLoader = FeedLoader(feedType: FeedFilter.FeedType.USER_POSTED, reloadDataToView: reloadDataToView)
            userLikedFeedLoader = FeedLoader(feedType: FeedFilter.FeedType.USER_LIKED, reloadDataToView: reloadDataToView)
            
            SwiftEventBus.onMainThread(self, name: "profileImgUploadSuccess") { result in
                self.view.makeToast(message: "Profile image uploaded successfully!")
            }
            
            SwiftEventBus.onMainThread(self, name: "profileImgUploadFailed") { result in
                self.view.makeToast(message: "Error uploading profile image!")
            }
            
            registerMoreEvents()
            
            eventsRegistered = true
        }
    }
    
    func loadMoreFeedItems() {
        if let userInfo = self.userInfo {
            switch feedFilter! {
            case FeedFilter.FeedType.USER_POSTED:
                userPostedFeedLoader?.loadMoreFeedItems(userInfo.id)
            case FeedFilter.FeedType.USER_LIKED:
                userLikedFeedLoader?.loadMoreFeedItems(userInfo.id)
            default: break
            }
        }
    }
    
    func reloadFeedItems() {
        if let userInfo = self.userInfo {
            switch feedFilter! {
            case FeedFilter.FeedType.USER_POSTED:
                userPostedFeedLoader?.reloadFeedItems(userInfo.id)
            case FeedFilter.FeedType.USER_LIKED:
                userLikedFeedLoader?.reloadFeedItems(userInfo.id)
            default: break
            }
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
    
    func getTypeProductInstance() -> [PostModel] {
        if (feedFilter == FeedFilter.FeedType.USER_POSTED) {
            if let feedLoader = userPostedFeedLoader {
                return feedLoader.feedItems
            }
        } else {
            if let feedLoader = userLikedFeedLoader {
                return feedLoader.feedItems
            }
        }
        return []
    }
}
