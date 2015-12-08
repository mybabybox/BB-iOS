//
//  Login.swift
//  Baby Box
//
//  Created by Mac on 06/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import ObjectMapper
//import Alamofire
//import AlamofireObjectMapper
import SwiftEventBus

//let kBaseServerURL = "http://192.168.2.18:9000/"
//let imagesBaseURL = "http://192.168.2.18:9000";

class ApiControlller {
    struct Payload {
                    var postId : Int = 0
                    var body = ""
                }
    
    init() {
        
        /*SwiftEventBus.onBackgroundThread(self, name: "getUserLoggedIn") {
            result in
            NSLog("getUserLoggedIn")
            
            //let arg: BaseArgVM = result.object as! BaseArgVM
            let callEvent = ApiCallEvent()
            callEvent.method = "mobile/login"
            callEvent.resultClass = "ResponseVM"
            callEvent.successEventbusName = "userLoginSuccess"
            callEvent.failedEventbusName = "userLoginFailed"
            //callEvent.arg = arg
            callEvent.apiUrl = kBaseServerURL + callEvent.method;
            
            self.makeApiCall(callEvent)
        }*/
        
        /*SwiftEventBus.onBackgroundThread(self, name: "getCategories") {
            result in
            NSLog("payPalCheckout")
            
            let arg: BaseArgVM = result.object as! BaseArgVM
            let callEvent = ApiCallEvent()
            callEvent.method = "categories"
            callEvent.resultClass = "CategoryVM"
            callEvent.successEventbusName = "categoriesReceivedSuccess"
            callEvent.failedEventbusName = "categoriesReceivedFailed"
            callEvent.arg = arg
            callEvent.apiUrl = kBaseServerURL + callEvent.method;
            
            self.makeApiCall(callEvent)
        }*/
    }
    
    func getAllCategories() {
        let callEvent = ApiCallEvent()
        callEvent.method = "categories"
        callEvent.resultClass = "CategoryModel"
        callEvent.successEventbusName = "categoriesReceivedSuccess"
        callEvent.failedEventbusName = "categoriesReceivedFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method;
        
        self.makeApiCall(callEvent)
    }
    
    func getAllFeedProducts() {
        let callEvent = ApiCallEvent()
        callEvent.method = "get-all-feed-products"
        callEvent.resultClass = "PostModel"
        callEvent.successEventbusName = "allPostsReceivedSuccess"
        callEvent.failedEventbusName = "allPostsReceivedFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method;
    
        self.makeApiCall(callEvent)
    }
    
    //Get the post of type HOME_EXPLORE & HOME_FOLLOWING
    func getHomeExploreFeeds(offSet: String) {
        let callEvent = ApiCallEvent()
        callEvent.method = "get-home-explore-feed"
        callEvent.resultClass = "PostModel"
        callEvent.successEventbusName = "homeExplorePostsReceivedSuccess"
        callEvent.failedEventbusName = "postsReceivedFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method + "/" + offSet;
        
        self.makeApiCall(callEvent)
    }
    
    func getHomeEollowingFeeds(offSet: String) {
        let callEvent = ApiCallEvent()
        callEvent.method = "get-home-following-feed"
        callEvent.resultClass = "PostModel"
        callEvent.successEventbusName = "homeFollowingPostsReceivedSuccess"
        callEvent.failedEventbusName = "postsReceivedFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method + "/" + offSet
        
        self.makeApiCall(callEvent)
    }
    
    func getUserInfo() {
        let callEvent = ApiCallEvent()
        callEvent.method = "get-user"
        callEvent.resultClass = "UserInfoModel"
        callEvent.successEventbusName = "categoriesReceivedSuccess"
        callEvent.failedEventbusName = "categoriesReceivedFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method + "/"; //append logged in user id to get the logged in user details.
        
        self.makeApiCall(callEvent)
    }
    
    func postLikeButton(offSet: String) {
        let callEvent = ApiCallEvent()
        callEvent.method = "like-post"
        callEvent.resultClass = "String"
        //callEvent.successEventbusName = "homeFollowingPostsReceivedSuccess"
        //callEvent.failedEventbusName = "postsReceivedFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method + "/" + offSet
        
        self.makeApiCall(callEvent)
    }
    
    func postUnlikeButton(offSet: String) {
        let callEvent = ApiCallEvent()
        callEvent.method = "unlike-post"
        callEvent.resultClass = "String"
        //callEvent.successEventbusName = "homeFollowingPostsReceivedSuccess"
        //callEvent.failedEventbusName = "postsReceivedFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method + "/" + offSet
        
        self.makeApiCall(callEvent)
    }
    
    func getProductDetails(offSet: String) {
        let callEvent = ApiCallEvent()
        callEvent.method = "post"
        callEvent.resultClass = "PostCatModel"
        callEvent.successEventbusName = "productDetailsReceivedSuccess"
        callEvent.failedEventbusName = "productDetailsFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method + "/" + offSet
        
        self.makeApiCall(callEvent)
    }
    
    func postComment(id: String, comment: String){
        print("In api call for id \(id) and comment --\(comment)", terminator: "")
        var strData = [String]()
        strData.append("postId=\(id)")
        strData.append("body=\(comment)")
        let parameter = self.makeBodyString(strData)
        
        let callEvent = ApiCallEvent()
        callEvent.method = "comment/new"
        callEvent.resultClass = "String"
        callEvent.body = parameter
        //callEvent.successEventbusName = "productDetailsReceivedSuccess"
        //callEvent.failedEventbusName = "productDetailsFailed"
        
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makePostApiCall(callEvent)
    }
    
    func makeApiCall(arg: ApiCallEvent) {
        //
        NSLog("makeApiCall")
        
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: arg.apiUrl)
        request.HTTPMethod = "GET"
        NSLog("sending string %@", arg.apiUrl)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                SwiftEventBus.post(arg.failedEventbusName, sender: error)
            } else {
                let result = self.handleResult(data!, arg: arg)
                //if (!result.success) {
                SwiftEventBus.post(arg.successEventbusName, sender: result)
                //} else {
                //    SwiftEventBus.post(arg.successEventbusName, sender: result)
                //}
            }
        })
        task.resume()
    }
    
    
    func makePostApiCall(arg: ApiCallEvent) {
        NSLog("makePostApiCall")
        
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: arg.apiUrl)
        request.HTTPMethod = "POST"
        
        if (arg.body != "") {
            request.HTTPBody = arg.body.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        NSLog("sending string %@", arg.apiUrl)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                SwiftEventBus.post(arg.failedEventbusName, sender: error)
            } else {
                let result: AnyObject = self.handleResult(data!, arg: arg)
                SwiftEventBus.post(arg.successEventbusName, sender: result)
    
            }
        })
        task.resume()
    }
    
    func authenticateUser(userName: String, password: String) -> Bool {
        
        let url = constants.kBaseServerURL + "mobile/login?email=\(userName)&password=\(password)"
        
        let callEvent = ApiCallEvent()
        callEvent.method = "mobile/login"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "loginReceivedSuccess"
        callEvent.failedEventbusName = "loginReceivedFailed"
        callEvent.apiUrl = url
        
        makePostApiCall(callEvent)
        
        return true
    }
    
    func forgotPasswordRequest(emailAddress: String) -> Bool {
        let url = constants.kBaseServerURL + "login/password/forgot?email=\(emailAddress)"
        
        let callEvent = ApiCallEvent()
        callEvent.method = "login/password/forgot"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "forgotPasswordSuccess"
        callEvent.failedEventbusName = "forgotPasswordFailed"
        callEvent.apiUrl = url
        
        self.makeApiCall(callEvent)
        
        return true
        
    }
    
    func handleResult(data: NSData, arg: ResponseVM) {
        //print("response")
        let error3: AutoreleasingUnsafeMutablePointer<NSError?> = nil
        let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        NSLog("responseString %@", responseString)
        let result: AnyObject = self.parseStr(arg.resultClass, inputStr: responseString as String)
        SwiftEventBus.post("getUserLoggedIn", sender: result)
        
    }
    
    func handleResult(data: NSData, arg: ApiCallEvent) -> AnyObject {
        let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        NSLog("responseString %@", responseString)
        let result: AnyObject = self.parseStr(arg.resultClass, inputStr: responseString as String)
        return result
    }
    
    func parseStr(cName: String, inputStr: String) -> AnyObject {
        var result: AnyObject = NSNull();
        switch cName {
            case "CategoryModel":
                result = Mapper<CategoryModel>().mapArray(inputStr)!
            print(result, terminator: "")
            //result = Mapper<CategoryModel>().mapArray(inputStr)
            case "UserInfoModel": result = Mapper<UserInfoModel>().map(inputStr)!
            case "ResponseVM": result = Mapper<ResponseVM>().map(inputStr)!
            case "PostModel": result = Mapper<PostModel>().mapArray(inputStr)!
            case "PostCatModel": result = Mapper<PostCatModel>().mapArray(inputStr)!
            case "String":
                print(inputStr, terminator: "")
                result = inputStr
            default:
                print("calling default object resolver", terminator: "")
        }
        return result
    }
    
    
    
     class func toJson(res: CommentVM) -> String {
       var JSONString = ""
        if (res is CommentVM) {
           JSONString = Mapper<CommentVM>().toJSONString(res as! CommentVM, prettyPrint: true)!
        }
        NSLog("inside tojson")
        let str = CFURLCreateStringByAddingPercentEscapes(
            nil,
            JSONString,
            nil,
            "!*'();:@&=+$,/?%#[]",
            CFStringBuiltInEncodings.UTF8.rawValue
        )
        NSLog(JSONString)
        //remeber to do urlescape on argPayload too
        //return JSONString
        
        return str as String
    }
    
    func makeBodyString(strData:[String]) -> String {
        var result = ""
        for myStr in strData
        {
            if(result == "") {
                result = myStr
            }else {
                result += "&\(myStr)"
            }
        }
        return result
    }
    
}
