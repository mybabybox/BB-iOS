//
//  FollowingCollectionViewCell.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

class FollowingCollectionViewCell: UICollectionViewCell {
    
    var userId: Int = 0
    
    @IBOutlet weak var followingsBtn: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
}
