//
//  NotificationViewCell.swift
//  BabyBox
//
//  Created by admin on 30/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class NotificationViewCell: UITableViewCell {
    //MARK: Params
    @IBOutlet weak var notificationTitle : UILabel!
    @IBOutlet weak var isEnabledSwitch : UISwitch!
    var notification : NotificationVM!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: Set Data Source
    func setUIWithDataSource(notification: NotificationVM) {
        self.notification = notification
        self.notificationTitle.text = self.notification.title
        self.isEnabledSwitch.setOn(self.notification.isEnabled, animated: true)
    }
    //MARK : Switch Action Method
    @IBAction func switchValueChanged(sender : UISwitch){
        self.notification.isEnabled = sender.on
    }
    
}