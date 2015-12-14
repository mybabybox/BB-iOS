//
//  InitialHomeSegmentedControllerViewController.swift
//  babybox
//
//  Created by Mac on 12/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

class InitialHomeSegmentedController: UIViewController {

    @IBOutlet weak var displayName: UIBarButtonItem!
    @IBOutlet weak var userImage: UIBarButtonItem!
    @IBOutlet weak var Sell: UIBarButtonItem!
    @IBOutlet weak var notifications: UIBarButtonItem!
    @IBOutlet weak var segController: UISegmentedControl!
    @IBOutlet weak var baseView: UIView!
    
    var exploreController : UIViewController?
    var followingController : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.exploreController = storyboard.instantiateViewControllerWithIdentifier("HomeExploreViewController") as! HomeExploreViewController
        self.followingController = storyboard.instantiateViewControllerWithIdentifier("homefollowingViewController") as! HomeFollowingViewController
        
        self.segController.backgroundColor = UIColor.whiteColor()
        self.segController.
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
        } else {
            self.userImage.title = ""
        }
        print("----------------")
        print(constants.userInfo?.displayName)
        self.displayName.title = constants.userInfo?.displayName
        
        /*dispatch_async(dispatch_get_main_queue(), {
            self.userImage.image.kf_setImageWithURL(imageUrl!)
        });*/
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

}
