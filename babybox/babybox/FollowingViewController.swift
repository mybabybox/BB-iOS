//
//  FollowingViewController.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class FollowingViewController: UICollectionViewController {
    
    var pageOffSet: Int = 0
    var currentIndex: Int = 0
    var reuseIdentifier = "followingCollectionViewCell"
    var userFollowings: [UserVM] = []
    var userId: Int = 0
    
    @IBAction func onClickFollowings(sender: AnyObject) {
        
        
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FollowingCollectionViewCell
        
        //let indexPath = self.collectionView!.indexPathForCell(cell)
        
        if (self.userFollowings[self.currentIndex].isFollowing) {
            ApiControlller.apiController.unfollowUser((constants.userInfo.id))
            self.userFollowings[self.currentIndex].isFollowing = false
            
            cell.followingsBtn.setTitle("+ Follow", forState: UIControlState.Normal)
            cell.followingsBtn.backgroundColor = ImageUtil.imageUtil.UIColorFromRGB(0xFF76A4)
        } else {
            ApiControlller.apiController.followUser(constants.userInfo.id)
            self.userFollowings[self.currentIndex].isFollowing = true
            
            //let indexPath = NSIndexPath(forItem: self.currentIndex, inSection: 0)
            //let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as! FollowingCollectionViewCell
            cell.followingsBtn.setTitle("- Unfollow", forState: UIControlState.Normal)
            cell.followingsBtn.backgroundColor = UIColor.grayColor()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getUserFollowings
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        SwiftEventBus.onMainThread(self, name: "userFollowingsSuccess") { result in
            // UI thread
            let resultDto: [UserVM] = result.object as! [UserVM]
            self.userFollowings.appendContentsOf(resultDto)
            self.pageOffSet++
            self.collectionView?.reloadData()
            
        }
        
        SwiftEventBus.onMainThread(self, name: "userFollowingsFailed") { result in
            // UI thread
            //TODO
        }
        
        //TODO...
        ApiControlller.apiController.getUserFollowings(self.userId, offSet: pageOffSet)
        // Do any additional setup after loading the view.
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
        return self.userFollowings.count;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FollowingCollectionViewCell
        
        let userInfo = self.userFollowings[indexPath.row]
        cell.userName.text = userInfo.displayName + String(userInfo.id)
        let imagePath =  constants.imagesBaseURL + "/image/get-mini-profile-image-by-id/" + String(userInfo.id)
        let imageUrl  = NSURL(string: imagePath);
        
        dispatch_async(dispatch_get_main_queue(), {
            cell.userImage.kf_setImageWithURL(imageUrl!)
        });
        if (userInfo.isFollowing) {
            cell.followingsBtn.backgroundColor = UIColor.grayColor()
            cell.followingsBtn.setTitle("- Unfollow", forState: UIControlState.Normal)
        } else {
            cell.followingsBtn.backgroundColor = ImageUtil.imageUtil.UIColorFromRGB(0xFF76A4)
            cell.followingsBtn.setTitle("+ Follow", forState: UIControlState.Normal)
        }
        
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //TODO - goto User Profile page for selected customer
        self.currentIndex = indexPath.row
        print("self.currentIndex" + String(self.currentIndex))
        self.performSegueWithIdentifier("gotoprofile", sender: nil)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "gotoprofile") {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier
        //let navigationController = segue.destinationViewController as! UINavigationController
        print(identifier)
        if (identifier == "gotoprofile") {
            //let vController = segue.destinationViewController as! UserProfileViewController
            //vController.userId = self.userFollowings[self.currentIndex].id
        }
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
