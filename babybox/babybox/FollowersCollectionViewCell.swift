//
//  FollowersCollectionViewCell.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

class FollowersCollectionViewCell: UICollectionViewCell {
    
    var userId: Int = 0
    
    @IBOutlet weak var followingBtn: UIButton!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBAction func onClickBtn(sender: AnyObject) {
    }
    
}
