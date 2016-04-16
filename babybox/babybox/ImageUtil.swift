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
    
    static let REVIEW_THUMBNAIL_MAX_WIDTH = 128
    static let PREVIEW_THUMBNAIL_MAX_HEIGHT = 128
    
    static let GALLERY_PICTURE = 2
    static let REQUEST_CAMERA = 1
    
    static let IMAGE_UPLOAD_MAX_WIDTH = 1024
    static let IMAGE_UPLOAD_MAX_HEIGHT = 1024
    
    static let IMAGE_COMPRESS_QUALITY = 80
    
    static let IMAGE_DISPLAY_CROSS_FADE_DURATION = 0.5
    
    static let COVER_IMAGE_BY_ID_URL = Constants.BASE_IMAGE_URL + "/image/get-cover-image-by-id/"
    
    static let THUMBNAIL_COVER_IMAGE_BY_ID_URL = Constants.BASE_IMAGE_URL + "/image/get-thumbnail-cover-image-by-id/"
    static let PROFILE_IMAGE_BY_ID_URL = Constants.BASE_IMAGE_URL + "/image/get-profile-image-by-id/"
    static let THUMBNAIL_PROFILE_IMAGE_BY_ID_URL = Constants.BASE_IMAGE_URL + "/image/get-thumbnail-profile-image-by-id/"
    static let POST_IMAGE_BY_ID_URL = Constants.BASE_IMAGE_URL + "/image/get-post-image-by-id/"
    static let ORIGINAL_POST_IMAGE_BY_ID_URL = Constants.BASE_IMAGE_URL + "/image/get-original-post-image-by-id/"
    static let MINI_POST_IMAGE_BY_ID_URL = Constants.BASE_IMAGE_URL + "/image/get-mini-post-image-by-id/"
    static let MESSAGE_IMAGE_BY_ID_URL = Constants.BASE_IMAGE_URL + "/image/get-message-image-by-id/"
    static let ORIGINAL_MESSAGE_IMAGE_BY_ID_URL = Constants.BASE_IMAGE_URL + "/image/get-original-message-image-by-id/"
    static let MINI_MESSAGE_IMAGE_BY_ID_URL = Constants.BASE_IMAGE_URL + "/image/get-mini-message-image-by-id/"
   
    // Config
    
    // Default is no limit.
    static func setMaxDiskCacheSize(mb: UInt) {
        let cache = KingfisherManager.sharedManager.cache
        cache.maxDiskCacheSize = mb * 1024 * 1024
    }
    
    // Default is 1 week.
    static func setMaxCachePeriod(days: UInt) {
        let cache = KingfisherManager.sharedManager.cache
        cache.maxCachePeriodInSecond = NSTimeInterval(days * 24 * 60 * 60)
    }
    
    // URL helper
    
    static func getOriginalPostImageUrl(id: Int) -> NSURL {
        return NSURL(string: ORIGINAL_POST_IMAGE_BY_ID_URL + String(id))!
    }

    static func getOriginalMessageImageUrl(id: Int) -> NSURL {
        return NSURL(string: ViewUtil.urlAppendSessionId(ORIGINAL_MESSAGE_IMAGE_BY_ID_URL + String(id)))!
    }
    
    // Cover image
    
    static func displayMyThumbnailCoverImage(id: Int, imageView: UIImageView) {
        displayImage(THUMBNAIL_COVER_IMAGE_BY_ID_URL + String(id), view: imageView, optionsInfo: [KingfisherOptionsInfoItem.Options(.ForceRefresh)])
    }
    
    static func displayThumbnailCoverImage(id: Int, imageView: UIImageView) {
        displayImage(THUMBNAIL_COVER_IMAGE_BY_ID_URL + String(id), view: imageView, optionsInfo: [KingfisherOptionsInfoItem.Options(.ForceRefresh)])
    }

    // Profile image
    
    static func displayMyThumbnailProfileImage(id: Int, imageView: UIImageView) {
        displayCircleImage(THUMBNAIL_PROFILE_IMAGE_BY_ID_URL + String(id), view: imageView, optionsInfo: [KingfisherOptionsInfoItem.Options(.ForceRefresh)])
    }
    
    static func displayThumbnailProfileImage(id: Int, imageView: UIImageView) {
        displayCircleImage(THUMBNAIL_PROFILE_IMAGE_BY_ID_URL + String(id), view: imageView, optionsInfo: [KingfisherOptionsInfoItem.Options(.ForceRefresh)])
    }
    
    // Post image
    
    static func displayPostImage(id: Int, imageView: UIImageView) {
        displayImage(POST_IMAGE_BY_ID_URL + String(id), view: imageView)
    }
    
    static func displayOriginalPostImage(id: Int, imageView: UIImageView) {
        displayImage(ORIGINAL_POST_IMAGE_BY_ID_URL + String(id), view: imageView)
    }
    
    static func displayMiniPostImage(id: Int, imageView: UIImageView) {
        displayImage(MINI_POST_IMAGE_BY_ID_URL + String(id), view: imageView)
    }
    
    static func displayMessageImage(id: Int, imageView: UIImageView) {
        displayImage(ViewUtil.urlAppendSessionId(MESSAGE_IMAGE_BY_ID_URL + String(id)), view: imageView)
    }
    
    static func displayOriginalMessageImage(id: Int, imageView: UIImageView) {
        displayImage(ViewUtil.urlAppendSessionId(ORIGINAL_MESSAGE_IMAGE_BY_ID_URL + String(id)), view: imageView)
    }
    
    static func displayMiniMessageImage(id: Int, imageView: UIImageView) {
        displayImage(ViewUtil.urlAppendSessionId(MINI_MESSAGE_IMAGE_BY_ID_URL + String(id)), view: imageView)
    }
    
    // Regular image
    static func displayImage(url: String, view: UIImageView, optionsInfo: [KingfisherOptionsInfoItem]? = nil) {
        let imageUrl  = NSURL(string: url)
        
        var allOptionsInfo: [KingfisherOptionsInfoItem] = [
            .Transition(ImageTransition.Fade(IMAGE_DISPLAY_CROSS_FADE_DURATION))
        ]
        
        if optionsInfo != nil {
            allOptionsInfo.appendContentsOf(optionsInfo!)
        }
        
        view.kf_setImageWithURL(imageUrl!,
            placeholderImage: nil,
            optionsInfo: allOptionsInfo)
    }

    // Circle image
    static func displayCircleImage(url: String, view: UIImageView, optionsInfo: [KingfisherOptionsInfoItem]? = nil) {
        let imageUrl = NSURL(string: url)
        
        var allOptionsInfo: [KingfisherOptionsInfoItem] = [
            .Transition(ImageTransition.Fade(IMAGE_DISPLAY_CROSS_FADE_DURATION))
        ]
        
        if optionsInfo != nil {
            allOptionsInfo.appendContentsOf(optionsInfo!)
        }
        
        view.kf_setImageWithURL(imageUrl!,
            placeholderImage: nil,
            optionsInfo: allOptionsInfo)
        view.layer.cornerRadius = view.frame.height/2
        view.layer.masksToBounds = true
    }
    
    // Rounded image
    
    static func displayRoundedImage(url: String, imageView:UIImageView) {
        displayRoundedImage(url, imageView: imageView)
    }
    
    static func displayRoundedImage(url: String, imageView:UIImageView, centerCrop: Bool, noCahe: Bool) {
        displayRoundedImage(url, imageView: imageView)
    }
    
    static func displayRoundedImage(url: String, view: UIImageView, optionsInfo: [KingfisherOptionsInfoItem]? = nil) {
        let imageUrl = NSURL(string: url)
        
        var allOptionsInfo: [KingfisherOptionsInfoItem] = [
            .Transition(ImageTransition.Fade(IMAGE_DISPLAY_CROSS_FADE_DURATION))
        ]
        
        if optionsInfo != nil {
            allOptionsInfo.appendContentsOf(optionsInfo!)
        }
        
        view.kf_setImageWithURL(imageUrl!,
            placeholderImage: nil,
            optionsInfo: allOptionsInfo)
        view.layer.cornerRadius = Constants.DEFAULT_CORNER_RADIUS
        view.layer.masksToBounds = true
    }
    
    static func getProductImageUrl(imageId: String) -> NSURL {
        return NSURL(string: ORIGINAL_POST_IMAGE_BY_ID_URL + imageId)!
    }
    
    //
    // Obsolete: see UIImageExtension.swift
    //
    static func compressImage(image:UIImage) -> NSData {
        // Reducing file size to a 10th
        
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        let maxHeight : CGFloat = CGFloat(IMAGE_UPLOAD_MAX_HEIGHT)
        let maxWidth : CGFloat = CGFloat(IMAGE_UPLOAD_MAX_WIDTH)
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = CGFloat(IMAGE_COMPRESS_QUALITY / 100)
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
                compressionQuality = 1;
            }
        }
        
        let rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.drawInRect(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img, compressionQuality);
        UIGraphicsEndImageContext();
        return imageData!;
    }
}