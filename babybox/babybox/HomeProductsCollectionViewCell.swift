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
    
    //@IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var productIcon: UIImageView!
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    
    var likeFlag: Bool!
    var id: Int!
    
    @IBAction func onLikeOrUnlinkClick(sender: AnyObject) {
        //print("sender..............\(sender)")
        
        let count = (self.likeCount.text! as NSString).integerValue
        //print(self.id)
        if(self.likeFlag == false){
            self.buttonLike.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = true
            ApiControlller().likePost(String(Int(self.id)))
            self.likeCount.text = String(count + 1)
        }else{
            self.buttonLike.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = false
            ApiControlller().unlikePost(String(Int(self.id)))
            self.likeCount.text = String(count - 1)
        }
        
    }
    
    
    
    
    
    
    
    
}