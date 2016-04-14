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
    
    var offset: Int64 = 0
    var currentIndex: Int = 0
    var reuseIdentifier = "followingCollectionViewCell"
    var followersFollowings: [UserVMLite] = []
    var userId: Int = 0
    var collectionViewCellSize : CGSize?
    var optionType: String = ""
    var loadedAll: Bool = false
    var loading: Bool = false
    var headerView: NoItemsToolTipHeaderView?
    
    @IBAction func onClickFollowings(sender: AnyObject) {
        
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FollowingCollectionViewCell
        
        let indexPath = self.collectionView?.indexPathForCell(cell)
        let item = followersFollowings[indexPath!.row]
        
        if (self.followersFollowings[self.currentIndex].isFollowing) {
            ApiController.instance.unfollowUser(item.id)
            self.followersFollowings[self.currentIndex].isFollowing = false
            cell.followingsBtn.setTitle("Follow", forState: UIControlState.Normal)
            ViewUtil.displayRoundedCornerView(cell.followingsBtn, bgColor: Color.PINK)
        } else {
            ApiController.instance.followUser(item.id)
            self.followersFollowings[self.currentIndex].isFollowing = true
            cell.followingsBtn.setTitle("Following", forState: UIControlState.Normal)
            ViewUtil.displayRoundedCornerView(cell.followingsBtn, bgColor: Color.LIGHT_GRAY)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCollectionViewSizesInsets()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        SwiftEventBus.onMainThread(self, name: "userFollowersFollowingsSuccess") { result in
            // UI thread
            if (!ViewUtil.isEmptyResult(result)) {
                let resultDto: [UserVMLite] = result.object as! [UserVMLite]
                self.followersFollowings.appendContentsOf(resultDto)
                self.offset += 1
            } else {
                self.loadedAll = true
            }
            self.loading = false
            
            if (self.followersFollowings.isEmpty) {
                ViewUtil.registerNoItemsHeaderView(self.collectionView!)
            }
            self.collectionView?.reloadData()
        }
        
        SwiftEventBus.onMainThread(self, name: "userFollowersFollowingsFailed") { result in
        }
        
        self.loadFollowingFollowers()
        self.loading = true
        
        self.collectionView!.alwaysBounceVertical = true
        self.collectionView!.backgroundColor = Color.FEED_BG
        
        self.collectionView!.addPullToRefresh({ [weak self] in
            self?.reloadActivities()
        })
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
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
        return self.followersFollowings.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let userInfo = self.followersFollowings[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FollowingCollectionViewCell
        
        cell.userName.text = userInfo.displayName
        ImageUtil.displayThumbnailProfileImage(userInfo.id, imageView: cell.userImage)
        cell.followersCount.text = String(userInfo.numFollowers)
        
        if (userInfo.isFollowing) {
            ViewUtil.displayRoundedCornerView(cell.followingsBtn, bgColor: Color.LIGHT_GRAY)
            cell.followingsBtn.setTitle("Following", forState: UIControlState.Normal)
        } else {
            ViewUtil.displayRoundedCornerView(cell.followingsBtn, bgColor: Color.PINK)
            cell.followingsBtn.setTitle("Follow", forState: UIControlState.Normal)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewCellSize!
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }

    override func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionElementKindSectionHeader:
                var noItemText = ""
                switch optionType {
                    case "followingCalls":
                        noItemText = Constants.NO_FOLLOWINGS
                    case "followersCall":
                        noItemText = Constants.NO_FOLLOWERS
                    default: break
                }
                
                return ViewUtil.prepareNoItemsHeaderView(collectionView, indexPath: indexPath, noItemText: noItemText)
                default:
                assert(false, "Unexpected element kind")
        }
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = CGSizeMake(self.view.bounds.width , 60)
    }
    
    // MARK: UIScrollview Delegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                if self.followersFollowings.isEmpty {
                    return;
                }
                
                loading = true
                switch optionType {
                case "followingCalls":
                    ApiController.instance.getUserFollowings(self.userId, offset:Int64(self.followersFollowings[self.followersFollowings.count - 1].offset))
                case "followersCall":
                    ApiController.instance.getUserFollowers(self.userId, offset: Int64(self.followersFollowings[self.followersFollowings.count - 1].offset))
                default: break
                }
            }
        }
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "fUserProfile"){
                return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cSender = sender as! UIButton
        let vController = segue.destinationViewController as! UserProfileFeedViewController
        vController.hidesBottomBarWhenPushed = true
        if (segue.identifier == "fUserProfile"){
            let cell = cSender.superview?.superview as! FollowingCollectionViewCell
            let indexPath = self.collectionView!.indexPathForCell(cell)
            vController.userId = self.followersFollowings[(indexPath?.row)!].id
            ViewUtil.resetBackButton(self.navigationItem)
        }
    }
    
    func loadFollowingFollowers() {
        if ("followingCalls" == optionType) {
            ApiController.instance.getUserFollowings(self.userId, offset: offset)
            self.navigationItem.title = "Following"
        } else if ("followersCall" == optionType) {
            ApiController.instance.getUserFollowers(self.userId, offset: offset)
            self.navigationItem.title = "Followers"
        }
    }
    
    func clearlist() {
        self.loading = false
        self.loadedAll = false
        self.followersFollowings.removeAll()
        self.followersFollowings = []
        self.collectionView?.reloadData()
        self.offset = 0
    }
    
    func reloadActivities() {
        
        clearlist()
        self.loadFollowingFollowers()
        self.loading = true
        
    }
}
