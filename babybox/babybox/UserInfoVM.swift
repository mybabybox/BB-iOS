//
//  UserInfoVM.swift
//  Baby Box
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//
import ObjectMapper

class UserInfoVM: UserVM {
    
    var email: String = "";
    var aboutMe: String = "";
    var firstName: String = "";
    var lastName: String = "";
    var gender: String = "";
    var birthYear: String = "";
    var location: LocationVM = LocationVM();
    var settings: SettingVM = SettingVM();
    var createdDate: Double = 0;
    var lastLogin: Double = 0;
    var totalLogin: Double = 0;
    var isLoggedIn: Bool = false;
    var isFBLogin: Bool = false;
    var emailValidated: Bool = false;
    var newUser: Bool = false;
    var isAdmin: Bool = false;
    var isMobile: Bool = false;
    
    override func mapping(map: ObjectMapper.Map) {
    
        email<-map["email"];
        aboutMe<-map["aboutMe"];
        firstName<-map["firstName"];
        lastName<-map["lastName"];
        gender<-map["gender"];
        birthYear<-map["birthYear"];
        //location<-map["LocationVM"];
        //settings<-map["]SettingVM"];
        createdDate<-map["createdDate"]
        lastLogin<-map["lastLogin"];
        totalLogin<-map["totalLogin"];
        isLoggedIn<-map["isLoggedIn"];
        isFBLogin<-map["isFBLogin"];
        emailValidated<-map["emailValidated"];
        newUser<-map["newUser"];
        isAdmin<-map["isAdmin"];
        isMobile<-map["isMobile"];
        
    }
}