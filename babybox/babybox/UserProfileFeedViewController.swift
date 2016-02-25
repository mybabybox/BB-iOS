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
    let shapeLayer = CAShapeLayer()
    
    override func reloadDataToView() {
        self.uiCollectionView.reloadData()
    }
    
    override func registerMoreEvents() {
        SwiftEventBus.onMainThread(self, name: "userByIdSuccess") { result in
            self.setUserInfo(result.object as? UserVM)
            //let userImg = self.navigationItem.leftBarButtonItems![0] as UIBarButtonItem
            //(userImg.customView as? UIButton)?.setTitle(self.userInfo?.displayName, forState: UIControlState.Normal)
            self.navigationItem.title = self.userInfo?.displayName
            
            if (self.activeHeaderViewCell != nil) {
                self.activeHeaderViewCell?.segmentControl.setTitle("Products " + String(self.userInfo!.numProducts), forSegmentAtIndex: 0)
                self.activeHeaderViewCell?.segmentControl.setTitle("Likes " + String(self.userInfo!.numLikes), forSegmentAtIndex: 1)
            }
            self.reloadFeedItems()
        }
        
        SwiftEventBus.onMainThread(self, name: "userByIdFailed") { result in
            self.view.makeToast(message: "Error getting User Profile Information!")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
        registerEvents()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = true
        self.navigationItem.setHidesBackButton(false, animated: true)
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
        
        ApiController.instance.getUser(self.userId)
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 5
        uiCollectionView.collectionViewLayout = flowLayout
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.navigationItem.rightBarButtonItems = []
        self.navigationItem.leftBarButtonItems = []
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
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
                
                ImageUtil.displayThumbnailProfileImage(self.userInfo!.id, imageView: cell.userImg)
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
                    ImageUtil.displayCornerButton(cell.editProfile, colorCode: 0xAAAAAA)
                } else {
                    cell.editProfile.setTitle("Follow", forState: UIControlState.Normal)
                    ImageUtil.displayCornerButton(cell.editProfile, colorCode: 0xFF76A4)
                }
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedProductCollectionViewCell
            let feedItem = self.getFeedItems()[indexPath.row]
            return feedViewAdapter!.bindViewCell(cell, feedItem: feedItem, index: indexPath.item, showOwner: true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (collectionView.tag == 2){
            
        } else {
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("FeedProductViewController") as! FeedProductViewController
            let feedItem = self.getFeedItems()[indexPath.row]
            vController.productModel = feedItem
            self.tabBarController!.tabBar.hidden = true
            self.navigationController?.pushViewController(vController, animated: true)
        }
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
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.tabBarController!.tabBar.hidden = true
        if (segue.identifier == "followingCalls" || segue.identifier == "followersCall") {
            let vController = segue.destinationViewController as! FollowersFollowingViewController
            vController.userId = self.userInfo!.id
            vController.optionType = segue.identifier!
        } /*else if (segue.identifier == "followersCall") {
            let vController = segue.destinationViewController as! FollowersFollowingViewController
            vController.userId = self.userInfo!.id
        } */else if (segue.identifier == "editProfile"){
            let vController = segue.destinationViewController as! EditProfileViewController
            vController.userId = self.userInfo!.id
        }
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - constants.FEED_LOAD_SCROLL_THRESHOLD {
            loadMoreFeedItems()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, 350)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = ImageUtil.imageUtil.getProductItemCellSize(self.view.bounds.width)
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
        
        redrawSegControlBorder(segControl!)
    }
    
    func redrawSegControlBorder(segControl: UISegmentedControl) {
        
        let extraHt = CGFloat(0.0)
        if(segControl.selectedSegmentIndex == 0){
            let y = CGFloat(segControl.frame.size.height)
            let start: CGPoint = CGPoint(x: 0, y: (segControl.frame.origin.y) + y - extraHt)
            let end: CGPoint = CGPoint(x: self.view.frame.size.width / 2, y: (segControl.frame.origin.y) + y - extraHt)
            
            let color: UIColor = UIColor(red: 255/255, green: 118/255, blue: 164/255, alpha: 1.0)
            self.drawLineFromPoint(start, toPoint: end, ofColor: color, inView: segControl)
            
        } else if(segControl.selectedSegmentIndex == 1){
            
            let y = CGFloat(segControl.frame.size.height)
            let start: CGPoint = CGPoint(x: segControl.frame.size.width / 2 , y: (segControl.frame.origin.y) + y - extraHt)
            let end: CGPoint = CGPoint(x: segControl.frame.size.width, y: (segControl.frame.origin.y) + y - extraHt)
            
            let color: UIColor = UIColor(red: 255/255, green: 118/255, blue: 164/255, alpha: 1.0)
            self.drawLineFromPoint(start, toPoint: end, ofColor: color, inView: segControl)
        }
        
        segControl.setTitleTextAttributes(
            [NSForegroundColorAttributeName: ImageUtil.UIColorFromRGB(0xFF76A4)],
            forState: UIControlState.Selected)
    }
    
    func setSizesForFilterButtons(cell: UserFeedHeaderViewCell) {
        isWidthSet = true
        let availableWidthForButtons:CGFloat = self.view.bounds.width
        let buttonWidth :CGFloat = availableWidthForButtons / 3
        
        cell.segmentControl.backgroundColor = UIColor.whiteColor()
        
        redrawSegControlBorder(cell.segmentControl)
        
        cell.btnWidthConsttraint.constant = buttonWidth
        /*cell.followersBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.followersBtn.layer.borderWidth = 1.0
        
        cell.followingBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.followingBtn.layer.borderWidth = 1.0        */
        
        cell.editProfile.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.editProfile.layer.borderWidth = 1.0
        
        ImageUtil.displayButtonRoundBorder(cell.editProfile)
        
        if (UserInfoCache.getUser().id != self.userId) {
            cell.editProfile.hidden = false
            ImageUtil.displayButtonRoundBorder(cell.editProfile)
        } else {
            cell.editProfile.hidden = true
        }
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
        
        shapeLayer.fillColor = UIColor.whiteColor().CGColor
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = lineColor.CGColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.allowsEdgeAntialiasing = false
        shapeLayer.allowsGroupOpacity = false
        shapeLayer.autoreverses = false
        self.uiCollectionView.layer.addSublayer(shapeLayer)
    }
    
    @IBAction func onClickFollowUnfollow(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview?.superview as! UserFeedHeaderViewCell
        
        if (self.userInfo!.isFollowing) {
            ApiController.instance.unfollowUser((UserInfoCache.getUser().id))
            self.userInfo!.isFollowing = false
            cell.editProfile.setTitle("Follow", forState: UIControlState.Normal)
            ImageUtil.displayCornerButton(cell.editProfile, colorCode: 0xFF76A4)
        } else {
            ApiController.instance.followUser(UserInfoCache.getUser().id)
            self.userInfo!.isFollowing = true
            cell.editProfile.setTitle("Following", forState: UIControlState.Normal)
            ImageUtil.displayCornerButton(cell.editProfile, colorCode: 0xAAAAAA)
        }
        
    }
}
