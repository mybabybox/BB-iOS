//
//  UserActivityViewCell.swift
//  babybox
//
//  Created by Mac on 17/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class UserActivityViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textMessage: UILabel!
    @IBOutlet weak var messageWidth: NSLayoutConstraint!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var prodImg: UIButton!
    @IBOutlet weak var activityTime: UILabel!
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var userImg: UIButton!
}
