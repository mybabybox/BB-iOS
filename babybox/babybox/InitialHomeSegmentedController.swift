//
//  InitialHomeSegmentedControllerViewController.swift
//  babybox
//
//  Created by Mac on 12/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
class InitialHomeSegmentedController: UIViewController {

    
    @IBOutlet weak var displayName: UIBarButtonItem!
    @IBOutlet weak var userImage: UIBarButtonItem!
    @IBOutlet weak var Sell: UIBarButtonItem!
    @IBOutlet weak var notifications: UIBarButtonItem!
    @IBOutlet weak var segController: UISegmentedControl!
    @IBOutlet weak var baseView: UIView!
    
    var exploreController : UIViewController?
    var followingController : UIViewController?
    
    @IBAction func logoutUser(sender: AnyObject) {
        print("logout user.")
        ApiControlller.apiController.logoutUser()
    }
    
    func handleLogout(result: String) {
        print("handleLogout")
        constants.accessToken = ""
        
        let vController = self.storyboard!.instantiateViewControllerWithIdentifier("loginController") as! ViewController
        self.navigationController?.pushViewController(vController, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.exploreController = storyboard.instantiateViewControllerWithIdentifier("HomeExploreViewController") as! HomeExploreViewController
        self.followingController = storyboard.instantiateViewControllerWithIdentifier("homefollowingViewController") as! HomeFollowingViewController
        
        self.segController.setDividerImage(UIImage(named: "front"), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
        //self.segController.remove
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        SwiftEventBus.onMainThread(self, name: "logoutSuccess") { result in
            // UI thread
            let resultDto: String = result.object as! String
            self.handleLogout(resultDto)
        }
        
        print("setting the background image for navbar")
        
    }
    
    
    override func viewDidAppear(animated: Bool){
        self.segController.selectedSegmentIndex = 0
        self.segAction(self.segController)
        //self.userName.text = constants.userInfo?.displayName
        
        let imagePath =  constants.imagesBaseURL + "/image/get-mini-profile-image-by-id/" + String(constants.userInfo?.id)
        let imageUrl  = NSURL(string: imagePath);
        let imageData = NSData(contentsOfURL: imageUrl!)
        if (imageData != nil) {
            dispatch_async(dispatch_get_main_queue(), {
                self.userImage.image = UIImage(data: imageData!)
            });
        }
        
        self.displayName.title = constants.userInfo?.displayName
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segAction(sender: AnyObject) {
        if(self.segController.selectedSegmentIndex == 0){
            self.followingController!.view.removeFromSuperview()
            self.baseView.addSubview(self.exploreController!.view)
            self.exploreController?.view.frame = CGRectMake(0, 0, self.baseView.bounds.width, self.baseView.bounds.height-20)
            
        }else{
            self.exploreController!.view.removeFromSuperview()
            self.baseView.addSubview(self.followingController!.view)
            self.followingController?.view.frame = CGRectMake(0, 0, self.baseView.bounds.width, self.baseView.bounds.height-20)
            
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let identifier = segue.identifier
        let navigationController = segue.destinationViewController as! UINavigationController
        print("identifier " + identifier!)
        if (identifier == "gotoUserProfile") {
            let vController = navigationController.viewControllers.first as! UserProfileViewController
            vController.userId = (constants.userInfo?.id)!
        }
        
    }
    

}
