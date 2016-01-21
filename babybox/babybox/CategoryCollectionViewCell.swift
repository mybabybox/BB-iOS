//
//  CategoryCollectionViewCell.swift
//  Baby Box
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var highToLow: UIButton!
    @IBOutlet weak var popularBtn: UIButton!
    @IBOutlet weak var newestBtn: UIButton!
    @IBOutlet weak var lowToHighBtn: UIButton!
    
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryIcon: UIImageView!
    
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
}
