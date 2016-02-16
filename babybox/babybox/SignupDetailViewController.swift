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
    var locations: [LocationModel] = []
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationController?.navigationBar.hidden = true
        if DistrictCache.getDistricts().count > 0 {
            locations = DistrictCache.getDistricts()
            self.refreshLocations()
        } else {
            DistrictCache.refresh()
        }
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
        
        SwiftEventBus.onMainThread(self, name: "getDistrictSuccess") { result in
            // UI thread
            //DistrictCache.set = result.object as? [LocationVM]
            self.locations = (result.object as? [LocationModel])!
            self.refreshLocations()
        }
        
        self.navigationController?.navigationBar.hidden = false
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
            ApiControlller.apiController.saveUserSignUpInfo(self.displayName.text!, locationId: Int(locationId))
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
    
    func refreshLocations() {
        if locations.count > 0 {
            var districtLocations : [String] = []
            for (_, element) in locations.enumerate() {
                districtLocations.append(element.displayName)
            }
            self.locationDropDown.dataSource = districtLocations
            self.locationDropDown.reloadAllComponents()
        }
    }
    
    func isValid() -> Bool {
        var isValidated = true
        if (self.displayName.text == nil || self.displayName.text == "") {
            self.view.makeToast(message: "Please enter displayname", duration: 1.5, position: "bottom")
            isValidated = false
        } else if (self.location.titleLabel?.text == nil || self.location.titleLabel?.text == "Area") {
            self.view.makeToast(message: "Please select location", duration: 1.5, position: "bottom")
            isValidated = false
        }
        return isValidated
        
    }
}
