//
//  CommentTableViewCell.swift
//  BabyBox
//
//  Created by admin on 13/04/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentTime: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
