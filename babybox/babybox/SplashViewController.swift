//
//  SplashViewController.swift
//  babybox
//
//  Created by Mac on 27/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        
        let sessionId: String? = SharedPreferencesUtil.getInstance().getUserAccessToken(SharedPreferencesUtil.User.ACCESS_TOKEN.rawValue)
        
        print(SharedPreferencesUtil.getInstance().getUserInfo())
        
        if ( sessionId != "nil") {
            constants.accessToken = sessionId!
            SwiftEventBus.onMainThread(self, name: "userInfoSuccess") { result in
                let resultDto: UserInfoVM = result.object as! UserInfoVM
                self.handleUserInfo_(resultDto)
            }
                
            SwiftEventBus.onMainThread(self, name: "userInfoFailed") { result in
                self.showLoginPage()
            }
            UserInfoCache.refresh()
            
        } else {
            //Modify later to pick this from SharedPreferences instead of reloading again.
            NSThread.sleepForTimeInterval(0.3)
            showLoginPage()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    func handleUserInfo_(resultDto: UserInfoVM?) {
        if (resultDto != nil) {
            self.navigationController?.navigationBar.hidden = true
            
            constants.accessToken = (SharedPreferencesUtil.getInstance().getUserAccessToken(SharedPreferencesUtil.User.ACCESS_TOKEN.rawValue) as? String)!
            constants.userInfo = resultDto!
            if (constants.userInfo.id == -1) {
            //invalid user
                SwiftEventBus.unregister(self)
                self.showLoginPage()
            } else {
                self.performSegueWithIdentifier("homefeed", sender: nil)
            }
            
            
        } else {
            self.showLoginPage()
        }
        
    }
    
    func showLoginPage() {
        /*let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("LandingPageViewController") as! LandingPageViewController
        self.navigationController?.pushViewController(vController, animated: true)
        */
        self.navigationController?.navigationBar.hidden = true
        self.performSegueWithIdentifier("loginpage", sender: nil)
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
