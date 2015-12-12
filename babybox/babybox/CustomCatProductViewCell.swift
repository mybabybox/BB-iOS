//
//  CustomCatProductViewCell.swift
//  babybox
//
//  Created by Mac on 11/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

class CustomCatProductViewCell: UICollectionViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var likeCounter: UILabel!
    @IBOutlet weak var likeImg: UIButton!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var title: UILabel!
    
    var id: Int = 0
    var likeFlag = false
    
}
