//
//  Login.swift
//  Baby Box
//
//  Created by Mac on 06/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//
 
import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import SwiftEventBus

class ApiController {
    
    struct Payload {
        var postId : Int = 0
        var body = ""
    }
    
    static let instance = ApiController()
    
    init() {
    }
    
    func getAllCategories() {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-categories"
        callEvent.resultClass = "CategoryModel"
        callEvent.successEventbusName = "categoriesReceivedSuccess"
        callEvent.failedEventbusName = "categoriesReceivedFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    //Get the post of type HOME_FOLLOWING
    func getHomeExploreFeed(offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-home-explore-feed/\(offset)"
        callEvent.resultClass = "PostModel"
        callEvent.successEventbusName = "homeExploreFeedLoadSuccess"
        callEvent.failedEventbusName = "homeExploreFeedLoadFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method;
        
        self.makeApiCall(callEvent)
    }
    
    func getHomeFollowingFeed(offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-home-following-feed/\(offset)"
        callEvent.resultClass = "PostModel"
        callEvent.successEventbusName = "homeFollowingFeedLoadSuccess"
        callEvent.failedEventbusName = "homeFollowingFeedLoadFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func getUserInfo() {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-user-info"
        callEvent.resultClass = "UserInfoVM"
        callEvent.successEventbusName = "userInfoSuccess"
        callEvent.failedEventbusName = "userInfoFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method; //append logged in user id to get the logged in user details.
        
        self.makeApiCall(callEvent)
    }
    
    func getUser(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-user/\(id)"
        callEvent.resultClass = "UserVMById"
        callEvent.successEventbusName = "userByIdSuccess"
        callEvent.failedEventbusName = "userByIdFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getUserActivities(offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-activities/\(offset)"
        callEvent.resultClass = "ActivityVM"
        callEvent.successEventbusName = "userActivitiesSuccess"
        callEvent.failedEventbusName = "userActivitiesFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
        
    }
    
    func likePost(id: String) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/like-post/\(id)"
        callEvent.resultClass = "String"
        //callEvent.successEventbusName = ""
        //callEvent.failedEventbusName = ""
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func unlikePost(id: String) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/unlike-post/\(id)"
        callEvent.resultClass = "String"
        //callEvent.successEventbusName = ""
        //callEvent.failedEventbusName = ""
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func getProductDetails(id: String) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-post/\(id)"
        callEvent.resultClass = "PostCatModel"
        callEvent.successEventbusName = "productDetailsReceivedSuccess"
        callEvent.failedEventbusName = "productDetailsReceivedFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func followUser(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/follow-user/\(id)"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "followUserSuccess"
        callEvent.failedEventbusName = "followUserFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func unfollowUser(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/unfollow-user/\(id)"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "unfollowUserSuccess"
        callEvent.failedEventbusName = "unfollowUserFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func postComment(id: String, comment: String){
        var strData = [String]()
        strData.append("postId=\(id)")
        strData.append("body=\(comment)")
        let parameter = self.makeBodyString(strData)
        
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/comment/new"
        callEvent.resultClass = "String"
        callEvent.body = parameter
        //callEvent.successEventbusName = ""
        //callEvent.failedEventbusName = ""
        
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makePostApiCall(callEvent)
    }

    func loginByFacebook(authToken: String) -> Bool {
        let url = constants.kBaseServerURL + "/authenticate/mobile/facebook?access_token=\(authToken)"
        let callEvent = ApiCallEvent()
        callEvent.method = "/authenticate/mobile/facebook"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "loginReceivedSuccess"
        callEvent.failedEventbusName = "loginReceivedFailed"
        callEvent.apiUrl = url
        
        makePostApiCall(callEvent)
        
        return true
    }
    
    func loginByEmail(userName: String, password: String) -> Bool {
        
        let url = constants.kBaseServerURL + "/login/mobile?email=\(userName)&password=\(password)"
        
        let callEvent = ApiCallEvent()
        callEvent.method = "/login/mobile"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "loginReceivedSuccess"
        callEvent.failedEventbusName = "loginReceivedFailed"
        callEvent.apiUrl = url
        
        makePostApiCall(callEvent)
        
        return true
    }
    
    func forgotPasswordRequest(emailAddress: String) -> Bool {
        let url = constants.kBaseServerURL + "/login/password/forgot?email=\(emailAddress)"
        
        let callEvent = ApiCallEvent()
        callEvent.method = "/login/password/forgot"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "forgotPasswordSuccess"
        callEvent.failedEventbusName = "forgotPasswordFailed"
        callEvent.apiUrl = url
        
        self.makeApiCall(callEvent)
        
        return true
        
    }
    
    //Categories products filter APIs calls
    func logoutUser() {
        let callEvent = ApiCallEvent()
        callEvent.method = "/logout"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "logoutSuccess"
        callEvent.failedEventbusName = "logoutFailed"
        callEvent.apiUrl = constants.kBaseServerURL
        self.makeApiCall(callEvent)
    }
    
    //Categories products filter APIs calls
    func getCategoryPopularFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-category-popular-feed/\(id)/ALL/\(offset)"
        callEvent.resultClass = "PostModel"
        callEvent.successEventbusName = "categoryPopularFeedLoadSuccess"
        callEvent.failedEventbusName = "categoryPopularFeedLoadFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getCategoryNewestFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-category-newest-feed/\(id)/ALL/\(offset)"
        callEvent.resultClass = "PostModel"
        callEvent.successEventbusName = "categoryNewestFeedLoadSuccess"
        callEvent.failedEventbusName = "categoryNewestFeedLoadFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getCategoryPriceLowHighFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-category-price-low-high-feed/\(id)/ALL/\(offset)"
        callEvent.resultClass = "PostModel"
        callEvent.successEventbusName = "categoryPriceLowHighFeedLoadSuccess"
        callEvent.failedEventbusName = "categoryPriceLowHighFeedLoadFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getCategoryPriceHighLowFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-category-price-high-low-feed/\(id)/ALL/\(offset)"
        callEvent.resultClass = "PostModel"
        callEvent.successEventbusName = "categoryPriceHighLowFeedLoadSuccess"
        callEvent.failedEventbusName = "categoryPriceHighLowFeedLoadFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getUserPostedFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-user-posted-feed/\(id)/\(offset)"
        callEvent.resultClass = "PostModel"
        callEvent.successEventbusName = "userPostedFeedLoadSuccess"
        callEvent.failedEventbusName = "userPostedFeedLoadFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getUserLikedFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-user-liked-feed/\(id)/\(offset)"
        callEvent.resultClass = "PostModel"
        callEvent.successEventbusName = "userLikedFeedLoadSuccess"
        callEvent.failedEventbusName = "userLikedFeedLoadFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getUserFollowings(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-followings/\(id)/\(offset)"
        callEvent.resultClass = "UserVM"
        callEvent.successEventbusName = "userFollowersFollowingsSuccess"
        callEvent.failedEventbusName = "userFollowersFollowingsFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getUserFollowers(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-followers/\(id)/\(offset)"
        callEvent.resultClass = "UserVM"
        callEvent.successEventbusName = "userFollowersFollowingsSuccess"
        callEvent.failedEventbusName = "userFollowersFollowingsFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getAllDistricts() { //filtering by high-low price
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-districts"
        callEvent.resultClass = "LocationModel"
        callEvent.successEventbusName = "getDistrictSuccess"
        callEvent.failedEventbusName = "getDistrictFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    //User Security APIs
    func saveUserSignUpInfo(displayName: String, locationId: Int) {
        var strData = [String]()
        strData.append("parent_displayname=\(displayName)")
        strData.append("parent_location=\(locationId)")
        let parameter = self.makeBodyString(strData)
        
        let callEvent = ApiCallEvent()
        callEvent.method = "/saveSignupInfo"
        callEvent.resultClass = "String"
        callEvent.body = parameter
        callEvent.successEventbusName = "saveSignInfoSuccess"
        callEvent.failedEventbusName = "saveSignInfoFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makePostApiCall(callEvent)
    }
    
    func uploadUserProfileImg(profileImg: UIImage) {
        let callEvent=ApiCallEvent()
        callEvent.method="/image/upload-profile-photo"
        callEvent.resultClass="String"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        callEvent.successEventbusName = "profileImgUploadSuccess"
        callEvent.failedEventbusName = "profileImgUploadFailed"
        
        Alamofire.upload(
            .POST,
            callEvent.apiUrl,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(profileImg)!, name: "profile-photo", fileName: "upload.jpg", mimeType:"*")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success( _, _, _):
                    SwiftEventBus.post(callEvent.successEventbusName, sender: "")
                    break
                case .Failure( _):
                    SwiftEventBus.post(callEvent.failedEventbusName, sender: "")
                    break
                }
            }
        )
    }
    
    func getConversation() {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-conversations"
        callEvent.resultClass = "ConversationVM"
        callEvent.successEventbusName = "conversationsSuccess"
        callEvent.failedEventbusName = "conversationsFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method;
        
        self.makeApiCall(callEvent)
    }
    func getSellProduct(){
        let callEvent=ApiCallEvent()
        callEvent.method="/api/post/new"
        callEvent.resultClass="SellVm"
        callEvent.successEventbusName="getSellSucess"
        callEvent.failedEventbusName="gerSellFailed"
        callEvent.apiUrl=constants.kBaseServerURL + callEvent.method;
        
        self.makeApiCall(callEvent)
    }
    
    /*func signup(){
        let callEvent=ApiCallEvent()
        callEvent.method="/signup"
        callEvent.resultClass="String"
        callEvent.successEventbusName="getSignUpSucess"
        callEvent.failedEventbusName="getSignUpFailed"
        callEvent.apiUrl=constants.kBaseServerURL + callEvent.method;
        
        self.makeApiCall(callEvent)
        
    }*/
    
    func signIn(firstNameText: String, lastNameText: String , emailText: String , passwordText: String , confirmPasswordText: String){
        
        var strData = [String]()
        strData.append("fname=\(firstNameText)")
        strData.append("lname=\(lastNameText)")
        strData.append("email=\(emailText)")
        strData.append("password=\(passwordText)")
        strData.append("repeatpassword=\(confirmPasswordText)")
        let parameter = self.makeBodyString(strData)
        
        let callEvent = ApiCallEvent()
        callEvent.method = "/signup"
        callEvent.resultClass = "signingin"
        callEvent.body = parameter
        //callEvent.successEventbusName = ""
        //callEvent.failedEventbusName = ""
        
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makePostApiCall(callEvent)
    }
    
    func getMessages(id: Int, offset: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-messages/\(id)/\(offset)"
        callEvent.resultClass = "MessageVM"
        callEvent.successEventbusName = "getMessagesSuccess"
        callEvent.failedEventbusName = "getMessagesFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func deleteComment(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/comment/delete/\(id)"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "onSuccessDeleteComment"
        callEvent.failedEventbusName = "onFailureDeleteComment"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func getPostById(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-post/\(id)"
        callEvent.resultClass = "PostModelById"
        callEvent.successEventbusName = "postByIdLoadSuccess"
        callEvent.failedEventbusName = "postByIdLoadFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func saveSellProduct(producttxt :String,sellingtext :String, categoryId:String, conditionType:String, pricetxt : String, imageCollection: [AnyObject]){
        
        let callEvent=ApiCallEvent()
        callEvent.method="/api/post/new"
        callEvent.resultClass="SellVm"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        callEvent.successEventbusName = "productSavedSuccess"
        callEvent.failedEventbusName = "productSavedFailed"
        
        Alamofire.upload(
            .POST,
            callEvent.apiUrl,
            multipartFormData: { multipartFormData in
                var index = 0
                
                for _image in imageCollection {
                    if let _ = _image as? String {
                    } else {
                        if let image: UIImage? = _image as? UIImage {
                            if (image != nil) {
                                multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(imageCollection[0] as! UIImage)!, name: "image\(index)", fileName: "upload.jpg", mimeType:"jpg")
                                index++
                            }
                        }
                    }
                }

                
                //multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(imageCollection[0] as! UIImage)!, name: "image", fileName: "upload.jpg", mimeType:"jpg")
                multipartFormData.appendBodyPart(data: categoryId.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"catId")
                multipartFormData.appendBodyPart(data: sellingtext.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"title")
                multipartFormData.appendBodyPart(data:producttxt.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"body")
                multipartFormData.appendBodyPart(data: pricetxt.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"price")
                multipartFormData.appendBodyPart(data:conditionType.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"conditionType")
                multipartFormData.appendBodyPart(data: "ios".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"deviceType")
                
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success( _, _, _):
                    SwiftEventBus.post(callEvent.successEventbusName, sender: "")
                    break
                case .Failure( _):
                    SwiftEventBus.post(callEvent.failedEventbusName, sender: "")
                    break
                }
            }
        )
        
    }

    func postMessage(id: String, message: String){
        
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/message/new"
        callEvent.resultClass = "MessageDetailVM"
        //callEvent.body = parameter
        //callEvent.successEventbusName = "postMessageSuccess"
        //callEvent.failedEventbusName = "postMessageFailed"
        callEvent.apiUrl = constants.kBaseServerURL + callEvent.method
        
        Alamofire.upload(
            .POST,
            callEvent.apiUrl,
            multipartFormData: { multipartFormData in
                //multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(imageData)!, name: "image", fileName: "upload.jpg", mimeType:"jpg")
                multipartFormData.appendBodyPart(data: id.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"conversationId")
                multipartFormData.appendBodyPart(data: message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"body")
                multipartFormData.appendBodyPart(data: "true".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"system")
                multipartFormData.appendBodyPart(data:"ios".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"deviceType")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success( _, _, _): break
                case .Failure( _): break
                }
            }
        )
    
    }
    
    func makeApiCall(arg: ApiCallEvent) {
        
        NSLog("makeApiCall")
        
        let request: NSMutableURLRequest = NSMutableURLRequest()
        let url = arg.apiUrl + "?key=\(StringUtil.encode(constants.sessionId))"
        
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        NSLog("sending string %@", url)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                SwiftEventBus.post(arg.failedEventbusName, sender: error)
            } else {
                let result = self.handleResult(data!, arg: arg)
                SwiftEventBus.post(arg.successEventbusName, sender: result)
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

    func handleResult(data: NSData, arg: ResponseVM) {
        let _: AutoreleasingUnsafeMutablePointer<NSError?> = nil
        let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        //NSLog("responseString %@", responseString)
        let result: AnyObject = self.parseStr(arg.resultClass, inputStr: responseString as String)
        SwiftEventBus.post("getUserLoggedIn", sender: result)
    }
    
    func handleResult(data: NSData, arg: ApiCallEvent) -> AnyObject {
        let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        //NSLog("responseString %@", responseString)
        if (responseString == "") {
            return ""
        }
        let result: AnyObject = self.parseStr(arg.resultClass, inputStr: responseString as String)
        return result
    }
    
    func parseStr(cName: String, inputStr: String) -> AnyObject {
        var result: AnyObject = NSNull();
        
        switch cName {
            case "CategoryModel": result = Mapper<CategoryModel>().mapArray(inputStr)!
            case "UserInfoModel": result = Mapper<UserInfoModel>().map(inputStr)!
            case "UserInfoVM": result = Mapper<UserInfoVM>().map(inputStr)!
            case "UserVM": result = Mapper<UserVM>().mapArray(inputStr)!
            case "ResponseVM": result = Mapper<ResponseVM>().map(inputStr)!
            case "PostModel": result = Mapper<PostModel>().mapArray(inputStr)!
            case "PostModelById": result = Mapper<PostModel>().map(inputStr)!
            case "PostCatModel": result = Mapper<PostCatModel>().mapArray(inputStr)!
            case "LocationModel": result = Mapper<LocationModel>().mapArray(inputStr)!
            case "UserVMById": result = Mapper<UserInfoVM>().map(inputStr)!
            case "ConversationVM": result = Mapper<ConversationVM>().mapArray(inputStr)!
            case "MessageVM": result = Mapper<MessageVM>().map(inputStr)!
            case "MessageDetailVM": result = Mapper<MessageDetailVM>().map(inputStr)!
            case "SellVm": result = Mapper<SellVM>().map(inputStr)!
            case "ActivityVM": result = Mapper<ActivityVM>().mapArray(inputStr)!
            case "String": result = inputStr
            default: NSLog("calling default object resolver")
        }
        return result
    }
    
    class func toJson(res: CommentVM) -> String {
        var JSONString = ""
        JSONString = Mapper<CommentVM>().toJSONString(res, prettyPrint: true)!
        //NSLog("inside tojson")
        let str = CFURLCreateStringByAddingPercentEscapes(
            nil,
            JSONString,
            nil,
            "!*'();:@&=+$,/?%#[]",
            CFStringBuiltInEncodings.UTF8.rawValue
        )
        //NSLog(JSONString)
        //remeber to do urlescape on argPayload too
        //return JSONString
        
        return str as String
    }
    
    func makeBodyString(strData:[String]) -> String {
        var result = ""
        for myStr in strData {
            if (result == "") {
                result = myStr
            } else {
                result += "&\(myStr)"
            }
        }
        return result
    }
}