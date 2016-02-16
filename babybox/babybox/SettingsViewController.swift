//
//  SettingsViewController.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftEventBus

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        SwiftEventBus.onMainThread(self, name: "logoutSuccess") { result in
            // UI thread
            let resultDto: String = result.object as! String
            self.handleLogout(resultDto)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutUser(sender: AnyObject) {
        ApiControlller.apiController.logoutUser()
    }
    
    func handleLogout(result: String) {
        self.navigationController?.navigationBar.hidden = true
        constants.accessToken = ""
        SharedPreferencesUtil.getInstance().setUserAccessToken("")
        let vController = self.storyboard!.instantiateViewControllerWithIdentifier("loginController") as! LoginViewController
        self.navigationController?.pushViewController(vController, animated: true)
        if (constants.userInfo.isFBLogin) {
            FBSDKLoginManager().logOut()
        }
        constants.userInfo = UserInfoVM()
        SwiftEventBus.unregister(self)
        
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
