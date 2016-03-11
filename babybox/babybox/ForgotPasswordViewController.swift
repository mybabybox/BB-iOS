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

    @IBOutlet weak var forgotPassWebView: UIWebView!
    @IBOutlet weak var emailAddress: UITextField!
    var forwardToNextPage = false
    
    override func viewDidAppear(animated: Bool) {
        self.forwardToNextPage = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailAddress.delegate = self
        
        SwiftEventBus.onMainThread(self, name: "forgotPasswordSuccess") { result in
            // UI thread
            let resultDto: String = result.object as! String
            self.handleForgotPassword(resultDto)
        }
        
    }

    func handleForgotPassword(resultDto: String) {
        //self.forwardToNextPage = true
        //self.forgotPassWebView.loadHTMLString(resultDto, baseURL: nil)
        //self.performSegueWithIdentifier("showloginpage", sender: nil)
        
        let webViewController = self.storyboard?.instantiateViewControllerWithIdentifier("webViewController") as? WebViewController
        webViewController?.resultString = resultDto
        self.presentViewController(webViewController!, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        //call forgot password API call...
        
        if (self.emailAddress.text != "") {
            //make API call...
            ApiController.instance.forgotPasswordRequest(self.emailAddress.text!)
        } else {
        }
        return forwardToNextPage
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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

}
