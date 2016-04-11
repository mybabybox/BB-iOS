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
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forgotPasswordWebView.loadRequest(NSURLRequest(URL: NSURL(string: ForgotPasswordViewController.FORGET_PASSWORD_URL)!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
}
