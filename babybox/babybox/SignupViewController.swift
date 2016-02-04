//
//  SignupViewController.swift
//  babybox
//
//  Created by Mac on 02/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
class SignupViewController: UIViewController {
    
    @IBOutlet weak var firstNameText: UITextField!
    
    @IBOutlet weak var lastNameText: UITextField!

    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var confirmPasswordText: UITextField!
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
    }
    override func viewDidLoad() {
        self.navigationController?.navigationBar.hidden = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    @IBAction func onSignup(sender: AnyObject) {
        if(validateSignup()){
            
        }
    }
    
    func validateSignup() -> Bool {
        var isValidated = true
        
        if (self.firstNameText.text == nil || self.firstNameText.text == "" ) {
            self.view.makeToast(message: "Please fill first name", duration: 1.5, position: "bottom")
            isValidated = false
        }else if (self.lastNameText.text == nil || self.lastNameText.text == "" ) {
            self.view.makeToast(message: "Please fill last name", duration: 1.5, position: "bottom")
            isValidated = false
        }else if (self.emailText.text == nil || self.emailText.text == "" ) {
            self.view.makeToast(message: "Please fill email", duration: 1.5, position: "bottom")
            isValidated = false
        }else if (self.passwordText.text == nil || self.passwordText.text == "" ) {
            self.view.makeToast(message: "Please fill password", duration: 1.5, position: "bottom")
            isValidated = false
        }else if (self.confirmPasswordText.text == nil || self.confirmPasswordText.text == "" ) {
            self.view.makeToast(message: "Please fill confirm password", duration: 1.5, position: "bottom")
            isValidated = false
        }else if (self.confirmPasswordText.text != self.passwordText.text ) {
            self.view.makeToast(message: "Please fill password and confirm password same", duration: 1.5, position: "bottom")
            isValidated = false
        }
        
        return isValidated
    }
}