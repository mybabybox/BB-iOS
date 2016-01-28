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
        /*SwiftEventBus.onMainThread(self, name: "userInfoSuccess") { result in
            // UI thread
            print(result.object)
            let resultDto: UserInfoVM = result.object as! UserInfoVM
            self.handleUserInfo(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "userInfoFailed") { result in
            // UI thread
            print(result.object)
            self.showLoginPage()
        }*/
        
        /*var sessionId: String! = SharedPreferencesUtil.getInstance().getUserAccessToken(SharedPreferencesUtil.User.ACCESS_TOKEN.rawValue)
        
        if ( sessionId != nil && sessionId != "") {
            constants.accessToken = sessionId!
            ApiControlller.apiController.getUserInfo()
        } else {
            //Modify later to pick this from SharedPreferences instead of reloading again.
            NSThread.sleepForTimeInterval(0.3)
            showLoginPage()
        }*/
        
        NSThread.sleepForTimeInterval(0.3)
        showLoginPage()
        
        // Do any additional setup after loading the view.
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
            constants.userInfo = resultDto!
            constants.accessToken = SharedPreferencesUtil.getInstance().getUserAccessToken(SharedPreferencesUtil.User.ACCESS_TOKEN.rawValue)
            SharedPreferencesUtil.getInstance().saveUserInfo(resultDto!)
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("LandingPageViewController") as! LandingPageViewController
            self.navigationController?.pushViewController(vController, animated: true)
            self.navigationController?.navigationBar.hidden = true
        } else {
            self.showLoginPage()
        }
        
    }
    
    func showLoginPage() {
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("LandingPageViewController") as! LandingPageViewController
        self.navigationController?.pushViewController(vController, animated: true)
        self.navigationController?.navigationBar.hidden = true
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
