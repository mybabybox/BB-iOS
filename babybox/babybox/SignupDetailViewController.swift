//
//  SignupDetailViewController.swift
//  babybox
//
//  Created by Mac on 08/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class SignupDetailViewController: BaseLoginViewController, UITextFieldDelegate, SSRadioButtonControllerDelegate {

    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var location: UIButton!
    
    let locationDropDown = DropDown()
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        ViewUtil.displayRoundedCornerView(self.submitBtn, bgColor: Color.PINK)
        
        var locs: [String] = []
        for (_, element) in DistrictCache.districts.enumerate() {
            locs.append(element.displayName)
        }
        self.locationDropDown.dataSource = locs
 
        self.locationDropDown.selectionAction = { [unowned self] (index, item) in
            self.location.setTitle(item, forState: .Normal)
        }
        
        self.locationDropDown.anchorView = self.location
        self.locationDropDown.bottomOffset = CGPoint(x: 0, y: self.location.bounds.height)
        self.locationDropDown.direction = .Top
    }

    func onSuccessSaveSignUpInfo(response: String) {
        self.postLogin()
    }
    
    override func onFailure(message: String?) {
        ViewUtil.showDialog("Login Error", message: message!, view: self)
        self.stopLoading()
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
    
    @IBAction func onClickSubmitBtn(sender: UIButton) {
        if isValid() {
            let location = DistrictCache.getDistrictByName(self.location.titleLabel!.text!)
            ApiFacade.saveSignUpInfo(self.displayName.text!, locationId: location!.id,
                                     successCallback: onSuccessSaveSignUpInfo, failureCallback: onFailure)
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
        } else if (self.location.titleLabel?.text == nil || self.location.titleLabel?.text == "- Select -") {
            self.view.makeToast(message: "Please select location", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
            isValidated = false
        }
        return isValidated
    }
}
