//
//  HomeReusableViewCollectionReusableView.swift
//  babybox
//
//  Created by Mac on 12/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

class HomeReusableView: UICollectionReusableView {

    @IBOutlet weak var trailingconstraints: NSLayoutConstraint!
    @IBOutlet weak var leadingConstrains: NSLayoutConstraint!
    
    @IBOutlet weak var headerViewCollection: UICollectionView!
    
    override func updateConstraints() {
        super.updateConstraints()
    }
}
