//
//  FbLoginViewController.swift
//  babybox
//
//  Created by Mac on 09/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftEventBus

class FbLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name: "onSuccessFbLogin") { result in
            // UI thread
            self.view.makeToast(message: "User Registered successfully!")
            
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("SignupDetailViewController") as! SignupDetailViewController
            self.navigationController?.pushViewController(vController, animated: true)
        }
        
        SwiftEventBus.onMainThread(self, name: "onFailedFbLogin") { result in
            // UI thread
            self.view.makeToast(message: "User Registration failed!")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loginWithFacebook() {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["public_profile"]) {
            (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            
            if (error != nil) {
                NSLog("User Logged In.")
                print(result)
                
                            } else if (result.isCancelled) {
                NSLog("User Cancelled")
            } else {
                NSLog("User Not Logged In.")
                print(result.token)
                constants.accessToken = result.token.tokenString
                ApiControlller.apiController.loginWithFacebook()
            }
        }
    }
}
