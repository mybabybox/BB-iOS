//
//  FeedProductCollectionViewCell.swift
//  babybox
//
//  Created by Mac on 12/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

class FeedProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var soldImage: UIImageView!
    @IBOutlet weak var userCircleImg: UIImageView!
    @IBOutlet weak var prodImageView: UIImageView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var likeImageIns: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var originalPrice: UILabel!
}
