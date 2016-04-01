//
//  ConversationTableViewCell.swift
//  BabyBox
//
//  Created by admin on 01/04/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var unreadComments: UILabel!
    @IBOutlet weak var photoLayout: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var SellText: UILabel!
    @IBOutlet weak var BuyText: UILabel!
    @IBOutlet weak var soldText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
