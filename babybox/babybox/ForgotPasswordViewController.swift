//
//  ForgotPasswordViewController.swift
//  babybox
//
//  Created by Mac on 07/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    static var FORGET_PASSWORD_URL: String = Constants.BASE_URL + "/login/password/forgot";
    
    @IBOutlet weak var forgotPasswordWebView: UIWebView!
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        ViewUtil.setCustomBackButton(self, action:"onBackPressed:")
        forgotPasswordWebView.loadRequest(NSURLRequest(URL: NSURL(string: ForgotPasswordViewController.FORGET_PASSWORD_URL)!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }

    func onBackPressed(sender: UIBarButtonItem) {
        /*let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let navController = app.window?.rootViewController as! UINavigationController
        //navController.popViewControllerAnimated(true)
        navController.popToRootViewControllerAnimated(true)*/
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(vController, animated: true)
    }
}
