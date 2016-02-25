//
//  CategoryCache.swift
//  babybox
//
//  Created by Mac on 04/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation


class CategoryCache {
    
    static var categories: [CategoryVM] = []
    
    init() {
    
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