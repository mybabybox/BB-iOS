//
//  EditProfileViewController.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    var userId = -1
    
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var editScrollView: UIScrollView!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var fbLoginIcon: UIImageView!
    @IBOutlet weak var location: UIButton!
    
    @IBOutlet weak var mbLoginIcon: UIImageView!
    @IBOutlet weak var submitBtn: UIButton!
    let locationDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeEditComponents()
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        var uiGesture = UITapGestureRecognizer(target: self, action: "scrollViewTouched")
        editScrollView.addGestureRecognizer(uiGesture)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeEditComponents() {
        
        let userInfo = UserInfoCache.getUser()
        if (userInfo!.isFBLogin) {
            self.fbLoginIcon.hidden = false
        } else {
            self.mbLoginIcon.hidden = false
        }
        
        self.email.text = userInfo?.email
        self.email.layer.borderColor = Color.RED.CGColor
        
        self.userName.delegate = self
        self.userName.text = userInfo?.displayName
        self.userName.layer.borderColor = Color.RED.CGColor
        
        self.firstName.delegate = self
        self.firstName.text = userInfo?.firstName
        self.firstName.layer.borderColor = Color.RED.CGColor
        
        self.lastName.delegate = self
        self.lastName.text = userInfo?.lastName
        self.lastName.layer.borderColor = Color.RED.CGColor
        
        self.desc.delegate = self
        self.desc.text = userInfo?.aboutMe
        self.desc.layer.borderColor = Color.RED.CGColor
        
        self.location.layer.borderColor = Color.RED.CGColor
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.editScrollView.contentSize.height += keyboardSize.height
    }
    
    @IBAction func ShoworDismiss(sender: AnyObject) {
        if self.locationDropDown.hidden {
            self.locationDropDown.show()
        } else {
            self.locationDropDown.hide()
        }
    }
    
    @IBAction func onClickSubmitBtn(sender: UIButton) {
        if isValid() {
            let location = DistrictCache.getDistrictByName(self.location.titleLabel!.text!)
            //ApiController.instance.saveSignUpInfo()
        }
    }
    
    func isValid() -> Bool {
        var isValidated = true
        return isValidated
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.editScrollView.contentSize.height = self.contentView.frame.height
    }
    
    func scrollViewTouched() {
        self.view.endEditing(true)
    }

}
