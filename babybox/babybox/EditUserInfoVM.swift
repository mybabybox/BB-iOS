//
//  EditUserInfoVM.swift
//  BabyBox
//
//  Created by admin on 02/04/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import ObjectMapper

class EditUserInfoVM: NSObject {
    
    var email: String = ""
    var aboutMe: String = ""
    var displayName: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var location: Int = -1
    
    init(email: String, aboutMe: String, displayName: String,
        firstName: String, lastName: String, location: Int) {
            
        self.email = email
        self.aboutMe = aboutMe
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.location = location
    }

}