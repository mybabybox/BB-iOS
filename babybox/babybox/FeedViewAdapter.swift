//
//  FeedViewAdapter.swift
//  BabyBox
//
//  Created by Keith Lei on 2/18/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class FeedViewAdapter {

    var collectionView: UICollectionView
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }

    func bindViewCell(cell: FeedProductCollectionViewCell, feedItem: PostVMLite, index: Int) -> FeedProductCollectionViewCell {
        return bindViewCell(cell, feedItem: feedItem, index: index, showOwner: false)
    }
    
    func bindViewCell(cell: FeedProductCollectionViewCell, feedItem: PostVMLite, index: Int, showOwner: Bool) -> FeedProductCollectionViewCell {
        
        cell.title.text = feedItem.title
        
        // load image
        if (feedItem.hasImage) {
            ImageUtil.displayPostImage(feedItem.images[0], imageView: cell.prodImageView)
        }
        
        // sold tag
        cell.soldImage.hidden = !feedItem.sold
        cell.likeCountIns.setTitle(String(feedItem.numLikes), forState: UIControlState.Normal)

        // liked?
        cell.likeImageIns.tag = index
        //cell.likeImageIns.addTarget(self, action: "onLikeBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        if (!feedItem.isLiked) {
            cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
        } else {
            cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
        }

        // price
        cell.productPrice.text = "\(Constants.CURRENCY_SYMBOL) \(String(stringInterpolationSegment: Int(feedItem.price)))"
        if (feedItem.originalPrice != 0 && feedItem.originalPrice != -1 && feedItem.originalPrice != Int(feedItem.price)) {
            let attrString = NSAttributedString(string: "\(Constants.CURRENCY_SYMBOL) \(String(stringInterpolationSegment:Int(feedItem.originalPrice)))", attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
            cell.originalPrice.attributedText = attrString
        } else {
            cell.originalPrice.attributedText = NSAttributedString(string: "")
        }
        
        cell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
        cell.layer.borderWidth = 1

        // Owner
        if (showOwner && cell.userCircleImg != nil) {
            cell.userCircleImg.layer.borderColor = Color.WHITE.CGColor
            cell.userCircleImg.layer.borderWidth = CGFloat(1.0)
            ImageUtil.displayThumbnailProfileImage(feedItem.ownerId, imageView: cell.userCircleImg)
        }
        
        return cell
    }

    func onLikeBtnClick(cell: FeedProductCollectionViewCell, feedItem: PostVMLite) {
        if (feedItem.isLiked) {
            feedItem.isLiked = false
            feedItem.numLikes--
            cell.likeCountIns.setTitle(String(feedItem.numLikes), forState: UIControlState.Normal)
            cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            ApiController.instance.unlikePost(feedItem.id)
        } else {
            feedItem.isLiked = true
            feedItem.numLikes++
            cell.likeCountIns.setTitle(String(feedItem.numLikes), forState: UIControlState.Normal)
            cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            ApiController.instance.likePost(feedItem.id)
        }
    }
}



