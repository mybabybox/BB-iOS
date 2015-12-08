//
//  ProductCollectionViewCell.swift
//  Baby Box
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productPrice: UILabel!
    
    @IBOutlet weak var likeIcon: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    
    @IBOutlet weak var productImg: UIImageView!
//    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
//        super.applyLayoutAttributes(layoutAttributes)
//        if let attributes = layoutAttributes as? PinterestLayoutAttributes {
//            //imageViewHeightLayoutConstraint.constant = attributes.photoHeight
//        }
//    }
}
