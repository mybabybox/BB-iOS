//
//  FeedLoader.swift
//  babybox
//
//  Created by Mac on 30/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftEventBus

class FeedLoader {
    
    var feedType: FeedFilter.FeedType
    var reloadDataToView: ()->()
    var activityIndicator: UIActivityIndicatorView?
    
    var feedItems: [PostVMLite] = []
    
    var loading = false
    var loadedAll = false
    
    var error: String? = nil
    
    init(feedType: FeedFilter.FeedType, reloadDataToView: ()->()) {
        self.feedType = feedType
        self.reloadDataToView = reloadDataToView
        registerEvents()
    }
    
    func setFeedType(feedType: FeedFilter.FeedType) {
        self.feedType = feedType
        clearFeedItems()
        registerEvents()
        NSLog("FeedLoader.setFeedType: feedType="+String(feedType))
    }
    
    func setActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        self.activityIndicator = activityIndicator
    }
    
    func unregisterEvents() {
        SwiftEventBus.unregister(self)
    }
        
    func registerEvents() {
        unregisterEvents()
        
        switch feedType {
        case FeedFilter.FeedType.HOME_EXPLORE:
            SwiftEventBus.onMainThread(self, name: "homeExploreFeedLoadSuccess") { result in
                let resultDto: [PostVMLite] = result.object as! [PostVMLite]
                self.handleFeedLoadSuccess(resultDto)
            }
            SwiftEventBus.onMainThread(self, name: "homeExploreFeedLoadFailed") { result in
                self.error = "Error getting home explore feed!"
            }
        case FeedFilter.FeedType.HOME_FOLLOWING:
            SwiftEventBus.onMainThread(self, name: "homeFollowingFeedLoadSuccess") { result in
                let resultDto: [PostVMLite] = result.object as! [PostVMLite]
                self.handleFeedLoadSuccess(resultDto)
            }
            SwiftEventBus.onMainThread(self, name: "homeFollowingFeedLoadFailed") { result in
                self.error = "Error getting home following feed!"
            }
        case FeedFilter.FeedType.CATEGORY_POPULAR:
            SwiftEventBus.onMainThread(self, name: "categoryPopularFeedLoadSuccess") { result in
                let resultDto: [PostVMLite] = result.object as! [PostVMLite]
                self.handleFeedLoadSuccess(resultDto)
            }
            SwiftEventBus.onMainThread(self, name: "categoryPopularFeedLoadFailed") { result in
                self.error = "Error getting category popular feed!"
            }
        case FeedFilter.FeedType.CATEGORY_NEWEST:
            SwiftEventBus.onMainThread(self, name: "categoryNewestFeedLoadSuccess") { result in
                let resultDto: [PostVMLite] = result.object as! [PostVMLite]
                self.handleFeedLoadSuccess(resultDto)
            }
            SwiftEventBus.onMainThread(self, name: "categoryNewestFeedLoadFailed") { result in
                self.error = "Error getting category newest feed!"
            }
        case FeedFilter.FeedType.CATEGORY_PRICE_LOW_HIGH:
            SwiftEventBus.onMainThread(self, name: "categoryPriceLowHighFeedLoadSuccess") { result in
                let resultDto: [PostVMLite] = result.object as! [PostVMLite]
                self.handleFeedLoadSuccess(resultDto)
            }
            SwiftEventBus.onMainThread(self, name: "categoryPriceLowHighFeedLoadFailed") { result in
                self.error = "Error getting category price low high feed!"
            }
        case FeedFilter.FeedType.CATEGORY_PRICE_HIGH_LOW:
            SwiftEventBus.onMainThread(self, name: "categoryPriceHighLowFeedLoadSuccess") { result in
                let resultDto: [PostVMLite] = result.object as! [PostVMLite]
                self.handleFeedLoadSuccess(resultDto)
            }
            SwiftEventBus.onMainThread(self, name: "categoryPriceHighLowFeedLoadFailed") { result in
                self.error = "Error getting category price high low feed!"
            }
        case FeedFilter.FeedType.USER_POSTED:
            SwiftEventBus.onMainThread(self, name: "userPostedFeedLoadSuccess") { result in
                let resultDto: [PostVMLite] = result.object as! [PostVMLite]
                self.handleFeedLoadSuccess(resultDto)
            }
            SwiftEventBus.onMainThread(self, name: "userPostedFeedLoadFailed") { result in
                self.error = "Error getting user posted feed!"
            }
        case FeedFilter.FeedType.USER_LIKED:
            SwiftEventBus.onMainThread(self, name: "userLikedFeedLoadSuccess") { result in
                let resultDto: [PostVMLite] = result.object as! [PostVMLite]
                self.handleFeedLoadSuccess(resultDto)
            }
            SwiftEventBus.onMainThread(self, name: "userLikedFeedLoadFailed") { result in
                self.error = "Error getting user liked feed!"
            }
        default: break
        }
    }
    
    func handleFeedLoadSuccess(feedItems: [PostVMLite]) {
        NSLog("FeedLoader.handleFeedLoadSuccess: feedItems="+String(feedItems.count)+" feedType="+String(feedType))
        if (!feedItems.isEmpty) {
            if (self.feedItems.count == 0) {
                self.feedItems = feedItems
            } else {
                self.feedItems.appendContentsOf(feedItems)
            }
            reloadDataToView()
        } else {
            loadedAll = true
        }
        loading = false
        ViewUtil.hideActivityLoading(activityIndicator)
    }
    
    func clearFeedItems() {
        feedItems = []
        loading = false
        loadedAll = false
        reloadDataToView()
        NSLog("FeedLoader.clearFeedItems")
    }
    
    func loadMoreFeedItems() {
        loadMoreFeedItems(-1)
    }
    
    func loadMoreFeedItems(objId: Int) {
        if (!loadedAll && !loading) {
            loading = true
            var feedOffset: Int64 = 0
            if (!feedItems.isEmpty) {
                feedOffset = Int64(feedItems[feedItems.count-1].offset)
            }
            loadFeed(feedOffset, objId: objId)
        }
    }
    
    func reloadFeedItems() {
        reloadFeedItems(-1)
    }
    
    func reloadFeedItems(objId: Int) {
        if (!loading) {
            clearFeedItems()
            loading = true
            loadFeed(0, objId: objId)
        }
    }
    
    func loadFeed(feedOffset: Int64, objId: Int) {
        NSLog("FeedLoader.loadFeed: feedOffset="+String(feedOffset)+" objId="+String(objId)+" feedType="+String(feedType))
        ViewUtil.showActivityLoading(activityIndicator)
        switch feedType {
        case FeedFilter.FeedType.HOME_EXPLORE:
            ApiController.instance.getHomeExploreFeed(feedOffset)
        case FeedFilter.FeedType.HOME_FOLLOWING:
            ApiController.instance.getHomeFollowingFeed(feedOffset)
        case FeedFilter.FeedType.CATEGORY_POPULAR:
            ApiController.instance.getCategoryPopularFeed(objId, offset: feedOffset)
        case FeedFilter.FeedType.CATEGORY_NEWEST:
            ApiController.instance.getCategoryNewestFeed(objId, offset: feedOffset)
        case FeedFilter.FeedType.CATEGORY_PRICE_LOW_HIGH:
            ApiController.instance.getCategoryPriceLowHighFeed(objId, offset: feedOffset)
        case FeedFilter.FeedType.CATEGORY_PRICE_HIGH_LOW:
            ApiController.instance.getCategoryPriceHighLowFeed(objId, offset: feedOffset)
        case FeedFilter.FeedType.USER_POSTED:
            ApiController.instance.getUserPostedFeed(objId, offset: feedOffset)
        case FeedFilter.FeedType.USER_LIKED:
            ApiController.instance.getUserLikedFeed(objId, offset: feedOffset)
        default: break
        }
    }
    
    func size() -> Int {
        return feedItems.count
    }
    
    func getItem(i: Int) -> PostVMLite {
        return feedItems[i]
    }
}
