//
//  FollowersFollowingViewController.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class FollowersFollowingViewController: UICollectionViewController {
    
    var offset: Int = 0
    var currentIndex: Int = 0
    var reuseIdentifier = "followingCollectionViewCell"
    var followersFollowings: [UserVM] = []
    var userId: Int = 0
    var collectionViewCellSize : CGSize?
    var optionType: String = ""
    
    @IBAction func onClickFollowings(sender: AnyObject) {
        
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FollowingCollectionViewCell
        
        //let indexPath = self.collectionView!.indexPathForCell(cell)
        
        if (self.followersFollowings[self.currentIndex].isFollowing) {
            ApiController.instance.unfollowUser((constants.userInfo.id))
            self.followersFollowings[self.currentIndex].isFollowing = false
            cell.followingsBtn.setTitle("+ Follow", forState: UIControlState.Normal)
            cell.followingsBtn.backgroundColor = ImageUtil.imageUtil.UIColorFromRGB(0xFF76A4)
        } else {
            ApiController.instance.followUser(constants.userInfo.id)
            self.followersFollowings[self.currentIndex].isFollowing = true
            cell.followingsBtn.setTitle("- Unfollow", forState: UIControlState.Normal)
            cell.followingsBtn.backgroundColor = ImageUtil.imageUtil.UIColorFromRGB(0xECECE6)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCollectionViewSizesInsets()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        SwiftEventBus.onMainThread(self, name: "userFollowersFollowingsSuccess") { result in
            // UI thread
            if (!ViewUtil.isEmptyResult(result)) {
                let resultDto: [UserVM] = result.object as! [UserVM]
                self.followersFollowings.appendContentsOf(resultDto)
                self.offset++
            }
            self.collectionView?.reloadData()
        }
        
        SwiftEventBus.onMainThread(self, name: "userFollowersFollowingsFailed") { result in
        }
        
        if ("followingCalls" == optionType) {
            ApiController.instance.getUserFollowings(self.userId, offset: offset)
            self.navigationItem.title = "Following"
        } else if ("followersCall" == optionType) {
            ApiController.instance.getUserFollowers(self.userId, offset: offset)
            self.navigationItem.title = "Followers"
        }
        
        // Do any additional setup after loading the view.
    }

    override func viewDidDisappear(_ animated: Bool) {
        SwiftEventBus.unregister(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.followersFollowings.count;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FollowingCollectionViewCell
        
        let userInfo = self.followersFollowings[indexPath.row]
        cell.userName.text = userInfo.displayName
        ImageUtil.displayThumbnailProfileImage(userInfo.id, imageView: cell.userImage)
        cell.followersCount.text = String(userInfo.numFollowers)
        
        if (userInfo.isFollowing) {
            cell.followingsBtn.backgroundColor = UIColor.grayColor()
            cell.followingsBtn.setTitle("- Unfollow", forState: UIControlState.Normal)
        } else {
            cell.followingsBtn.backgroundColor = ImageUtil.imageUtil.UIColorFromRGB(0xFF76A4)
            cell.followingsBtn.setTitle("+ Follow", forState: UIControlState.Normal)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewCellSize!
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.currentIndex = indexPath.row
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = self.followersFollowings[self.currentIndex].id
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController, animated: true)
        
    }

    func setCollectionViewSizesInsets() {
        collectionViewCellSize = CGSizeMake(self.view.bounds.width , 60)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
