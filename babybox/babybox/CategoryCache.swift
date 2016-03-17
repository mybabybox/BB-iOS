//
//  CategoryCache.swift
//  babybox
//
//  Created by Mac on 04/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftEventBus

class CategoryCache {
    
    static var categories: [CategoryVM] = []
    
    init() {
    }

    static func refresh() {
        self.refresh(nil, failureCallback: nil)
    }
    
    static func refresh(successCallback: (([CategoryVM]) -> Void)?, failureCallback: ((error: String) -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedSuccess") { result in
            SwiftEventBus.unregister(self)
            
            if ViewUtil.isEmptyResult(result) {
                failureCallback!(error: "Categories returned is empty")
                return
            }
            
            self.categories = result.object as! [CategoryVM]
            if successCallback != nil {
                successCallback!(categories)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedFailed") { result in
            SwiftEventBus.unregister(self)
            
            if failureCallback != nil {
                var error = "Failed to get categories..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error: error)
            }
        }
        
        ApiController.instance.getCategories()
    }
    
    static func getCategoryById(catId: Int) -> CategoryVM? {
        for index in 0...CategoryCache.categories.count {
            if (Int(CategoryCache.categories[index].id) == catId) {
                return CategoryCache.categories[index]
            }
        }
        return nil
    }
    
    static func getCategoryByName(name: String) -> CategoryVM? {
        for index in 0...CategoryCache.categories.count {
            if (CategoryCache.categories[index].name == name) {
                return CategoryCache.categories[index]
            }
        }
        return nil
    }
    
    static func setCategories(cats: [CategoryVM]) {
        CategoryCache.categories = cats
    }

}