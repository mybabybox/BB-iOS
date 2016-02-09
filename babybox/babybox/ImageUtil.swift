//
//  ImageUtil.swift
//  babybox
//
//  Created by Mac on 05/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Kingfisher

class ImageUtil {
    
    static let REVIEW_THUMBNAIL_MAX_WIDTH = 128;
    static let PREVIEW_THUMBNAIL_MAX_HEIGHT = 128;
    
    static let GALLERY_PICTURE = 2;
    static let REQUEST_CAMERA = 1;
    
    static let IMAGE_UPLOAD_MAX_WIDTH = 1024;
    static let IMAGE_UPLOAD_MAX_HEIGHT = 1024;
    
    static let IMAGE_COMPRESS_QUALITY = 80;
    
    static let COVER_IMAGE_BY_ID_URL = constants.imagesBaseURL + "/image/get-cover-image-by-id/"
    
    static let THUMBNAIL_COVER_IMAGE_BY_ID_URL = constants.imagesBaseURL + "/image/get-thumbnail-cover-image-by-id/"
    static let PROFILE_IMAGE_BY_ID_URL = constants.imagesBaseURL + "/image/get-profile-image-by-id/"
    static let THUMBNAIL_PROFILE_IMAGE_BY_ID_URL = constants.imagesBaseURL + "/image/get-thumbnail-profile-image-by-id/"
    static let POST_IMAGE_BY_ID_URL = constants.imagesBaseURL + "/image/get-post-image-by-id/"
    static let ORIGINAL_POST_IMAGE_BY_ID_URL = constants.imagesBaseURL + "/image/get-original-post-image-by-id/"
    static let MINI_POST_IMAGE_BY_ID_URL = constants.imagesBaseURL + "/image/get-mini-post-image-by-id/"
    static let MESSAGE_IMAGE_BY_ID_URL = constants.imagesBaseURL + "/image/get-message-image-by-id/";
    static let ORIGINAL_MESSAGE_IMAGE_BY_ID_URL = constants.imagesBaseURL + "/image/get-original-message-image-by-id/"
    static let MINI_MESSAGE_IMAGE_BY_ID_URL = constants.imagesBaseURL + "/image/get-mini-message-image-by-id/"
    
    static let IMAGE_FOLDER_NAME = constants.APP_NAME
    //static let IMAGE_FOLDER_PATH = Environment.getExternalStorageDirectory() + "/" + IMAGE_FOLDER_NAME
    //static let CAMERA_IMAGE_TEMP_PATH = IMAGE_FOLDER_PATH + "/" + "camera.jpg"

    
    static var imageUtil: ImageUtil = ImageUtil()
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func getProductItemCellSize(width: CGFloat) -> CGSize {
        let availableWidthForCells:CGFloat = width - 15
        let cellWidth :CGFloat = availableWidthForCells / 2
        let cellHeight = cellWidth + 35
        return CGSizeMake(cellWidth, cellHeight)
    }
    
    static func displayButtonRoundBorder(view: UIView) {
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
    }
    
    /*func setCircularImgStyle(view: UIView) {
        view.layer.cornerRadius = view.frame.height/2
        view.layer.masksToBounds = true
    }*/
    
    func displayCornerView(view: UIButton) {
        let color = UIColorFromRGB(0xFF76A4).CGColor
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = color
    }
    
    func displayCornerView(view: UIView) {
        let color = UIColorFromRGB(0xFF76A4).CGColor
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = color
    }
    
    func getPinkColor() -> UIColor {
        let rgbValue: UInt = 0xFF76A4
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    static func displayImage(url: String, view: UIImageView, centerCrop: Bool, noCahe: Bool) {
        let imageUrl  = NSURL(string: url)
        view.kf_setImageWithURL(imageUrl!,
            placeholderImage: nil,
            optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
    }
    
    static func displayCoverImage(id: Int, imageView: UIImageView) {
        displayImage(COVER_IMAGE_BY_ID_URL + String(id), view: imageView, centerCrop: true, noCahe: true)
    }
    
    static func displayThumbnailCoverImage(id: Int, imageView: UIImageView) {
        displayImage(THUMBNAIL_COVER_IMAGE_BY_ID_URL + String(id), view: imageView, centerCrop: true, noCahe: true)
    }
    
    // Profile image
    
    static func displayProfileImage(id: Int, imageView: UIImageView) {
        displayCircleImage(PROFILE_IMAGE_BY_ID_URL + String(id), view: imageView)
    }
    
    static func displayThumbnailProfileImage(id: Int, imageView: UIImageView) {
        displayCircleImage(THUMBNAIL_PROFILE_IMAGE_BY_ID_URL + String(id), view: imageView)
    }
    
    static func displayThumbnailProfileImage(id: Int, buttonView: UIButton) {
        displayCircleImage(THUMBNAIL_PROFILE_IMAGE_BY_ID_URL + String(id), view: buttonView)
    }
    
    // Post image
    
    static func displayPostImage(id: Int, imageView: UIImageView) {
        displayImage(POST_IMAGE_BY_ID_URL + String(id), view: imageView, centerCrop: false, noCahe: false)
    }
    
    static func displayOriginalPostImage(id: Int, imageView: UIImageView) {
        displayImage(ORIGINAL_POST_IMAGE_BY_ID_URL + String(id), view: imageView, centerCrop: false, noCahe: false)
    }
    
    static func displayMiniPostImage(id: Int, imageView: UIImageView) {
        displayImage(MINI_POST_IMAGE_BY_ID_URL + String(id), view: imageView, centerCrop: false, noCahe: false)
    }
    
    static func displayMessageImage(id: Int, imageView: UIImageView) {
        displayImage(MESSAGE_IMAGE_BY_ID_URL + String(id), view: imageView, centerCrop: false, noCahe: false)
    }
    
    static func displayOriginalMessageImage(id: Int, imageView: UIImageView) {
        displayImage(ORIGINAL_MESSAGE_IMAGE_BY_ID_URL + String(id), view: imageView, centerCrop: false, noCahe: false)
    }
    
    static func displayMiniMessageImage(id: Int, imageView: UIImageView) {
        displayImage(MINI_MESSAGE_IMAGE_BY_ID_URL + String(id), view: imageView, centerCrop: false, noCahe: false);
    }
    
    // Circle image
    static func displayCircleImage(url: String, view: UIImageView) {
        let imageUrl  = NSURL(string: url)
        view.kf_setImageWithURL(imageUrl!,
            placeholderImage: nil,
            optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
        view.layer.cornerRadius = view.frame.height/2
        view.layer.masksToBounds = true
    }
    
    static func displayCircleImage(url: String, view: UIButton) {
        let imageUrl  = NSURL(string: url)
        let imageData = NSData(contentsOfURL: imageUrl!)
        if (imageData != nil) {
            view.setImage(UIImage(data: imageData!), forState: UIControlState.Normal)
        }
        view.layer.cornerRadius = view.frame.height/2
        view.layer.masksToBounds = true
    }
    
    // Rounded image
    
    static func displayRoundedImage(url: String, imageView:UIImageView) {
        displayRoundedImage(url, imageView: imageView);
    }
    
    static func displayRoundedImage(url: String, imageView:UIImageView, centerCrop: Bool, noCahe: Bool) {
        displayRoundedImage(url, imageView: imageView);
    }
    
    static func displayRoundedImage(url: String, view: UIImageView) {
        let imageUrl  = NSURL(string: url)
        view.kf_setImageWithURL(imageUrl!,
            placeholderImage: nil,
            optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
    }
    
}