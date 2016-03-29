//
//  NotificationVM.swift
//  BabyBox
//
//  Created by admin on 30/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class NotificationVM: NSObject {
    //MARK: Params
    var title : String = ""
    var isEnabled : Bool = false
    
    //MARK: Initializer
    init(title: String, isEnabled: Bool) {
        self.title = title
        self.isEnabled = isEnabled
    }
}
