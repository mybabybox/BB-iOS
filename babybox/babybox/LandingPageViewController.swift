//
//  LandingPageViewController.swift
//  babybox
//
//  Created by Mac on 06/12/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

import UIKit

class LandingPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        print("going to login..", terminator: "")
        return true
    }
}
