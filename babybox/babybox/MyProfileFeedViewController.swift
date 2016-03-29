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
    
    var activeHeaderViewCell: UserFeedHeaderViewCell?  = nil
    let shapeLayer = CAShapeLayer()
    let imagePicker = UIImagePickerController()
    
    var vController: ProductViewController?
    var currentIndex: NSIndexPath?
    
    var isRefresh: Bool = false
    
    override func reloadDataToView() {
        self.uiCollectionView.reloadData()
    }
    
    override func registerMoreEvents() {
        SwiftEventBus.onMainThread(self, name: "profileImgUploadSuccess") { result in
            self.view.makeToast(message: "Profile image uploaded successfully!")
        }
        
        SwiftEventBus.onMainThread(self, name: "profileImgUploadFailed") { result in
            self.view.makeToast(message: "Error uploading profile image!")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
        registerEvents()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.alpha = CGFloat(Constants.MAIN_BOTTOM_BAR_ALPHA)
        //self.navigationItem.hidesBackButton = true
        //self.tabBarController?.tabBar.hidden = false
        
        if (self.activeHeaderViewCell != nil) {
            self.activeHeaderViewCell?.segmentControl.setTitle("Products " + String(self.userInfo!.numProducts), forSegmentAtIndex: 0)
            self.activeHeaderViewCell?.segmentControl.setTitle("Likes " + String(self.userInfo!.numLikes), forSegmentAtIndex: 1)
        }
        
        if (currentIndex != nil) {
            let item = vController?.feedItem
            feedLoader?.setItem(currentIndex!.row, item: item!)
            self.uiCollectionView.reloadItemsAtIndexPaths([currentIndex!])
        }
        
        NotificationCounter.mInstance.refresh(handleNotificationSuccess, failureCallback: handleNotificationError)
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
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = Constants.FEED_ITEM_SIDE_SPACING
        flowLayout.minimumLineSpacing = Constants.FEED_ITEM_LINE_SPACING
        uiCollectionView.collectionViewLayout = flowLayout
        
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            ViewUtil.showActivityLoading(self!.activityLoading)
            self!.feedLoader?.reloadFeedItems((self!.userInfo?.id)!)
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
        
        if (collectionView.tag == 2){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("headerCell", forIndexPath: indexPath) as! UserFeedHeaderViewCell
            self.activeHeaderViewCell = cell
            
            //Divide the width equally among buttons..
            if (!isWidthSet) {
                setSizesForFilterButtons(cell)
            }
            
            cell.displayName.text = self.userInfo?.displayName
                
            ImageUtil.displayThumbnailProfileImage(self.userInfo!.id, imageView: cell.userImg)
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedProductCollectionViewCell
            let feedItem = self.getFeedItems()[indexPath.row]
            return feedViewAdapter!.bindViewCell(cell, feedItem: feedItem, index: indexPath.item)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        
        if (kind == UICollectionElementKindSectionHeader) {
            
            let headerView : ProfileFeedReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! ProfileFeedReusableView
            headerView.headerViewCollection.reloadData()
            reusableView = headerView
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
            /*var ht: CGFloat = 0.0
            for view in collectionView.subviews as [UIView] {
                ht += view.frame.height
            }*/
            if (self.isTipVisible()) {
                return CGSizeMake(self.view.frame.width, 295)
            } else {
                return CGSizeMake(self.view.frame.width, 190)
            }
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
            //
            let cell = sender as! FeedProductCollectionViewCell
            let indexPath = self.uiCollectionView!.indexPathForCell(cell)
            let feedItem = feedLoader!.getItem(indexPath!.row)
            self.currentIndex = indexPath
            vController = segue.destinationViewController as? ProductViewController
            vController!.feedItem = feedItem
            vController!.hidesBottomBarWhenPushed = true
            self.tabBarController?.tabBar.hidden = true
            
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
        collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, 350)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = ViewUtil.getProductItemCellSize(self.view.bounds.width)
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FeedProductCollectionViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        let feedItem = self.getFeedItems()[indexPath.row]
        
        feedViewAdapter!.onLikeBtnClick(cell, feedItem: feedItem)
    }
    
    @IBAction func onClickCloseTip(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview!.superview as! UserFeedHeaderViewCell
        cell.tipsView.hidden = true
        cell.tipsConstraint.constant = 6
        redrawSegControlBorder(cell.segmentControl)
        self.uiCollectionView.reloadData()
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

        redrawSegControlBorder(segControl!)
        
        if (self.activeHeaderViewCell != nil) {
            self.activeHeaderViewCell?.segmentControl.setTitle("Products " + String(self.userInfo!.numProducts), forSegmentAtIndex: 0)
            self.activeHeaderViewCell?.segmentControl.setTitle("Likes " + String(self.userInfo!.numLikes), forSegmentAtIndex: 1)
        }
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.activeHeaderViewCell?.userImg.image = pickedImage
            ApiController.instance.uploadUserProfileImage(pickedImage)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func redrawSegControlBorder(segControl: UISegmentedControl) {
        
        var extraHt = CGFloat(0.0)
        if (!isTipVisible() && !isHtCalculated) {
            extraHt = CGFloat(114.0)
            self.isHtCalculated = true
        }
        
        if(segControl.selectedSegmentIndex == 0){
            let y = CGFloat(segControl.frame.size.height)
            let start: CGPoint = CGPoint(x: 0, y: (segControl.frame.origin.y) + y - extraHt)
            let end: CGPoint = CGPoint(x: self.view.frame.size.width / 2, y: (segControl.frame.origin.y) + y - extraHt)
            self.drawLineFromPoint(start, toPoint: end, ofColor: Color.PINK, inView: segControl)
        } else if(segControl.selectedSegmentIndex == 1){
            let y = CGFloat(segControl.frame.size.height)
            let start: CGPoint = CGPoint(x: segControl.frame.size.width / 2 , y: (segControl.frame.origin.y) + y - extraHt)
            let end: CGPoint = CGPoint(x: segControl.frame.size.width, y: (segControl.frame.origin.y) + y - extraHt)
            self.drawLineFromPoint(start, toPoint: end, ofColor: Color.PINK, inView: segControl)
        }
        segControl.setTitleTextAttributes([NSForegroundColorAttributeName: Color.PINK],
            forState: UIControlState.Selected)
        segControl.setTitleTextAttributes([NSForegroundColorAttributeName: Color.LIGHT_GRAY],
            forState: UIControlState.Normal)
    }
    
    func setSizesForFilterButtons(cell: UserFeedHeaderViewCell) {
        isWidthSet = true
        let availableWidthForButtons:CGFloat = self.view.bounds.width
        let buttonWidth :CGFloat = availableWidthForButtons / 3
        
        cell.segmentControl.backgroundColor = Color.WHITE
        
        redrawSegControlBorder(cell.segmentControl)
        
        cell.btnWidthConsttraint.constant = buttonWidth
        cell.editProfile.layer.borderColor = Color.LIGHT_GRAY.CGColor
        cell.editProfile.layer.borderWidth = 1.0
        
        if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.MY_PROFILE_TIPS)) {
            cell.tipsView.hidden = false
        } else {
            cell.tipsView.hidden = true
            cell.tipsConstraint.constant = 6
        }
        
        ViewUtil.displayRoundedCornerView(cell.editProfile)
    }
   
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view: UIView) {
        //design the path
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addLineToPoint(end)
        path.lineJoinStyle = CGLineJoin.Round
        path.lineCapStyle = CGLineCap.Square
        path.miterLimit = CGFloat(0.0)
        //design path in layer
        
        shapeLayer.fillColor = Color.WHITE.CGColor
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = lineColor.CGColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.allowsEdgeAntialiasing = false
        shapeLayer.allowsGroupOpacity = false
        shapeLayer.autoreverses = false
        self.uiCollectionView.layer.addSublayer(shapeLayer)
    }
    
    func handleNotificationSuccess(notifcationCounter: NotificationCounterVM) {
        ViewUtil.refreshNotifications((self.tabBarController?.tabBar)!, navigationItem: self.navigationItem)
    }
    
    func handleNotificationError(message: String) {
        NSLog(message)
    }
}
