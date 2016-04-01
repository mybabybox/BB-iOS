//
//  ApiController.swift
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

    func loginByFacebook(authToken: String) {
        let url = Constants.BASE_URL + "/authenticate/mobile/facebook?access_token=\(authToken)"
        let callEvent = ApiCallEvent()
        callEvent.method = "/authenticate/mobile/facebook"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "loginReceivedSuccess"
        callEvent.failedEventbusName = "loginReceivedFailed"
        callEvent.apiUrl = url
        makePostApiCall(callEvent, appendSessionId: false)
    }
    
    func loginByEmail(userName: String, password: String) {
        let url = Constants.BASE_URL + "/login/mobile?email=\(userName)&password=\(password)"
        let callEvent = ApiCallEvent()
        callEvent.method = "/login/mobile"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "loginReceivedSuccess"
        callEvent.failedEventbusName = "loginReceivedFailed"
        callEvent.apiUrl = url
        makePostApiCall(callEvent, appendSessionId: false)
    }
    
    func signUp(email: String, fname: String, lname: String, password: String, repeatPassword: String){
        var strData = [String]()
        strData.append("fname=\(fname)")
        strData.append("lname=\(lname)")
        strData.append("email=\(email)")
        strData.append("password=\(password)")
        strData.append("repeatPassword=\(repeatPassword)")
        let parameter = self.makeBodyString(strData)
        
        let callEvent = ApiCallEvent()
        callEvent.method = "/signup"
        callEvent.resultClass = "String"
        callEvent.body = parameter
        callEvent.successEventbusName = "signUpSuccess"
        callEvent.failedEventbusName = "signUpFailed"
        
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makePostApiCall(callEvent)
    }
    
    func saveSignUpInfo(displayName: String, locationId: Int) {
        var strData = [String]()
        strData.append("parent_displayname=\(displayName)")
        strData.append("parent_location=\(locationId)")
        let parameter = self.makeBodyString(strData)
        
        let callEvent = ApiCallEvent()
        callEvent.method = "/saveSignupInfo"
        callEvent.resultClass = "String"
        callEvent.body = parameter
        callEvent.successEventbusName = "saveSignUpInfoSuccess"
        callEvent.failedEventbusName = "saveSignUpInfoFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makePostApiCall(callEvent)
    }
    
    func forgotPasswordRequest(emailAddress: String) {
        let url = Constants.BASE_URL + "/login/password/forgot?email=\(emailAddress)"
        let callEvent = ApiCallEvent()
        callEvent.method = "/login/password/forgot"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "forgotPasswordSuccess"
        callEvent.failedEventbusName = "forgotPasswordFailed"
        callEvent.apiUrl = url
        self.makeApiCall(callEvent)
    }
    
    func logoutUser() {
        let callEvent = ApiCallEvent()
        callEvent.method = "/logout"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "logoutSuccess"
        callEvent.failedEventbusName = "logoutFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func initNewUser() {
        let callEvent = ApiCallEvent()
        callEvent.method = "/init-new-user"
        callEvent.resultClass = "UserVM"
        callEvent.successEventbusName = "initNewUserSuccess"
        callEvent.failedEventbusName = "initNewUserFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
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
    
    func uploadUserProfileImage(profileImg: UIImage) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/image/upload-profile-photo"
        callEvent.resultClass = "String"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        callEvent.successEventbusName = "profileImgUploadSuccess"
        callEvent.failedEventbusName = "profileImgUploadFailed"
        let url = callEvent.apiUrl + "?key=\(StringUtil.encode(AppDelegate.getInstance().sessionId!))"
        
        let nsData = profileImg.lowestQualityJPEGNSData
        Alamofire.upload(
            .POST,
            url,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: nsData, name: "profile-photo", fileName: "upload.jpg", mimeType:"*")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    self.handleUploadResponse(upload, callEvent: callEvent)
                case .Failure(_):
                    SwiftEventBus.post(callEvent.failedEventbusName, sender: "")
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
    ///api/get-post-conversations/
    func getPostConversations(postId: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/get-post-conversations/\(postId)"
        callEvent.resultClass = "[ConversationVM]"
        callEvent.successEventbusName = "productConversationsSuccess"
        callEvent.failedEventbusName = "productConversationsFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }
    
    func editPost(postId: Int, title: String, body: String, catId: Int, conditionType:String, pricetxt : String) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/post/edit"
        callEvent.resultClass="String"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        callEvent.successEventbusName = "editProductSuccess"
        callEvent.failedEventbusName = "editProductFailed"
        let url = callEvent.apiUrl + "?key=\(StringUtil.encode(AppDelegate.getInstance().sessionId!))"
        Alamofire.upload(
            .POST,
            url,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(String(postId)), name :"id")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(String(catId)), name :"catId")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(title), name :"title")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(body), name :"body")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(pricetxt), name :"price")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(conditionType), name :"conditionType")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(Constants.DEVICE_TYPE), name :"deviceType")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    self.handleUploadResponse(upload, callEvent: callEvent)
                case .Failure(_):
                    SwiftEventBus.post(callEvent.failedEventbusName, sender: "")
                }
            }
        )
    }
    
    func newPost(title: String, body: String, catId: Int, conditionType:String, pricetxt : String, imageCollection: [AnyObject]) {
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
                                let nsData = image!.lowestQualityJPEGNSData
                                multipartFormData.appendBodyPart(data: nsData, name: "image\(index)", fileName: "upload.jpg", mimeType:"jpg")
                                index++
                            }
                        }
                    }
                }
                
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(String(catId)), name :"catId")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(title), name :"title")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(body), name :"body")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(pricetxt), name :"price")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(conditionType), name :"conditionType")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData("ios"), name :"deviceType")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    self.handleUploadResponse(upload, callEvent: callEvent)
                case .Failure(_):
                    SwiftEventBus.post(callEvent.failedEventbusName, sender: "")
                }
            }
        )
    }
    
    func deletePost(id: Int) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/post/delete/\(id)"
        callEvent.resultClass = "String"
        callEvent.successEventbusName = "deletePostSuccess"
        callEvent.failedEventbusName = "deletePostFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        self.makeApiCall(callEvent)
    }

    func newMessage(id: Int, message: String, system: Bool) {
        newMessage(id, message: message, image: nil, system: system)
    }
    
    func newMessage(id: Int, message: String, image: UIImage?, system: Bool) {
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
                if image != nil {
                    let index = 0
                    let nsData = image!.lowestQualityJPEGNSData
                    multipartFormData.appendBodyPart(data: nsData, name:  "image\(index)", fileName: "upload.jpg", mimeType:"jpg")
                }
                
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(String(id)), name :"conversationId")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(message), name :"body")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData(String(system)), name :"system")
                multipartFormData.appendBodyPart(data: StringUtil.toEncodedData("ios"), name :"deviceType")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    self.handleUploadResponse(upload, callEvent: callEvent)
                case .Failure(_):
                    SwiftEventBus.post(callEvent.failedEventbusName, sender: "")
                }
            }
        )
    }
    
    //@POST("/api/user-notification-settings/edit")
    func editUserNotificationSettings(settingsVM: SettingVM) {
        let callEvent = ApiCallEvent()
        callEvent.method = "/api/user-notification-settings/edit"
        callEvent.resultClass = "UserVM"
        callEvent.successEventbusName = "editNotificationSettingsSuccess"
        callEvent.failedEventbusName = "editNotificationSettingsFailed"
        callEvent.apiUrl = Constants.BASE_URL + callEvent.method
        let url = callEvent.apiUrl + "?key=\(StringUtil.encode(AppDelegate.getInstance().sessionId!))"
        
        NSLog("makePostApiCall")
        
        var strData = [String]()
        strData.append("emailNewPost=\(settingsVM.emailNewPost)")
        strData.append("emailNewConversation=\(settingsVM.emailNewConversation)")
        strData.append("emailNewComment=\(settingsVM.emailNewComment)")
        strData.append("emailNewPromotion=\(settingsVM.emailNewPromotion)")
        strData.append("pushNewConversion=\(settingsVM.pushNewConversion)")
        strData.append("pushNewComment=\(settingsVM.pushNewConversion)")
        strData.append("pushNewFollow=\(settingsVM.pushNewConversion)")
        strData.append("pushNewFeedback=\(settingsVM.pushNewConversion)")
        strData.append("pushNewPromotions=\(settingsVM.pushNewConversion)")
        let parameter = self.makeBodyString(strData)
        
        
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSLog("sending string %@", url)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            self.handleApiResponse(callEvent, data: data, response: response, error: error)
        })
        task.resume()
        
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
            self.handleApiResponse(arg, data: data, response: response, error: error)
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
            self.handleApiResponse(arg, data: data, response: response, error: error)
        })
        task.resume()
    }
    
    func handleApiResponse(arg: ApiCallEvent, data: NSData?, response: NSURLResponse?, error: NSError?) {
        if error != nil {
            SwiftEventBus.post(arg.failedEventbusName, sender: error)
        } else {
            let result: AnyObject?
            do {
                result = try self.handleApiResult(data!, arg: arg)
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == Constants.HTTP_STATUS_OK {
                        SwiftEventBus.post(arg.successEventbusName, sender: result)
                    } else {
                        SwiftEventBus.post(arg.failedEventbusName, sender: result)
                    }
                }
            } catch {
                SwiftEventBus.post(arg.failedEventbusName, sender: nil)
            }
        }
    }
    
    func handleApiResult(data: NSData, arg: ApiCallEvent) throws -> AnyObject {
        let responseString: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        if responseString.isEmpty {
            return ""
        }
        let result: AnyObject = try self.parseStr(arg.resultClass, inputStr: responseString as String)
        return result
    }
    
    func handleUploadResponse(upload: Request, callEvent: ApiCallEvent) {
        upload.responseJSON { response in
            switch response.result {
            case .Success:
                SwiftEventBus.post(callEvent.successEventbusName, sender: "")
            case .Failure(let error):
                SwiftEventBus.post(callEvent.failedEventbusName, sender: error)
            }
        }
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


