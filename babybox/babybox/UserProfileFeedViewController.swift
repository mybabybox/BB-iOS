//
//  UserProfileFeedViewController.swift
//  babybox
//
//  Created by Mac on 30/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class UserProfileFeedViewController: BaseProfileFeedViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var reuseIdentifier = "CellType"

    var isWidthSet = false
    var isHeightSet: Bool = false
    var isHtCalculated = false
    
    var activeHeaderViewCell: UserFeedHeaderViewCell? = nil
    
    var vController: ProductViewController?
    var currentIndex: NSIndexPath?
    
    override func reloadDataToView() {
        self.uiCollectionView.reloadData()
    }
    
    override func registerMoreEvents() {
    
    }
    
    func onSuccessGetUser(user: UserVM?) {
        self.setUserInfo(user)
        self.navigationItem.title = self.userInfo?.displayName
        
        if (self.activeHeaderViewCell != nil) {
            self.activeHeaderViewCell?.segmentControl.setTitle("Products " + String(self.userInfo!.numProducts), forSegmentAtIndex: 0)
            self.activeHeaderViewCell?.segmentControl.setTitle("Likes " + String(self.userInfo!.numLikes), forSegmentAtIndex: 1)
        }
        self.reloadFeedItems()
    }
    
    func onFailureGetUser(error: String) {
        self.view.makeToast(message: error)
    }

    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
        registerEvents()
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.tabBarController!.tabBar.hidden = true
        //self.navigationItem.setHidesBackButton(false, animated: true)
        
        if (currentIndex != nil) {
            let item = vController?.feedItem
            feedLoader?.setItem(currentIndex!.row, item: item!)
            self.uiCollectionView.reloadItemsAtIndexPaths([currentIndex!])
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        unregisterEvents()
        //clearFeedItems()
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feedViewAdapter = FeedViewAdapter(collectionView: uiCollectionView)
        
        registerEvents()
        
        ApiFacade.getUser(self.userId, successCallback: onSuccessGetUser, failureCallback: onFailureGetUser)
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        uiCollectionView.collectionViewLayout = FeedViewAdapter.getFeedViewFlowLayout(self)
        
        self.navigationItem.rightBarButtonItems = []
        self.navigationItem.leftBarButtonItems = []
        self.uiCollectionView!.alwaysBounceVertical = true
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            self!.feedLoader?.reloadFeedItems((self?.userInfo?.id)!)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if (collectionView.tag == 2) {
            count = 1
        } else {
            count = self.getFeedItems().count
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (collectionView.tag == 2) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("headerCell", forIndexPath: indexPath) as! UserFeedHeaderViewCell
            self.activeHeaderViewCell = cell
            
            //Divide the width equally among buttons..
            if (!isWidthSet) {
                setSizesForFilterButtons(cell)
            }
            
            if (self.userInfo != nil) {
                cell.displayName.text = self.userInfo?.displayName
                
                if cell.userImg.image == nil {
                    ImageUtil.displayThumbnailProfileImage(self.userInfo!.id, imageView: cell.userImg)
                }
                
                if (self.userInfo!.numFollowers > 0) {
                    cell.followersBtn.setTitle("Followers " + String(self.userInfo!.numFollowers), forState: UIControlState.Normal)
                } else {
                    cell.followersBtn.setTitle("Followers", forState: UIControlState.Normal)
                }
                
                if (self.userInfo!.numFollowings > 0) {
                    cell.followingBtn.setTitle("Following " + String(self.userInfo!.numFollowings), forState: UIControlState.Normal)
                } else {
                    cell.followingBtn.setTitle("Following", forState: UIControlState.Normal)
                }
                
                if (self.userInfo!.isFollowing) {
                    cell.editProfile.setTitle("Following", forState: UIControlState.Normal)
                    ViewUtil.displayRoundedCornerView(cell.editProfile, bgColor: Color.LIGHT_GRAY)
                } else {
                    cell.editProfile.setTitle("Follow", forState: UIControlState.Normal)
                    ViewUtil.displayRoundedCornerView(cell.editProfile, bgColor: Color.PINK)
                }
                
                cell.profileDescription.numberOfLines = 3
                cell.profileDescription.text = self.userInfo?.aboutMe
                cell.profileDescription.sizeToFit()
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedProductCollectionViewCell
            let feedItem = self.getFeedItems()[indexPath.row]
            return feedViewAdapter!.bindViewCell(cell, feedItem: feedItem, index: indexPath.item, showOwner: true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (collectionView.tag == 2) {
            
        } else {
            /*vController =  self.storyboard!.instantiateViewControllerWithIdentifier("ProductViewController") as! ProductViewController
            let feedItem = self.getFeedItems()[indexPath.row]
            vController!.feedItem = feedItem
            self.currentIndex = indexPath
            //self.tabBarController!.tabBar.hidden = true
            self.navigationController?.pushViewController(vController!, animated: true)*/
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        
        if kind == UICollectionElementKindSectionHeader {
            
            let headerView : ProfileFeedReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! ProfileFeedReusableView
            headerView.headerViewCollection.reloadData()
            reusableView = headerView
            
        } else if kind == UICollectionElementKindSectionFooter {
            switch self.feedLoader!.feedType {
            case FeedFilter.FeedType.USER_POSTED:
                reusableView = ViewUtil.prepareNoItemsFooterView(self.uiCollectionView, indexPath: indexPath, noItemText: Constants.NO_POSTS)
            case FeedFilter.FeedType.USER_LIKED:
                reusableView = ViewUtil.prepareNoItemsFooterView(self.uiCollectionView, indexPath: indexPath, noItemText: Constants.NO_LIKES)
            default: break
            }
        }
        
        return reusableView!
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (collectionView.tag == 2) {
            if let _ = collectionViewTopCellSize {
                setCollectionViewSizesInsetsForTopView()
                return collectionViewTopCellSize!
            }
        } else {
            if let _ = collectionViewCellSize {
                return collectionViewCellSize!
            }
        }
        return CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (collectionView.tag == 2){
            return CGSizeZero
        } else {
            return CGSizeMake(self.view.frame.width, Constants.PROFILE_HEADER_HEIGHT)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "followingCalls" || identifier == "followersCall") {
            return true
        } else if (identifier == "editProfile"){
            return true
        } else if (identifier == "upProductScreen") {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //self.tabBarController!.tabBar.hidden = true
        if (segue.identifier == "followingCalls" || segue.identifier == "followersCall") {
            let vController = segue.destinationViewController as! FollowersFollowingViewController
            vController.userId = self.userInfo!.id
            vController.optionType = segue.identifier!
            vController.hidesBottomBarWhenPushed = true
        } else if (segue.identifier == "editProfile"){
            let vController = segue.destinationViewController as! EditProfileViewController
            vController.userId = self.userInfo!.id
            vController.hidesBottomBarWhenPushed = true
        } else if (segue.identifier == "upProductScreen") {
            let cell = sender as! FeedProductCollectionViewCell
            let indexPath = self.uiCollectionView!.indexPathForCell(cell)
            let feedItem = feedLoader!.getItem(indexPath!.row)
            self.currentIndex = indexPath
            vController = segue.destinationViewController as? ProductViewController
            vController!.feedItem = feedItem
            vController!.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            loadMoreFeedItems()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, Constants.PROFILE_HEADER_HEIGHT)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = FeedViewAdapter.getFeedItemCellSize(self.view.bounds.width)
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FeedProductCollectionViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        let feedItem = self.getFeedItems()[indexPath.row]
        
        feedViewAdapter!.onLikeBtnClick(cell, feedItem: feedItem)
    }
    
    @IBAction func segAction(sender: AnyObject) {
        let segControl = sender as? UISegmentedControl
        if (segControl!.selectedSegmentIndex == 0) {
            feedLoader?.setFeedType(FeedFilter.FeedType.USER_POSTED)
        } else if (segControl!.selectedSegmentIndex == 1) {
            feedLoader?.setFeedType(FeedFilter.FeedType.USER_LIKED)
        }
        
        reloadFeedItems()
        
        ViewUtil.selectSegmentControl(segControl!, view: self.uiCollectionView)
    }
    
    func setSizesForFilterButtons(cell: UserFeedHeaderViewCell) {
        isWidthSet = true
        let availableWidthForButtons:CGFloat = self.view.bounds.width
        let buttonWidth :CGFloat = availableWidthForButtons / 3
        
        cell.segmentControl.backgroundColor = Color.WHITE
        
        ViewUtil.selectSegmentControl(cell.segmentControl, view: self.uiCollectionView)
        
        cell.btnWidthConsttraint.constant = buttonWidth
        /*cell.followersBtn.layer.borderColor = Color.LIGHT_GRAY.CGColor
        cell.followersBtn.layer.borderWidth = 1.0
        
        cell.followingBtn.layer.borderColor = Color.LIGHT_GRAY.CGColor
        cell.followingBtn.layer.borderWidth = 1.0        */
        
        ViewUtil.displayRoundedCornerView(cell.editProfile, bgColor: Color.LIGHT_GRAY)
        
        if (UserInfoCache.getUser()!.id != self.userId) {
            cell.editProfile.hidden = false
        } else {
            cell.editProfile.hidden = true
        }
    }
   
    @IBAction func onClickFollowUnfollow(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview?.superview as! UserFeedHeaderViewCell
        
        if (self.userInfo!.isFollowing) {
            ApiController.instance.unfollowUser((self.userInfo!.id))
            self.userInfo!.isFollowing = false
            cell.editProfile.setTitle("Follow", forState: UIControlState.Normal)
            ViewUtil.displayRoundedCornerView(cell.editProfile, bgColor: Color.PINK)
        } else {
            ApiController.instance.followUser(self.userInfo!.id)
            self.userInfo!.isFollowing = true
            cell.editProfile.setTitle("Following", forState: UIControlState.Normal)
            ViewUtil.displayRoundedCornerView(cell.editProfile, bgColor: Color.LIGHT_GRAY)
        }
    }
}
