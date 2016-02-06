//
//  CategoryCache.swift
//  babybox
//
//  Created by Mac on 04/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation


class CategoryCache {
    
    static var categories: [CategoryModel] = []
    
    init() {
    
    }
    
    static func getCategoryById(catId: Int) -> CategoryModel {
        var category: CategoryModel? = nil
        for index in 0...CategoryCache.categories.count {
            if (Int(CategoryCache.categories[index].id) == catId) {
                category = CategoryCache.categories[index]
                break
            }
        }
        return category!
    }
    
    static func setCategories(cats: [CategoryModel]) {
        CategoryCache.categories = cats
    }

}