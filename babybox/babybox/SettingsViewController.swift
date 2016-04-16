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
    
    @IBOutlet weak var logOutBtn: UIButton!
    @IBOutlet weak var languageDropDown: UIButton!
    let languageTypeDropDown = DropDown()
    var currentLangValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name: "logoutSuccess") { result in
            // UI thread
            let resultDto: String = result.object as! String
            self.handleLogout(resultDto)
        }
        
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        ViewUtil.displayRoundedCornerView(logOutBtn, bgColor: Color.PINK)
        
        initLanguages()
        self.languageTypeDropDown.anchorView = languageDropDown
        self.languageTypeDropDown.bottomOffset = CGPoint(x: 0, y: languageDropDown.bounds.height)
        self.languageTypeDropDown.direction = .Top
        self.languageDropDown.titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.New, context: nil)
        
        setCurrentUserLanguage()
        self.languageDropDown.setTitle(self.currentLangValue, forState: .Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutUser(sender: AnyObject) {
        ApiController.instance.logoutUser()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "text" {
            
            if self.currentLangValue != self.languageDropDown.titleLabel!.text! {
                let _confirmDialog = UIAlertController(title: "", message: NSLocalizedString("confirm_lang_change", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    self.languageDropDown.setTitle(self.currentLangValue, forState: .Normal)
                })
                
                let confirmAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    let selLanguage = ViewUtil.parseLanguageFromValue(self.languageDropDown.titleLabel!.text!)
                    self.currentLangValue = self.languageDropDown.titleLabel!.text!
                    var lang = "en"
                    if selLanguage == ViewUtil.Languages.ZH {
                        lang = "zh-Hans"
                    }
                    
                    NSUserDefaults.standardUserDefaults().setObject([lang], forKey: "AppleLanguages")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                })
                
                _confirmDialog.addAction(okAction)
                _confirmDialog.addAction(confirmAction)
                self.presentViewController(_confirmDialog, animated: true, completion: nil)
            }
        }
    }
    func handleLogout(result: String) {
        AppDelegate.getInstance().logOut()
        let vController = self.storyboard!.instantiateViewControllerWithIdentifier("WelcomeViewController") as! WelcomeViewController
        self.navigationController?.pushViewController(vController, animated: true)
        SwiftEventBus.unregister(self)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        ViewUtil.resetBackButton(self.navigationItem)
    }
    
    func initLanguages() {
        self.languageTypeDropDown.dataSource = [
            ViewUtil.Languages.EN.rawValue,
            ViewUtil.Languages.ZH.rawValue
        ]
        
        dispatch_async(dispatch_get_main_queue(), {
            self.languageTypeDropDown.reloadAllComponents()
        })
        
        self.languageDropDown.setTitle(NSLocalizedString("select", comment: ""), forState: UIControlState.Normal)
        
        self.languageTypeDropDown.selectionAction = { [unowned self] (index, item) in
            self.languageDropDown.setTitle(item, forState: .Normal)
        }
    }
    
    @IBAction func ShoworDismiss(sender: AnyObject) {
        if self.languageTypeDropDown.hidden {
            self.languageTypeDropDown.show()
        } else {
            self.languageTypeDropDown.hide()
        }
    }
    
    func setCurrentUserLanguage() {
        let langs: NSArray = NSUserDefaults.standardUserDefaults().objectForKey("AppleLanguages")! as! NSArray
        let lang = langs.objectAtIndex(0) as? NSString
        if lang == "zh-Hans" {
            self.currentLangValue = ViewUtil.Languages.ZH.rawValue
        } else {
            self.currentLangValue = ViewUtil.Languages.EN.rawValue
        }
    }
}
