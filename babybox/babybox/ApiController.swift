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
    
    func getCategories() {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-categories"
        callEvent.resultClass = "[CategoryVM]"
        callEvent.successEventbusName = "categoriesReceivedSuccess"
        callEvent.failedEventbusName = "categoriesReceivedFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    //Get the post of type HOME_FOLLOWING
    func getHomeExploreFeed(offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-home-explore-feed/\(offset)"
        callEvent.resultClass = "[PostVMLite]"
        callEvent.successEventbusName = "homeExploreFeedLoadSuccess"
        callEvent.failedEventbusName = "homeExploreFeedLoadFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func getHomeFollowingFeed(offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-home-following-feed/\(offset)"
        callEvent.resultClass = "[PostVMLite]"
        callEvent.successEventbusName = "homeFollowingFeedLoadSuccess"
        callEvent.failedEventbusName = "homeFollowingFeedLoadFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func getUserInfo() {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-user-info"
        callEvent.resultClass = "UserVM"
        callEvent.successEventbusName = "userInfoSuccess"
        callEvent.failedEventbusName = "userInfoFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method      //append logged in user id to get the logged in user details.
        
        self.makeApiCall(callEvent)
    }
    
    func getUser(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-user/\(id)"
        callEvent.resultClass = "UserVM"
        callEvent.successEventbusName = "userByIdSuccess"
        callEvent.failedEventbusName = "userByIdFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getUserActivities(offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-activities/\(offset)"
        callEvent.resultClass = "[ActivityVM]"
        callEvent.successEventbusName = "userActivitiesSuccess"
        callEvent.failedEventbusName = "userActivitiesFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
        
    }
    
    func likePost(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/like-post/\(id)"
        callEvent.resultClass = "String"
        //callEvent.successEventbusName = ""
        //callEvent.failedEventbusName = ""
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func unlikePost(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/unlike-post/\(id)"
        callEvent.resultClass = "String"
        //callEvent.successEventbusName = ""
        //callEvent.failedEventbusName = ""
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func getProductDetails(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-post/\(id)"
        callEvent.resultClass = "PostVM"
        callEvent.successEventbusName = "productDetailsReceivedSuccess"
        callEvent.failedEventbusName = "productDetailsReceivedFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }

    func soldPost(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/sold-post/\(id)"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "soldPostSuccess"
        callEvent.failedEventbusName = "soldPostFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }

    func followUser(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/follow-user/\(id)"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "followUserSuccess"
        callEvent.failedEventbusName = "followUserFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func unfollowUser(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/unfollow-user/\(id)"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "unfollowUserSuccess"
        callEvent.failedEventbusName = "unfollowUserFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func postComment(id: Int, comment: String){
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
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makePostApiCall(callEvent)
    }

    func loginByFacebook(authToken: String) -> Bool {
        let url = Constants.BASE_URL + "/authenticate/mobile/facebook?access_token=\(authToken)"
        let callEvent = ApiCallEvent()
        callEvent.method = "/authenticate/mobile/facebook"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "loginReceivedSuccess"
        callEvent.failedEventbusName = "loginReceivedFailed"
        callEvent.apiUrl = url
        
        makePostApiCall(callEvent, appendSessionId: false)
        
        return true
    }
    
    func loginByEmail(userName: String, password: String) -> Bool {
        
        let url = Constants.BASE_URL + "/login/mobile?email=\(userName)&password=\(password)"
        
        let callEvent = ApiCallEvent()
        callEvent.method = "/login/mobile"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "loginReceivedSuccess"
        callEvent.failedEventbusName = "loginReceivedFailed"
        callEvent.apiUrl = url
        
        makePostApiCall(callEvent, appendSessionId: false)
        
        return true
    }
    
    func forgotPasswordRequest(emailAddress: String) -> Bool {
        let url = Constants.BASE_URL + "/login/password/forgot?email=\(emailAddress)"
        
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
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    //Categories products filter APIs calls
    func getCategoryPopularFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-category-popular-feed/\(id)/ALL/\(offset)"
        callEvent.resultClass = "[PostVMLite]"
        callEvent.successEventbusName = "categoryPopularFeedLoadSuccess"
        callEvent.failedEventbusName = "categoryPopularFeedLoadFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getCategoryNewestFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-category-newest-feed/\(id)/ALL/\(offset)"
        callEvent.resultClass = "[PostVMLite]"
        callEvent.successEventbusName = "categoryNewestFeedLoadSuccess"
        callEvent.failedEventbusName = "categoryNewestFeedLoadFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getCategoryPriceLowHighFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-category-price-low-high-feed/\(id)/ALL/\(offset)"
        callEvent.resultClass = "[PostVMLite]"
        callEvent.successEventbusName = "categoryPriceLowHighFeedLoadSuccess"
        callEvent.failedEventbusName = "categoryPriceLowHighFeedLoadFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getCategoryPriceHighLowFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-category-price-high-low-feed/\(id)/ALL/\(offset)"
        callEvent.resultClass = "[PostVMLite]"
        callEvent.successEventbusName = "categoryPriceHighLowFeedLoadSuccess"
        callEvent.failedEventbusName = "categoryPriceHighLowFeedLoadFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getUserPostedFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-user-posted-feed/\(id)/\(offset)"
        callEvent.resultClass = "[PostVMLite]"
        callEvent.successEventbusName = "userPostedFeedLoadSuccess"
        callEvent.failedEventbusName = "userPostedFeedLoadFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getUserLikedFeed(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-user-liked-feed/\(id)/\(offset)"
        callEvent.resultClass = "[PostVMLite]"
        callEvent.successEventbusName = "userLikedFeedLoadSuccess"
        callEvent.failedEventbusName = "userLikedFeedLoadFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getUserFollowings(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-followings/\(id)/\(offset)"
        callEvent.resultClass = "[UserVMLite]"
        callEvent.successEventbusName = "userFollowersFollowingsSuccess"
        callEvent.failedEventbusName = "userFollowersFollowingsFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getUserFollowers(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-followers/\(id)/\(offset)"
        callEvent.resultClass = "[UserVMLite]"
        callEvent.successEventbusName = "userFollowersFollowingsSuccess"
        callEvent.failedEventbusName = "userFollowersFollowingsFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getDistricts() {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-districts"
        callEvent.resultClass = "[LocationVM]"
        callEvent.successEventbusName = "getDistrictsSuccess"
        callEvent.failedEventbusName = "getDistrictsFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }

    func getCountries() {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-countries"
        callEvent.resultClass = "[CountryVM]"
        callEvent.successEventbusName = "getCountriesSuccess"
        callEvent.failedEventbusName = "getCountriesFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
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
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makePostApiCall(callEvent)
    }
    
    func uploadUserProfileImg(profileImg: UIImage) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/image/upload-profile-photo"
        callEvent.resultClass = "String"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        callEvent.successEventbusName = "profileImgUploadSuccess"
        callEvent.failedEventbusName = "profileImgUploadFailed"
        let url = callEvent.apiUrl + "?key=\(StringUtil.encode(AppDelegate.getInstance().sessionId!))"
        Alamofire.upload(
            .POST,
            url,
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
    
    func getConversations(offSet: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-user-conversations/\(offSet)"
        callEvent.resultClass = "[ConversationVM]"
        callEvent.successEventbusName = "getConversationsSuccess"
        callEvent.failedEventbusName = "getConversationsFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func getConversation(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-conversation/\(id)"
        callEvent.resultClass = "ConversationVM"
        callEvent.successEventbusName = "getConversationSuccess"
        callEvent.failedEventbusName = "getConversationFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func openConversation(postId: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/open-conversation/\(postId)"
        callEvent.resultClass = "ConversationVM"
        callEvent.successEventbusName = "openConversationSuccess"
        callEvent.failedEventbusName = "openConversationFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func deleteConversation(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/delete-conversation/\(id)"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "deleteConversationSuccess"
        callEvent.failedEventbusName = "deleteConversationFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    /*func signup(){
        let callEvent=ApiCallEvent()
        callEvent.method="/signup"
        callEvent.resultClass="String"
        callEvent.successEventbusName="getSignUpSucess"
        callEvent.failedEventbusName="getSignUpFailed"
        callEvent.apiUrl=Constants.BASE_URL + callEvent.method
        
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
        
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makePostApiCall(callEvent)
    }
    
    func getMessages(id: Int, offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-messages/\(id)/\(offset)"
        callEvent.resultClass = "MessageResponseVM"
        callEvent.successEventbusName = "getMessagesSuccess"
        callEvent.failedEventbusName = "getMessagesFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func deleteComment(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/comment/delete/\(id)"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "onSuccessDeleteComment"
        callEvent.failedEventbusName = "onFailureDeleteComment"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        
        self.makeApiCall(callEvent)
    }
    
    func getPostById(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-post/\(id)"
        callEvent.resultClass = "PostVM"
        callEvent.successEventbusName = "postByIdLoadSuccess"
        callEvent.failedEventbusName = "postByIdLoadFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getNotificationCounter() {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/notification-counter"
        callEvent.resultClass = "NotificationCounterVM"
        callEvent.successEventbusName = "loadNotificationSuccess"
        callEvent.failedEventbusName = "loadNotificationFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func getRecommendedSellersFeed(offset: Int64) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-recommended-sellers-feed/\(offset)"
        callEvent.resultClass = "[SellerVM]"
        callEvent.successEventbusName = "recommendedSellerSuccess"
        callEvent.failedEventbusName = "recommendedSellerFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func newProduct(title: String, body: String, catId: Int, conditionType:String, pricetxt : String, imageCollection: [AnyObject]) {
        
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/post/new"
        callEvent.resultClass="NewPostVM"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        callEvent.successEventbusName = "newProductSuccess"
        callEvent.failedEventbusName = "newProductFailed"
        let url = callEvent.apiUrl + "?key=\(StringUtil.encode(AppDelegate.getInstance().sessionId!))"
        Alamofire.upload(
            .POST,
            url,
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
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(String(catId)), name :"catId")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(title), name :"title")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(body), name :"body")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(pricetxt), name :"price")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(conditionType), name :"conditionType")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData("ios"), name :"deviceType")
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

    func newMessage(id: Int, message: String, imagePath: AnyObject) {
        newMessage(id, message: message, system: false, imagePath: imagePath)
    }
    
    func newMessage(id: Int, message: String, system: Bool, imagePath: AnyObject) {
        
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/message/new"
        callEvent.resultClass = "MessageVM"
        callEvent.successEventbusName = "newMessageSuccess"
        callEvent.failedEventbusName = "newMessageFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        let url = callEvent.apiUrl + "?key=\(StringUtil.encode(AppDelegate.getInstance().sessionId!))"
        Alamofire.upload(
            .POST,
            url,
            multipartFormData: { multipartFormData in
                if let _ = imagePath as? String {
                } else {
                    let index = 0
                    multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(imagePath as! UIImage)!, name:  "image\(index)", fileName: "upload.jpg", mimeType:"jpg")
                }
                
                //multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(imageData)!, name: "image", fileName: "upload.jpg", mimeType:"jpg")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(String(id)), name :"conversationId")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(message), name :"body")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(String(system)), name :"system")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData("ios"), name :"deviceType")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success( _, _, _):
                    SwiftEventBus.post(callEvent.successEventbusName, sender: "")
                    break
                case .Failure( _):
                    SwiftEventBus.post(callEvent.failedEventbusName, sender:"")
                    break
                }
            }
        )
    }
    
    func makeApiCall(arg: ApiCallEvent) {
        
        NSLog("makeApiCall")
        
        let request: NSMutableURLRequest = NSMutableURLRequest()
        let url = arg.apiUrl + "?key=\(StringUtil.encode(AppDelegate.getInstance().sessionId!))"
        
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        NSLog("sending string %@", url)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                SwiftEventBus.post(arg.failedEventbusName, sender: error)
            } else {
                let result: AnyObject?
                do {
                    result = try self.handleResult(data!, arg: arg)
                    SwiftEventBus.post(arg.successEventbusName, sender: result)
                } catch {
                    SwiftEventBus.post(arg.failedEventbusName, sender: nil)
                }
            }
        })
        task.resume()
    }

    func makePostApiCall(arg: ApiCallEvent) {
        makePostApiCall(arg, appendSessionId: true)
    }
    
    func makePostApiCall(arg: ApiCallEvent, appendSessionId: Bool) {
        NSLog("makePostApiCall")
        
        let request: NSMutableURLRequest = NSMutableURLRequest()
        var url = arg.apiUrl
        if appendSessionId {
            url += "?key=\(StringUtil.encode(AppDelegate.getInstance().sessionId!))"
        }
        
        request.URL = NSURL(string: url)
        request.HTTPMethod = "POST"
        
        if (arg.body != "") {
            request.HTTPBody = arg.body.dataUsingEncoding(NSUTF8StringEncoding)
        }
        NSLog("sending string %@", url)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                SwiftEventBus.post(arg.failedEventbusName, sender: error)
            } else {
                let result: AnyObject?
                do {
                    result = try self.handleResult(data!, arg: arg)
                    SwiftEventBus.post(arg.successEventbusName, sender: result)
                } catch {
                    SwiftEventBus.post(arg.failedEventbusName, sender: nil)
                }
            }
        })  
        task.resume()
    }
    
    func handleResult(data: NSData, arg: ApiCallEvent) throws -> AnyObject {
        let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        if (responseString == "") {
            return ""
        }
        let result: AnyObject = try self.parseStr(arg.resultClass, inputStr: responseString as String)
        return result
    }
    
    func parseStr(cName: String, inputStr: String) throws -> AnyObject {
        var result: AnyObject = NSNull()
        
        switch cName {
        case "[CategoryVM]": result = Mapper<CategoryVM>().mapArray(inputStr)!
        case "[CountryVM]": result = Mapper<CountryVM>().mapArray(inputStr)!
        case "[LocationVM]": result = Mapper<LocationVM>().mapArray(inputStr)!
        case "[UserVMLite]": result = Mapper<UserVMLite>().mapArray(inputStr)!
        case "UserVM": result = Mapper<UserVM>().map(inputStr)!
        case "[PostVMLite]": result = Mapper<PostVMLite>().mapArray(inputStr)!
        case "PostVM": result = Mapper<PostVM>().map(inputStr)!
        case "[ConversationVM]": result = Mapper<ConversationVM>().mapArray(inputStr)!
        case "ConversationVM": result = Mapper<ConversationVM>().map(inputStr)!
        case "MessageResponseVM": result = Mapper<MessageResponseVM>().map(inputStr)!
        case "MessageVM": result = Mapper<MessageVM>().map(inputStr)!
        case "NewPostVM": result = Mapper<NewPostVM>().map(inputStr)!
        case "[ActivityVM]": result = Mapper<ActivityVM>().mapArray(inputStr)!
        case "NotificationCounterVM": result = Mapper<NotificationCounterVM>().map(inputStr)!
        case "[SellerVM]": result = Mapper<SellerVM>().mapArray(inputStr)!
        case "String": result = inputStr
        default: NSLog("calling default object resolver")
        }
        return result
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
