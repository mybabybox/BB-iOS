//
//  CommentTableViewCell.swift
//  babybox
//
//  Created by Mac on 24/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var delCommentBtn: UIButton!
    @IBOutlet weak var createTime: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var comment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
