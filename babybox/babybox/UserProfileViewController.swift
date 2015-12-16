//
//  UserProfileViewController.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class UserProfileViewController: UIViewController {

    
    @IBOutlet weak var onClickBackButton: UIBarButtonItem!
    @IBOutlet weak var imageUpload: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followings: UIButton!
    @IBOutlet weak var followers: UIButton!
    
    var userId: Int = 0
    @IBAction func onClickBackButton(sender: AnyObject) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("userid " + String(self.userId))
        ApiControlller.apiController.getUserInfoById(userId)
        
        SwiftEventBus.onMainThread(self, name: "userInfoByIdSuccess") { result in
            // UI thread
            let resultDto: UserInfoVM = result.object as! UserInfoVM
            
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
            self.userName.text = resultDto.displayName
            
            if (constants.userInfo?.numFollowers > 0) {
                self.followers.setTitle("Followers " + String(resultDto.numFollowers), forState: UIControlState.Normal)
            } else {
                self.followers.setTitle("Followers", forState: UIControlState.Normal)
            }
            
            if (constants.userInfo?.numFollowings > 0) {
                self.followings.setTitle("Following " + String(resultDto.numFollowings), forState: UIControlState.Normal)
            } else {
                self.followings.setTitle("Following", forState: UIControlState.Normal)
            }
            
        }
        
        SwiftEventBus.onMainThread(self, name: "userInfoByIdFailed") { result in
            // UI thread
            //TODO
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var nController = segue.destinationViewController as! UINavigationController
        print(nController)
        if (segue.identifier == "followingCalls") {
            var vController = nController.viewControllers.first as! FollowingViewController
            vController.userId = userId
        } else if (segue.identifier == "followersCall") {
            var vController = nController.viewControllers.first as! FollowersViewController
            vController.userId = userId
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
