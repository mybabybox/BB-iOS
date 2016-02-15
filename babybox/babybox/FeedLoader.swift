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
    
    var feedItems: [PostModel] = []
    
    var loading = false
    var loadedAll = false
    
    var error: String? = nil
    
    init(feedType: FeedFilter.FeedType, reloadDataToView: ()->()) {
        self.feedType = feedType
        self.reloadDataToView = reloadDataToView
        
        registerEvents()
    }
    
    func registerEvents() {
        SwiftEventBus.onMainThread(self, name: "feedLoadSuccess") { result in
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleFeedLoadSuccess(resultDto)
        }
        SwiftEventBus.onMainThread(self, name: "feedLoadFailed") { result in
            self.error = "Error getting User Posted feeds!"
        }
    }
    
    func handleFeedLoadSuccess(items: [PostModel]) {
        if (!items.isEmpty) {
            if (self.feedItems.count == 0) {
                self.feedItems = items
            } else {
                self.feedItems.appendContentsOf(items)
            }
        } else {
            loadedAll = true
        }
        
        reloadDataToView()
        
        loading = false
    }
    
    func clearFeedItems() {
        feedItems.removeAll()
        loading = false
        loadedAll = false
        reloadDataToView()
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
    
    func reloadFeedItems(objId: Int) {
        clearFeedItems()
        if (!loadedAll && !loading) {
            loading = true
            loadFeed(0, objId: objId)
        }
    }
    
    func loadFeed(feedOffset: Int64, objId: Int) {
        switch feedType {
        case FeedFilter.FeedType.HOME_EXPLORE:
            ApiControlller.apiController.getHomeExploreFeed(feedOffset)
        case FeedFilter.FeedType.HOME_FOLLOWING:
            ApiControlller.apiController.getHomeFollowingFeed(feedOffset)
        case FeedFilter.FeedType.CATEGORY_POPULAR:
            ApiControlller.apiController.getCategoryPopularFeed(objId, offSet: feedOffset)
        case FeedFilter.FeedType.CATEGORY_NEWEST:
            ApiControlller.apiController.getCategoryNewestFeed(objId, offSet: feedOffset)
        case FeedFilter.FeedType.CATEGORY_PRICE_LOW_HIGH:
            ApiControlller.apiController.getCategoryPriceLowHighFeed(objId, offSet: feedOffset)
        case FeedFilter.FeedType.CATEGORY_PRICE_HIGH_LOW:
            ApiControlller.apiController.getCategoryPriceHighLowFeed(objId, offSet: feedOffset)
        case FeedFilter.FeedType.USER_POSTED:
            ApiControlller.apiController.getUserPostedFeed(objId, offSet: feedOffset)
        case FeedFilter.FeedType.USER_LIKED:
            ApiControlller.apiController.getUserLikedFeed(objId, offSet: feedOffset)
        default: break
        }
    }
}
