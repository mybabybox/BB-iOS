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

class FbLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
        var fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["public_profile"], fromViewController: self) {
            (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            
            if (error != nil) {
                NSLog("User Logged In.")
                print(result)
            } else if (result.isCancelled) {
                NSLog("User Cancelled")
            } else {
                NSLog("User Not Logged In.")
            }
        }
    }
}
