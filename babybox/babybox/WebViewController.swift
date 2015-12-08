//
//  WebViewController.swift
//  babybox
//
//  Created by Mac on 07/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    var resultString: String = ""
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        //super.viewDidLoad()
        webView.loadHTMLString(resultString, baseURL: nil)
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

}
