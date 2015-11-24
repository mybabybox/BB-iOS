//
//  ViewController.swift
//  Baby Box
//
//  Created by Anshul Gupta on 10/26/15.
//  Copyright (c) 2015 MIndNerves. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftEventBus

class ViewController: UIViewController,FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UITextField!
    
    @IBOutlet weak var passwordLabel: UITextField!
    
    var isUserLoggedIn = false
    let apiController =  ApiControlller();
    
    @IBAction func onClickSignUp(sender: AnyObject) {
        print(self.userNameLabel.text)
        print(self.passwordLabel.text)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        print(">>>>>>>>>>>>>>>>>>>>>>")
        print(identifier)
        if identifier == "clickToLogin" {
            if (userNameLabel.text!.isEmpty || passwordLabel.text!.isEmpty) {
                print("enter details....")
                
                let _errorDialog = UIAlertController(title: "Warning Message", message: "Please Enter UserName & Password", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);
                _errorDialog.addAction(okAction)
                self.presentViewController(_errorDialog, animated: true, completion: nil)
                return false;
            }
            
            
            
            //apiController.validateLogin(self.userNameLabel.text!, password: self.passwordLabel.text!);
            
            //apiController.authenticateUser("pitlawarkp@gmail.com", password: "pitlawarkp");
            apiController.authenticateUser(self.userNameLabel.text!, password: self.passwordLabel.text!);
        }
        
        return self.isUserLoggedIn
        
    }
    
    func handleUserLogin(resultDto: String) {
        self.isUserLoggedIn = true
        constants.accessToken = resultDto
        self.performSegueWithIdentifier("clickToLogin", sender: nil)
        //apiController.getUserInfo();
    }
    
    func handleUserLoginFailed(resultDto: String) {
        self.isUserLoggedIn = false
        //apiController.getUserInfo();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isUserLoggedIn = false
        ApiControlller.init();
        // Do any additional setup after loading the view, typically from a nib.
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedSuccess") { result in
            // UI thread
            print(result.object)
            let resultDto: String = result.object as! String
            print("here got the login result... " + resultDto);
            self.handleUserLogin(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "loginReceivedFailure") { result in
            // UI thread
            let resultDto: String = result.object as! String
            self.handleUserLoginFailed(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "getUserLoggedUserInfo") { result in
            // UI thread
            let resultDto: UserInfoModel = result.object as! UserInfoModel
            print(resultDto);
        }
        
        if(FBSDKAccessToken.currentAccessToken()==nil)
        {
            
            let loginButton=FBSDKLoginButton()
            self.view.addSubview(loginButton)
            
            loginButton.center=self.view.center
            loginButton.readPermissions=["public_profile","email","user_friends"]
            loginButton.delegate=self
            
            
            //println("Not logged in..")
        }
        else{
            
            print("Logged in..")
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error == nil) {
            print("Login Complete..", terminator: "")
            self.performSegueWithIdentifier("clickToLogin", sender: self)
        } else {
            print(error.localizedDescription, terminator: "")
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged out..", terminator: "")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        print("return key is pressed")
        return true;
    }
    
}

