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
    
    static func refresh(successCallback: (([CategoryVM]) -> Void)?, failureCallback: (() -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedSuccess") { result in
            self.categories = result.object as! [CategoryVM]
            if successCallback != nil {
                successCallback!(categories)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedFailed") { result in
            if failureCallback != nil {
                failureCallback!()
            }
        }
        
        ApiController.instance.getCategories()
    }
    
    static func getCategoryById(catId: Int) -> CategoryVM {
        var category: CategoryVM? = nil
        for index in 0...CategoryCache.categories.count {
            if (Int(CategoryCache.categories[index].id) == catId) {
                category = CategoryCache.categories[index]
                break
            }
        }
        return category!
    }
    
    static func setCategories(cats: [CategoryVM]) {
        CategoryCache.categories = cats
    }

}