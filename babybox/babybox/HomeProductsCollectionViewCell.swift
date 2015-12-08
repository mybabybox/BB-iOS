//
//  HomeProductsCollectionViewCell.swift
//  Baby Box
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import UIKit

class HomeProductsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var likeCount: UILabel!
    
   // @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var productIcon: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var productPrice: UILabel!
    
    var likeFlag: Bool!
    var id: Double!
    
    @IBAction func onLikeOrUnlinkClick(sender: AnyObject) {
        //print("sender..............\(sender)")
        
        let count = (self.likeCount.text! as NSString).integerValue
        //print(self.id)
        if(self.likeFlag == false){
            self.buttonLike.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = true
            ApiControlller().postLikeButton(String(Int(self.id)))
            self.likeCount.text = String(count + 1)
        }else{
            self.buttonLike.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = false
            ApiControlller().postUnlikeButton(String(Int(self.id)))
            self.likeCount.text = String(count - 1)
        }
        
    }
    
    
    
    
    
    
    
    
}