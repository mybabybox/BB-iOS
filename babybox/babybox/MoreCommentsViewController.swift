//
//  MoreCommentsViewController.swift
//  BabyBox
//
//  Created by admin on 13/04/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class MoreCommentsViewController: UIViewController {

    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    var comments: [CommentVM]? = []
    var collectionViewCellSize : CGSize?
    var loading: Bool = false
    var loadedAll: Bool = false
    var postId: Int = 0
    var offset: Int64 = 0
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewUtil.showActivityLoading(self.activityLoading)
        
        setCollectionViewSizesInsetsForTopView()
        
        ApiFacade.getComments(self.postId, offset: offset, successCallback: onSuccessAddComment, failureCallback: onFailure)
        
        self.loading = true
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        self.uiCollectionView.collectionViewLayout = flowLayout
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.comments!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("commentViewCell", forIndexPath: indexPath) as! CommentCollectionViewCell
        let comment = self.comments![indexPath.row]
        ImageUtil.displayThumbnailProfileImage(comment.ownerId, imageView: cell.userImg)
        cell.userName.text = comment.ownerName
        cell.commentText.text = comment.body
        cell.commentTime.text = NSDate(timeIntervalSince1970:Double(comment.createdDate) / 1000.0).timeAgo
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = self.comments![indexPath.row].ownerId
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        collectionViewCellSize = CGSizeMake(self.view.bounds.width, 65)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewCellSize!
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                ViewUtil.showActivityLoading(self.activityLoading)
                loading = true
                if (!self.comments!.isEmpty) {
                    self.offset += 1
                }
                ApiFacade.getComments(self.postId, offset: offset, successCallback: onSuccessAddComment, failureCallback: onFailure)
                
            }
        }
    }
    
    func onSuccessAddComment(_comments: [CommentVM]) {
        
        if (!_comments.isEmpty) {
            if (self.comments!.count == 0) {
                self.comments = _comments
            } else {
                self.comments!.appendContentsOf(_comments)
            }
            self.uiCollectionView.reloadData()
        } else {
            loadedAll = true
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
        
    }
    
    func onFailure(message: String) {
        ViewUtil.showDialog("Error", message: message, view: self)
    }
    

}
