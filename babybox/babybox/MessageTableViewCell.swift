//
//  MessageTableViewCell.swift
//  GallerySwiftApp
//
//  Created by Apple on 15/12/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var btnDeleteComments: UIButton!
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var txtEnterComments: UITextField!
    @IBOutlet weak var btnPostComments: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
