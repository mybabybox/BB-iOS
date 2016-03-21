//
//  SignInOptionsViewController.swift
//  babybox
//
//  Created by Mac on 09/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit

class SignInOptionsViewController: BaseLoginViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func onClickBackButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func loginSuccess() {
        self.performSegueWithIdentifier("clickToLogin", sender: nil)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "clickToLogin" {
            return false
        }
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
