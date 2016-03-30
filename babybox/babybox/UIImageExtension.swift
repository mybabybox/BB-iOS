//
//  UIImageExtension.swift
//  BabyBox
//
//  Created by admin on 30/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

//http://stackoverflow.com/questions/29726643/how-to-compress-of-reduce-the-size-of-an-image-before-uploading-to-parse-as-pffi
extension UIImage
{
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)! }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)!}
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)! }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)!}
    var lowestQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.0)! }
}