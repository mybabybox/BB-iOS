//
//  UserActivityViewController.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import PullToRefreshSwift

class UserActivityViewController: CustomNavigationController {

    @IBOutlet weak var tipText: UILabel!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var activityOffSet: Int64 = 0
    var userActivitesItems: [ActivityVM] = []
    var collectionViewCellSize : CGSize?
    var loading: Bool = false
    var loadedAll: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
    }

    override func viewDidAppear(animated: Bool) {
        NotificationCounter.mInstance.refresh(handleNotificationSuccess, failureCallback: handleNotificationError)
    }
    
    override func viewDidDisappear(animated: Bool) {
        //self.userActivitesItems.removeAll()
        //self.uiCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewUtil.showActivityLoading(self.activityLoading)
        
        ApiController.instance.getUserActivities(activityOffSet)
        self.loading = true
        setCollectionViewSizesInsetsForTopView()
        
        SwiftEventBus.onMainThread(self, name: "userActivitiesSuccess") { result in
            // UI thread
            let resultDto: [ActivityVM] = result.object as! [ActivityVM]
            self.handleUserActivitiesData(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "userActivitiesFailed") { result in
            // UI thread
            self.view.makeToast(message: "Error getting User activities data.")
        }
        
        SwiftEventBus.onMainThread(self, name: "postByIdLoadSuccess") { result in
            // UI thread
            
            if ViewUtil.isEmptyResult(result, message: "Product not found. It may be deleted by seller.", view: self.view) {
                return
            }
            
            let resultDto: PostVMLite = result.object as! PostVMLite
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("ProductViewController") as! ProductViewController
            vController.feedItem = resultDto
            vController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vController, animated: true)
        }
        
        SwiftEventBus.onMainThread(self, name: "postByIdLoadFailure") { result in
            // UI thread
            self.view.makeToast(message: "Error getting Post data.")
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        uiCollectionView.collectionViewLayout = flowLayout
        
        self.uiCollectionView.addPullToRefresh({ [weak self] in
            self?.reload()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userActivitesItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let viewStatus = self.userActivitesItems[indexPath.row].viewed
        
        switch (self.userActivitesItems[indexPath.row].activityType) {
            
            case "LIKED", "FOLLOWED":
                
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserActivity", forIndexPath: indexPath) as! UserActivityViewCell
                
                cell.contentMode = UIViewContentMode.Redraw
                cell.sizeToFit()
                cell.activityTime.text = NSDate(timeIntervalSince1970:Double(self.userActivitesItems[indexPath.row].createdDate) / 1000.0).timeAgo
                ImageUtil.displayThumbnailProfileImage(Int(self.userActivitesItems[indexPath.row].actorImage), imageView: cell.profileImg)
                cell.textMessage.text = self.setMessageText(self.userActivitesItems[indexPath.row])
                cell.textMessage.numberOfLines = 0
                cell.textMessage.sizeToFit()
                cell.userName.setTitle(self.userActivitesItems[indexPath.row].actorName, forState: UIControlState.Normal)
                cell.userName.setTitleColor(Color.PINK, forState: UIControlState.Normal)
                //cell.userName.addTarget(self, action: "onClickActor:", forControlEvents: UIControlEvents.TouchUpInside)
                ImageUtil.displayPostImage(Int(self.userActivitesItems[indexPath.row].targetImage), imageView: cell.postImage)
                
                if (!viewStatus) {
                    cell.layer.backgroundColor = Color.IMAGE_LOAD_BG.CGColor
                }
                
                return cell
            case "FIRST_POST", "NEW_POST", "SOLD", "NEW_COMMENT":
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserActivity2", forIndexPath: indexPath) as! UserActivityType2ViewCell
                cell.contentMode = UIViewContentMode.Redraw
                cell.sizeToFit()
                cell.activityTime.text = NSDate(timeIntervalSince1970:Double(self.userActivitesItems[indexPath.row].createdDate) / 1000.0).timeAgo
                cell.textMessage.text = self.setMessageText(self.userActivitesItems[indexPath.row])
                cell.textMessage.numberOfLines = 0
                cell.textMessage.sizeToFit()
                ImageUtil.displayThumbnailProfileImage(Int(self.userActivitesItems[indexPath.row].actorImage), imageView: cell.profileImg)
                ImageUtil.displayPostImage(Int(self.userActivitesItems[indexPath.row].targetImage), imageView: cell.postImage)
                
                if (!viewStatus) {
                    cell.layer.backgroundColor = Color.IMAGE_LOAD_BG.CGColor
                }
                
                return cell

            default:
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserActivityType", forIndexPath: indexPath) as! UserActivityTypeViewCell
                ImageUtil.displayThumbnailProfileImage(Int(self.userActivitesItems[indexPath.row].actorImage), imageView: cell.profileImg)
                cell.contentMode = UIViewContentMode.Redraw
                cell.sizeToFit()
                
                cell.activityTime.text = NSDate(timeIntervalSince1970:Double(self.userActivitesItems[indexPath.row].createdDate) / 1000.0).timeAgo
                cell.textMessage.text = self.setMessageText(self.userActivitesItems[indexPath.row])
                cell.textMessage.numberOfLines = 0
                cell.textMessage.sizeToFit()
                
                if (!viewStatus) {
                    cell.layer.backgroundColor = Color.IMAGE_LOAD_BG.CGColor
                }
                
                return cell
        }
    }
    var currentIndex = 0
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.currentIndex = indexPath.row
        let item = self.userActivitesItems[indexPath.row]
        switch (item.activityType) {
            case "FIRST_POST", "NEW_POST", "NEW_COMMENT", "LIKED", "SOLD":
                ApiController.instance.getPostById(self.userActivitesItems[indexPath.row].target)
            default: break
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if ("FIRST_POST" == self.userActivitesItems[indexPath.row].activityType) {
            return CGSizeMake(self.view.bounds.width, 90)
        }
        return collectionViewCellSize!
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        collectionViewCellSize = CGSizeMake(self.view.bounds.width, 75)
    }
    
    func handleUserActivitiesData(resultDto: [ActivityVM]) {
        if (!resultDto.isEmpty) {
            if (self.userActivitesItems.count == 0) {
                self.userActivitesItems = resultDto
            } else {
                self.userActivitesItems.appendContentsOf(resultDto)
            }
            uiCollectionView.reloadData()
        } else {
            loadedAll = true
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
        
        if (self.userActivitesItems.isEmpty) {
            self.tipText.hidden = false
            self.uiCollectionView.hidden = true
        }
    }

    @IBAction func onClickPostImg(sender: AnyObject) {

        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! BaseActivityViewCell
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        ApiController.instance.getPostById(self.userActivitesItems[indexPath.row].target)
        
    }
    
    func setMessageText(item: ActivityVM) -> String {
        
        var message: String = ""
        switch (item.activityType) {
            case "FIRST_POST":
                message = Constants.ACTIVITY_FIRST_POST + item.targetName
            case "NEW_POST":
                message = Constants.ACTIVITY_NEW_POST + item.targetName
            case "NEW_COMMENT":
                message = Constants.ACTIVITY_COMMENTED + item.targetName
            case "LIKED":
                message = " " + Constants.ACTIVITY_LIKED
            case "FOLLOWED":
                message = Constants.ACTIVITY_FOLLOWED
            case "SOLD":
                message = Constants.ACTIVITY_SOLD
            case "NEW_GAME_BADGE":
                message = Constants.ACTIVITY_GAME_BADGE + item.targetName
            default: break
        }
        return message
        
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                ViewUtil.showActivityLoading(self.activityLoading)
                loading = true
                var feedOffset: Int64 = 0
                if (!self.userActivitesItems.isEmpty) {
                    feedOffset = ++activityOffSet
                }
                ApiController.instance.getUserActivities(feedOffset)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "userprofile_1" || identifier == "userprofile_2"
            || identifier == "userprofile_3" || identifier == "userprofile_4"){
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cSender = sender as! UIButton
        let vController = segue.destinationViewController as! UserProfileFeedViewController
        vController.hidesBottomBarWhenPushed = true
        if (segue.identifier == "userprofile_1"){
            let cell = cSender.superview?.superview as! UserActivityType2ViewCell
            let indexPath = self.uiCollectionView.indexPathForCell(cell)
            vController.userId = self.userActivitesItems[(indexPath?.row)!].actor
        } else if (segue.identifier == "userprofile_2"){
            let cell = cSender.superview?.superview as! UserActivityTypeViewCell
            let indexPath = self.uiCollectionView.indexPathForCell(cell)
            vController.userId = self.userActivitesItems[(indexPath?.row)!].actor
        } else if (segue.identifier == "userprofile_3" || segue.identifier == "userprofile_4"){
            let cell = cSender.superview?.superview as! UserActivityViewCell
            let indexPath = self.uiCollectionView.indexPathForCell(cell)
            vController.userId = self.userActivitesItems[(indexPath?.row)!].actor
        
        }
    }
    
    func clearActivities() {
        self.loading = false
        self.loadedAll = false
        self.userActivitesItems.removeAll()
        self.userActivitesItems = []
        self.activityOffSet = 0
    }
    
    func reload() {
        ViewUtil.showActivityLoading(self.activityLoading)
        clearActivities()
        ApiController.instance.getUserActivities(self.activityOffSet)
        self.loading = true
    }
    
    func handleNotificationSuccess(notifcationCounter: NotificationCounterVM) {
        ViewUtil.refreshNotifications((self.tabBarController?.tabBar)!, navigationItem: self.navigationItem)
    }
    
    func handleNotificationError(message: String) {
        NSLog(message)
    }
}
