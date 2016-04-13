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
        
        cell.title.font = UIFont.systemFontOfSize(14)
        cell.title.textColor = Color.DARK_GRAY
        cell.title.text = feedItem.title
        
        // load image
        if (feedItem.hasImage) {
            ImageUtil.displayPostImage(feedItem.images[0], imageView: cell.prodImageView)
        }
        
        // sold tag
        cell.soldImage.hidden = !feedItem.sold
        
        // like count
        cell.likeCountIns.titleLabel?.minimumScaleFactor = 0.01
        cell.likeCountIns.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.likeCountIns.titleLabel?.lineBreakMode = NSLineBreakMode.ByClipping
        cell.likeCountIns.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        cell.likeCountIns.setTitle(String(feedItem.numLikes), forState: UIControlState.Normal)
        cell.likeCountIns.sizeToFit()

        // liked?
        cell.likeImageIns.tag = index
        //cell.likeImageIns.addTarget(self, action: "onLikeBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        if (!feedItem.isLiked) {
            cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
        } else {
            cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
        }

        // price
        cell.productPrice.font = UIFont.systemFontOfSize(14)
        cell.productPrice.text = "\(Constants.CURRENCY_SYMBOL)\(String(stringInterpolationSegment: Int(feedItem.price)))"
        if (feedItem.originalPrice != 0 && feedItem.originalPrice != -1 && feedItem.originalPrice != Int(feedItem.price)) {
            let attrString = NSAttributedString(string: "\(Constants.CURRENCY_SYMBOL)\(String(stringInterpolationSegment:Int(feedItem.originalPrice)))", attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
            cell.originalPrice.attributedText = attrString
        } else {
            cell.originalPrice.attributedText = NSAttributedString(string: "")
        }
        
        cell.layer.borderColor = Color.FEED_ITEM_BORDER.CGColor
        cell.layer.borderWidth = 0.5

        // Owner
        if (showOwner && cell.userCircleImg != nil) {
            cell.userCircleImg.layer.borderColor = Color.WHITE.CGColor
            cell.userCircleImg.layer.borderWidth = CGFloat(1.0)
            ImageUtil.displayThumbnailProfileImage(feedItem.ownerId, imageView: cell.userCircleImg)
        }
        
        cell.layer.cornerRadius = 7
        return cell
    }

    func onLikeBtnClick(cell: FeedProductCollectionViewCell, feedItem: PostVMLite) {
        if (feedItem.isLiked) {
            feedItem.isLiked = false
            feedItem.numLikes -= 1
            cell.likeCountIns.setTitle(String(feedItem.numLikes), forState: UIControlState.Normal)
            cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            ApiController.instance.unlikePost(feedItem.id)
        } else {
            feedItem.isLiked = true
            feedItem.numLikes += 1
            cell.likeCountIns.setTitle(String(feedItem.numLikes), forState: UIControlState.Normal)
            cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            ApiController.instance.likePost(feedItem.id)
        }
    }
    
    func getFeedItemCellSize(width: CGFloat) -> CGSize {
        let availableWidthForCells: CGFloat = width - (Constants.FEED_ITEM_SIDE_SPACING * 3)  // left middle right spacing
        let cellWidth: CGFloat = availableWidthForCells / 2
        let cellHeight = cellWidth + Constants.FEED_ITEM_DETAILS_HEIGHT
        return CGSizeMake(cellWidth, cellHeight)
    }
    
    func getFeedViewFlowLayout(viewController: UIViewController) -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(viewController.view.bounds.width, viewController.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = Constants.FEED_ITEM_SIDE_SPACING
        flowLayout.minimumLineSpacing = Constants.FEED_ITEM_LINE_SPACING
        flowLayout.sectionInset = UIEdgeInsetsMake(0, Constants.FEED_ITEM_SIDE_SPACING, 0, Constants.FEED_ITEM_SIDE_SPACING)
        return flowLayout
    }
}



