//
//  UserFeedHeaderViewCell.swift
//  babybox
//
//  Created by Mac on 30/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class UserFeedHeaderViewCell: UICollectionViewCell {
    
    @IBOutlet weak var btnWidthConsttraint: NSLayoutConstraint!
    @IBOutlet weak var profileDescription: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var tipsConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tipsView: UIView!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var browseBtn: UIButton!
    @IBOutlet weak var editProfile: UIButton!
    @IBOutlet weak var followersBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var userImg: UIImageView!
}
