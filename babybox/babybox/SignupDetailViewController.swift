//
//  SignupDetailViewController.swift
//  babybox
//
//  Created by Mac on 08/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class SignupDetailViewController: UIViewController, UITextFieldDelegate, SSRadioButtonControllerDelegate {

    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var location: UIButton!
    
    let locationDropDown = DropDown()
    var locations: [LocationVM] = []
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        
        self.locations = DistrictCache.districts
        var locs: [String] = []
        for (index, element) in locations.enumerate() {
            locs.append(element.displayName)
        }
        self.locationDropDown.dataSource = locs
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = true
        
        SwiftEventBus.onMainThread(self, name: "saveSignInfoSuccess") { result in
            // UI thread
            self.view.makeToast(message: "User Registered successfully!")
        }
        
        SwiftEventBus.onMainThread(self, name: "saveSignInfoFailed") { result in
            self.view.makeToast(message: (result.object as? String)!)
        }
        
        self.locationDropDown.selectionAction = { [unowned self] (index, item) in
            self.location.setTitle(item, forState: .Normal)
        }
        
        self.locationDropDown.anchorView = self.location
        self.locationDropDown.bottomOffset = CGPoint(x: 0, y:self.location.bounds.height)
        self.locationDropDown.direction = .Top
        
        
    }

    override func viewDidLayoutSubviews() {
        //let contentSize = self.headingTxt.sizeThatFits(self.headingTxt.bounds.size)
       // var frame = self.headingTxt.frame
       // frame.size.height = contentSize.height
       // self.headingTxt.frame = frame
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
    
    @IBAction func saveSignUpInfo(sender: AnyObject) {
        var locationId = 0.0
        for (index, element) in locations.enumerate() {
            if (self.location.titleLabel?.text == element.displayName) {
                locationId = element.id
            }
        }
        
        if (isValid()) {
            ApiController.instance.saveUserSignUpInfo(self.displayName.text!, locationId: Int(locationId))
        } else {

        }
    }
    
    @IBAction func ShoworDismiss(sender: AnyObject) {
        if self.locationDropDown.hidden {
            self.locationDropDown.show()
        } else {
            self.locationDropDown.hide()
        }
    }
    
    func isValid() -> Bool {
        var isValidated = true
        if (self.displayName.text == nil || self.displayName.text == "") {
            self.view.makeToast(message: "Please enter displayname", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        } else if (self.location.titleLabel?.text == nil || self.location.titleLabel?.text == "Area") {
            self.view.makeToast(message: "Please select location", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        }
        return isValidated
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        var status: Bool = false
        if (identifier == "completesignup") {
            var locationId = 0.0
            for (index, element) in locations.enumerate() {
                if (self.location.titleLabel?.text == element.displayName) {
                    locationId = element.id
                }
            }
            
            if (isValid()) {
                ApiController.instance.saveUserSignUpInfo(self.displayName.text!, locationId: Int(locationId))
                status = true
            } else {
                status = false
            }
        }
        return status
    }
    
    //completesignup
}
