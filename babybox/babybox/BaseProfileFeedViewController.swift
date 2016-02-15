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
    
    var userPostedProducts: [PostModel] = []
    var userLikedProducts: [PostModel] = []

    var userPostedFeedLoading = false
    var userPostedFeedLoadingEnd = false
    var userLikedFeedLoading = false
    var userLikedFeedLoadingEnd = false
    
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

    func resetData() {
        self.userPostedFeedLoading = false
        self.userPostedFeedLoadingEnd = false
        self.userLikedFeedLoading = false
        self.userLikedFeedLoadingEnd = false
        
        self.userPostedProducts.removeAll()
        self.userLikedProducts.removeAll()
        
        reloadDataToView()
    }
    
    func unregisterEvents() {
        SwiftEventBus.unregister(self)
        eventsRegistered = false
    }
   
    func registerEvents() {
        if (!eventsRegistered) {
            
            SwiftEventBus.onMainThread(self, name: "userPostFeedSuccess") { result in
                let resultDto: [PostModel] = result.object as! [PostModel]
                self.handleUserPostedProductsSuccess(resultDto)
            }
            
            SwiftEventBus.onMainThread(self, name: "userPostFeedFailed") { result in
                self.view.makeToast(message: "Error getting User Posted feeds!")
            }
            
            SwiftEventBus.onMainThread(self, name: "userLikedFeedSuccess") { result in
                let resultDto: [PostModel] = result.object as! [PostModel]
                self.handleUserLikedProductsSuccess(resultDto)
            }
            
            SwiftEventBus.onMainThread(self, name: "userLikedFeedFailed") { result in
                self.view.makeToast(message: "Error getting User Liked feeds!")
            }
            
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
    
    func handleUserPostedProductsSuccess(resultDto: [PostModel]) {
        if (!resultDto.isEmpty) {
            if (self.userPostedProducts.count == 0) {
                self.userPostedProducts = resultDto
            } else {
                self.userPostedProducts.appendContentsOf(resultDto)
            }
        } else {
            userPostedFeedLoadingEnd = true
        }
        
        if (feedFilter == FeedFilter.FeedType.USER_POSTED) {
            reloadDataToView()
        }
        
        self.userPostedFeedLoading = false
    }
    
    func handleUserLikedProductsSuccess(resultDto: [PostModel]) {
        if (!resultDto.isEmpty) {
            if (self.userLikedProducts.count == 0) {
                self.userLikedProducts = resultDto
            } else {
                self.userLikedProducts.appendContentsOf(resultDto)
            }
        } else {
            userLikedFeedLoadingEnd = true
        }
        
        if (feedFilter == FeedFilter.FeedType.USER_LIKED) {
            reloadDataToView()
        }
        
        self.userLikedFeedLoading = false
    }
    
    func loadMoreFeedItems() {
        if self.userInfo != nil {
            switch feedFilter! {
            case FeedFilter.FeedType.USER_POSTED:
                if (!self.userPostedFeedLoadingEnd && !self.userPostedFeedLoading) {
                    self.userPostedFeedLoading = true
                    var feedOffSet : Int64 = 0
                    if (!self.userPostedProducts.isEmpty) {
                        feedOffSet = Int64(self.userPostedProducts[self.userPostedProducts.count-1].offset)
                    }
                    ApiControlller.apiController.getUserPostedFeeds(self.userInfo!.id, offSet: feedOffSet)
                }
            case FeedFilter.FeedType.USER_LIKED:
                if (!self.userLikedFeedLoadingEnd && !self.userLikedFeedLoading) {
                    userLikedFeedLoading = true
                    var feedOffSet : Int64 = 0
                    if (!self.userLikedProducts.isEmpty) {
                        feedOffSet = Int64(self.userLikedProducts[self.userLikedProducts.count-1].offset)
                    }
                    ApiControlller.apiController.getUserLikedFeeds(self.userInfo!.id, offSet: feedOffSet)
                }
            default: break
            }
        }
    }
    
    func reloadFeedItems() {
        if let userInfo = self.userInfo {
            switch feedFilter! {
            case FeedFilter.FeedType.USER_POSTED:
                self.userPostedProducts.removeAll()
                self.userPostedFeedLoading = false
                self.userPostedFeedLoadingEnd = false
                if (!self.userPostedFeedLoadingEnd && !self.userPostedFeedLoading) {
                    self.userPostedFeedLoading = true
                    ApiControlller.apiController.getUserPostedFeeds(userInfo.id, offSet: 0)
                }
            case FeedFilter.FeedType.USER_LIKED:
                self.userLikedProducts.removeAll()
                self.userLikedFeedLoading = false
                self.userLikedFeedLoadingEnd = false
                if (!self.userLikedFeedLoadingEnd && !self.userLikedFeedLoading) {
                    self.userLikedFeedLoading = true
                    ApiControlller.apiController.getUserLikedFeeds(userInfo.id, offSet: 0)
                }
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
            return self.userPostedProducts
        } else {
            return self.userLikedProducts
        }
    }
}
