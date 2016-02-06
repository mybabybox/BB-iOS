//
//  ImageUtil.swift
//  babybox
//
//  Created by Mac on 05/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class ImageUtil {
    
    static let REVIEW_THUMBNAIL_MAX_WIDTH = 128;
    static let PREVIEW_THUMBNAIL_MAX_HEIGHT = 128;
    
    static let GALLERY_PICTURE = 2;
    static let REQUEST_CAMERA = 1;
    
    static let IMAGE_UPLOAD_MAX_WIDTH = 1024;
    static let IMAGE_UPLOAD_MAX_HEIGHT = 1024;
    
    static let IMAGE_COMPRESS_QUALITY = 80;
    
    static let imageUrl = ApiControlller.BASE_URL
    static let COVER_IMAGE_BY_ID_URL = ApiControlller.BASE_URL + "/image/get-cover-image-by-id/"
    
    static let THUMBNAIL_COVER_IMAGE_BY_ID_URL = ApiControlller.BASE_URL + "/image/get-thumbnail-cover-image-by-id/"
    static let PROFILE_IMAGE_BY_ID_URL = ApiControlller.BASE_URL + "/image/get-profile-image-by-id/"
    static let THUMBNAIL_PROFILE_IMAGE_BY_ID_URL = ApiControlller.BASE_URL + "/image/get-thumbnail-profile-image-by-id/"
    static let POST_IMAGE_BY_ID_URL = ApiControlller.BASE_URL + "/image/get-post-image-by-id/"
    static let ORIGINAL_POST_IMAGE_BY_ID_URL = ApiControlller.BASE_URL + "/image/get-original-post-image-by-id/"
    static let MINI_POST_IMAGE_BY_ID_URL = ApiControlller.BASE_URL + "/image/get-mini-post-image-by-id/"
    static let MESSAGE_IMAGE_BY_ID_URL = ApiControlller.BASE_URL + "/image/get-message-image-by-id/";
    static let ORIGINAL_MESSAGE_IMAGE_BY_ID_URL = ApiControlller.BASE_URL + "/image/get-original-message-image-by-id/"
    static let MINI_MESSAGE_IMAGE_BY_ID_URL = ApiControlller.BASE_URL + "/image/get-mini-message-image-by-id/"
    
    static let IMAGE_FOLDER_NAME = ApiControlller.APP_NAME
    //static let IMAGE_FOLDER_PATH = Environment.getExternalStorageDirectory() + "/" + IMAGE_FOLDER_NAME
    //static let CAMERA_IMAGE_TEMP_PATH = IMAGE_FOLDER_PATH + "/" + "camera.jpg"

    

    
    
}