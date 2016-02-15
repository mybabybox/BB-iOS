//
//  LandingPageViewController.swift
//  babybox
//
//  Created by Mac on 06/12/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

import UIKit

class LandingPageViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.toolbar.hidden = true
        self.navigationController?.navigationBar.hidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let color = ImageUtil.imageUtil.UIColorFromRGB(0xFF76A4).CGColor
        self.signUpBtn.backgroundColor = UIColor.clearColor()
        ImageUtil.displayButtonRoundBorder(self.signUpBtn)
        self.signUpBtn.layer.borderColor = color
        
        ImageUtil.displayButtonRoundBorder(self.loginBtn)
        self.loginBtn.layer.borderColor = color
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        print("going to login..", terminator: "")
        if (identifier == "signup") {
            self.navigationController?.navigationBar.hidden = false
        }
        return true
    }
    
    
}
