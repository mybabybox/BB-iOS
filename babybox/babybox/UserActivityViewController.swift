//
//  UserActivityViewController.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class UserActivityViewController: CustomNavigationController {

    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    var activityOffSet: Int64 = 0
    var lastContentOffset: CGFloat = 0
    var userActivitesItems: [ActivityVM] = []
    var collectionViewCellSize : CGSize?
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        self.activityLoading.startAnimating()
        self.userActivitesItems = []
        ApiControlller.apiController.getUserActivities(activityOffSet)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
            
            let resultDto: PostModel = result.object as! PostModel
            
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("FeedProductViewController") as! FeedProductViewController
            vController.productModel = resultDto
            //ApiControlller.apiController.getProductDetails(String(resultDto.id))
            self.navigationController?.pushViewController(vController, animated: true)
            
        }
        
        SwiftEventBus.onMainThread(self, name: "postByIdLoadFailure") { result in
            // UI thread
            self.view.makeToast(message: "Error getting Post data.")
        }
        
        
        
        
        // Do any additional setup after loading the view.
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserActivity", forIndexPath: indexPath) as! UserActivityViewCell
        
        ImageUtil.displayThumbnailProfileImage(Int(self.userActivitesItems[indexPath.row].actorImage), imageView: cell.profileImg)
        
        self.setMessageText(self.userActivitesItems[indexPath.row], cell: cell)
        
        //var createdDt = NSDate(timeIntervalSinceNow: (self.userActivitesItems[indexPath.row].createdDate / 1000) )
        cell.activityTime.text = NSDate(timeIntervalSince1970:Double(self.userActivitesItems[indexPath.row].createdDate) / 1000.0).timeAgo
        //cell.message.lineBreakMode = NSLineBreakMode.ByWordWrapping
        //cell.message.numberOfLines = 0
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let item = self.userActivitesItems[indexPath.row]
        switch (item.activityType) {
            case "FIRST_POST", "NEW_POST", "NEW_COMMENT", "LIKED", "SOLD":
                ApiControlller.apiController.getPostById(self.userActivitesItems[indexPath.row].target)
            default: break
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
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
        }
        self.activityLoading.stopAnimating()
    }

    @IBAction func onClickActor(sender: AnyObject) {
        NSLog("onClickActor")
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! UserActivityViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = self.userActivitesItems[indexPath.row].actor
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController, animated: true)
        
    }
    
    @IBAction func onClickPostImg(sender: AnyObject) {
        NSLog("onClickPostImg")
        NSLog("onClickActor")
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! UserActivityViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)!
        ApiControlller.apiController.getPostById(self.userActivitesItems[indexPath.row].target)
        
    }
    
    func setMessageText(item: ActivityVM, cell: UserActivityViewCell) {
        var message: String = ""
        var userName: String = ""
        switch (item.activityType) {
            case "FIRST_POST":
                message = constants.ACTIVITY_FIRST_POST + item.targetName;
            case "NEW_POST":
                message = constants.ACTIVITY_NEW_POST + item.targetName;
            case "NEW_COMMENT":
                message = constants.ACTIVITY_COMMENTED + item.targetName;
            case "LIKED":
                userName = item.actorName
                message = "   " + constants.ACTIVITY_LIKED
            case "FOLLOWED":
                message = constants.ACTIVITY_FOLLOWED
            case "SOLD":
                message = constants.ACTIVITY_SOLD
            case "NEW_GAME_BADGE":
                message = constants.ACTIVITY_GAME_BADGE + item.targetName
            default: break
        }
        switch (item.activityType) {
            case "FIRST_POST", "NEW_POST", "NEW_COMMENT", "LIKED", "SOLD":
                // open product
                cell.userName.setTitle(userName, forState: UIControlState.Normal)
                cell.userName.setTitleColor(ImageUtil.getPinkColor(), forState: UIControlState.Normal)
                cell.userName.addTarget(self, action: "onClickActor:", forControlEvents: UIControlEvents.TouchUpInside)
                ImageUtil.displayPostImage(Int(item.targetImage), imageView: cell.postImage)
                cell.prodImg.hidden = false
                print(userName.characters.count)
                if (!userName.isEmpty) {
                    for _ in 0...userName.characters.count {
                        message = "  " + message
                    }
                }
            
            case "FOLLOWED":
                // open actor user
                cell.prodImg.hidden = true
            case "NEW_GAME_BADGE":
                // open game badges
                cell.prodImg.hidden = true
            default: break
        }
                cell.textMessage.text = message
                cell.textMessage.numberOfLines = 0
                cell.textMessage.sizeToFit()
        
        
        //cell.txtMessage.text = message
        //let nsString = cell.txtMessage.text! as NSString
        //let range = nsString.rangeOfString(userName)
        //let url = NSURL(string: "action://onClickActor1")!
        
        //cell.txtMessage.addLinkToURL(url, withRange: range)
        
    }
    
}
