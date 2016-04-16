//
//  MyProfileFeedViewController.swift
//  babybox
//
//  Created by Mac on 30/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class MyProfileFeedViewController: BaseProfileFeedViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var reuseIdentifier = "CellType"
    
    var isWidthSet = false
    var isHtCalculated = false
    
    var activeHeaderViewCell: UserFeedHeaderViewCell? = nil
    let imagePicker = UIImagePickerController()
    
    var vController: ProductViewController?
    var currentIndex: NSIndexPath?
    
    var isRefresh: Bool = false
    var uploadedImage: UIImage?
    
    override func reloadDataToView() {
        self.uiCollectionView.reloadData()
    }
    
    override func registerMoreEvents() {
        SwiftEventBus.onMainThread(self, name: "profileImgUploadSuccess") { result in
            self.view.makeToast(message: "Profile image uploaded successfully!")
            self.activeHeaderViewCell!.userImg.image = self.uploadedImage
            //ImageUtil.displayThumbnailProfileImage(self.userInfo!.id, imageView: self.activeHeaderViewCell!.userImg)
        }
        
        SwiftEventBus.onMainThread(self, name: "profileImgUploadFailed") { result in
            self.view.makeToast(message: "Error uploading profile image!")
            self.uploadedImage = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
        NotificationCounter.refresh(onSuccessRefreshNotifications, failureCallback: onFailureRefreshNotifications)
        registerEvents()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.alpha = CGFloat(Constants.MAIN_BOTTOM_BAR_ALPHA)
        
        if (self.activeHeaderViewCell != nil) {
            self.activeHeaderViewCell?.segmentControl.setTitle("Products " + String(self.userInfo!.numProducts), forSegmentAtIndex: 0)
            self.activeHeaderViewCell?.segmentControl.setTitle("Likes " + String(self.userInfo!.numLikes), forSegmentAtIndex: 1)
        }
        
        if (currentIndex != nil) {
            let item = vController?.feedItem
            feedLoader?.setItem(currentIndex!.row, item: item!)
            self.uiCollectionView.reloadItemsAtIndexPaths([currentIndex!])
            currentIndex = nil
        }
        
        setUserInfo(UserInfoCache.getUser())
        
        //check for flag and if found refresh the data..
        if (self.isRefresh) {
            reloadFeedItems()
            self.isRefresh = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        unregisterEvents()
        //clearFeedItems()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedViewAdapter = FeedViewAdapter(collectionView: uiCollectionView)
        
        setUserInfo(UserInfoCache.getUser())
        
        registerEvents()
        
        reloadFeedItems()
        
        self.imagePicker.delegate = self
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        self.uiCollectionView.collectionViewLayout = FeedViewAdapter.getFeedViewFlowLayout(self)
        
        self.uiCollectionView!.alwaysBounceVertical = true
        self.uiCollectionView!.backgroundColor = Color.FEED_BG
        
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            self?.reloadFeedItems()
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
        
        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("headerCell", forIndexPath: indexPath) as! UserFeedHeaderViewCell
            self.activeHeaderViewCell = cell
            
            //Divide the width equally among buttons..
            if (!isWidthSet) {
                setSizesForFilterButtons(cell)
            }
            
            cell.displayName.text = self.userInfo?.displayName
            cell.profileDescription.numberOfLines = 3
            cell.profileDescription.text = self.userInfo?.aboutMe
            cell.profileDescription.sizeToFit()
            if cell.userImg.image == nil {
                ImageUtil.displayMyThumbnailProfileImage(self.userInfo!.id, imageView: cell.userImg)
            }
            
            if (self.userInfo!.numFollowers > 0) {
                cell.followersBtn.setTitle("Followers " + String(self.userInfo!.numFollowers), forState:UIControlState.Normal)
            } else {
                cell.followersBtn.setTitle("Followers", forState: UIControlState.Normal)
            }
                
            if (self.userInfo!.numFollowings > 0) {
                cell.followingBtn.setTitle("Following " + String(self.userInfo!.numFollowings), forState: UIControlState.Normal)
            } else {
                cell.followingBtn.setTitle("Following", forState: UIControlState.Normal)
            }

            return cell
        } else {
            let feedItem = self.getFeedItems()[indexPath.row]
            if feedItem.id == -1 {
                //this mean there are no results.... hence show no result text
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoItemsToolTip", forIndexPath: indexPath) as! TooltipViewCell
                return feedViewAdapter!.bindNoItemToolTip(cell, feedType: (self.feedLoader?.feedType)!)
            }
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedProductCollectionViewCell
            
            return feedViewAdapter!.bindViewCell(cell, feedItem: feedItem, index: indexPath.item)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
            if self.feedLoader?.feedItems.count == 1 {
                if self.feedLoader?.feedItems[0].id == -1 {
                    return FeedViewAdapter.getNoFeedItemCellSize(self.view.bounds.width)
                }
            }
            
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
        if (identifier == "followingCalls") {
            return true
        } else if (identifier == "followersCall") {
            return true
        } else if (identifier == "editProfile"){
            return true
        } else if (identifier == "mpProductScreen"){
            return true
        } else if (identifier == "settings") {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "followingCalls" || segue.identifier == "followersCall") {
            let vController = segue.destinationViewController as! FollowersFollowingViewController
            vController.userId = self.userInfo!.id
            vController.optionType = segue.identifier!
            vController.hidesBottomBarWhenPushed = true
        } else if (segue.identifier == "editProfile"){
            let vController = segue.destinationViewController as! EditProfileViewController
            vController.userId = self.userInfo!.id
            vController.hidesBottomBarWhenPushed = true
        } else if (segue.identifier == "mpProductScreen"){
            let cell = sender as! FeedProductCollectionViewCell
            let indexPath = self.uiCollectionView!.indexPathForCell(cell)
            let feedItem = feedLoader!.getItem(indexPath!.row)
            self.currentIndex = indexPath
            vController = segue.destinationViewController as? ProductViewController
            vController!.feedItem = feedItem
            vController!.hidesBottomBarWhenPushed = true
        } else if (segue.identifier == "settings") {
            //self.uiCollectionView.delegate = nil
            let vController = segue.destinationViewController as! SettingsViewController
            vController.hidesBottomBarWhenPushed = true
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
    
    @IBAction func onClickBrowse(sender: AnyObject) {
        //upload image.
        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .PhotoLibrary
        self.navigationController!.presentViewController(self.imagePicker, animated: true, completion: nil)
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
        
        if (self.activeHeaderViewCell != nil) {
            self.activeHeaderViewCell?.segmentControl.setTitle("Products " + String(self.userInfo!.numProducts), forSegmentAtIndex: 0)
            self.activeHeaderViewCell?.segmentControl.setTitle("Likes " + String(self.userInfo!.numLikes), forSegmentAtIndex: 1)
        }
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.uploadedImage = pickedImage
            ApiController.instance.uploadUserProfileImage(pickedImage)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setSizesForFilterButtons(cell: UserFeedHeaderViewCell) {
        isWidthSet = true
        let availableWidthForButtons:CGFloat = self.view.bounds.width
        let buttonWidth :CGFloat = availableWidthForButtons / 3
        
        cell.segmentControl.backgroundColor = Color.WHITE
        
        ViewUtil.selectSegmentControl(cell.segmentControl, view: self.uiCollectionView)
        
        cell.btnWidthConsttraint.constant = buttonWidth
        cell.editProfile.layer.borderColor = Color.LIGHT_GRAY.CGColor
        cell.editProfile.layer.borderWidth = 1.0
        
        ViewUtil.displayRoundedCornerView(cell.editProfile)
    }
    
    func onSuccessRefreshNotifications(notifcationCounter: NotificationCounterVM) {
        ViewUtil.refreshNotifications((self.tabBarController?.tabBar)!, navigationItem: self.navigationItem)
    }
    
    func onFailureRefreshNotifications(message: String) {
        NSLog(message)
    }
}
