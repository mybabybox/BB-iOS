//
//  FollowersViewController.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class FollowersViewController: UICollectionViewController {
    
    
    var pageOffSet: Int = 0
    var currentIndex: Int = 0
    var reuseIdentifier = "followersViewController"
    var userFollowers: [UserVM] = []
    var userId: Int = 0
    @IBAction func onClickFollowers(sender: AnyObject) {
        print("---")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name: "userFollowersSuccess") { result in
            // UI thread
            let resultDto: [UserVM] = result.object as! [UserVM]
            self.userFollowers.appendContentsOf(resultDto)
            self.pageOffSet++
            self.collectionView?.reloadData()
        }
        
        SwiftEventBus.onMainThread(self, name: "userFollowersFailed") { result in
            // UI thread
            //TODO
        }
        //TODO
        ApiControlller.apiController.getUserFollowers(self.userId, offSet: pageOffSet)
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
        return self.userFollowers.count;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FollowersCollectionViewCell
        let userInfo = self.userFollowers[indexPath.row]
        cell.userName.text = userInfo.displayName
        let imagePath =  constants.imagesBaseURL + "/image/get-mini-profile-image-by-id/" + String(userInfo.id)
        let imageUrl  = NSURL(string: imagePath);
        print(imageUrl)
        dispatch_async(dispatch_get_main_queue(), {
            cell.userImage.kf_setImageWithURL(imageUrl!)
        })
        
        if (userInfo.isFollowing) {
            cell.followingBtn.backgroundColor = UIColor.grayColor()
            cell.followingBtn.setTitle("- Unfollow", forState: UIControlState.Normal)
        } else {
            cell.followingBtn.backgroundColor = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF76A4)
            cell.followingBtn.setTitle("+ Follow", forState: UIControlState.Normal)
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //TODO - goto User Profile page for selected customer
        self.currentIndex = indexPath.row
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
        if (identifier == "gotoprofile") {
            let vController = segue.destinationViewController as! UserProfileViewController
            vController.userId = self.userFollowers[self.currentIndex].id
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
