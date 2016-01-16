//
//  InitialHomeSegmentedControllerViewController.swift
//  babybox
//
//  Created by Mac on 12/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus
import FBSDKLoginKit

class InitialHomeSegmentedController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    
    @IBOutlet weak var topbarView: UIView!
    @IBOutlet weak var segController: UISegmentedControl!
    @IBOutlet weak var baseView: UIView!
    var bottomLayer: CALayer? = nil
    var exploreController : UIViewController?
    var followingController : UIViewController?
    var activeSegment: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.grayColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(12.0)
        ]
        
        let activeTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(12.0)
        ]
        
        UISegmentedControl.appearance().setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        UISegmentedControl.appearance().setTitleTextAttributes(activeTextAttributes, forState: .Selected)
        
        
        let image = UIImage(named: "mn_home_sel")
        image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBarController?.tabBar.items![0].image = image
        self.tabBarController?.tabBar.hidden = false
        
        constants.viewControllerIns = self
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidAppear(animated: Bool) {
        self.segController.selectedSegmentIndex = self.activeSegment
        self.segAction(self.segController)
        
        let imagePath =  constants.imagesBaseURL + "/image/get-thumbnail-profile-image-by-id/" + String(constants.userInfo?.id)
        let imageUrl  = NSURL(string: imagePath);
        let imageData = NSData(contentsOfURL: imageUrl!)
        if (imageData != nil) {
            dispatch_async(dispatch_get_main_queue(), {
                self.userImg.image = UIImage(data: imageData!)
            });
        }
        self.userImg.layer.cornerRadius = 18.0
        self.userImg.layer.masksToBounds = true
        self.userName.text = constants.userInfo?.displayName
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func segAction(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if(self.segController.selectedSegmentIndex == 0){
            
            let y = CGFloat(self.segController.frame.height)
            let start: CGPoint = CGPoint(x: 0, y: y)
            let end: CGPoint = CGPoint(x: self.segController.frame.size.width / 2 , y: y)

            let color: UIColor = UIColor(red: 255/255, green: 118/255, blue: 164/255, alpha: 1.0)
            self.drawLineFromPoint(start, toPoint: end, ofColor: color, inView: self.segController)
            
            
            self.followingController?.view.removeFromSuperview()
            self.exploreController = storyboard.instantiateViewControllerWithIdentifier("HomeExploreViewController") as! HomeExploreViewController
            self.baseView.addSubview(self.exploreController!.view)
            self.exploreController!.view.frame = CGRectMake(0, 0, self.baseView.bounds.width, self.baseView.bounds.height-20)

            //self.followingController?.view.hidden = true
            //self.exploreController?.view.hidden = false
            
        } else if(self.segController.selectedSegmentIndex == 1){
            let y = CGFloat(self.segController.frame.height)
            let start: CGPoint = CGPoint(x: self.segController.frame.size.width / 2, y: y)
            let end: CGPoint = CGPoint(x: self.segController.frame.size.width, y: y)
            
            
            let color: UIColor = UIColor(red: 255/255, green: 118/255, blue: 164/255, alpha: 1.0)
            self.drawLineFromPoint(start, toPoint: end, ofColor: color, inView: self.segController)
            
            self.exploreController?.view.removeFromSuperview()
            self.followingController = storyboard.instantiateViewControllerWithIdentifier("homefollowingViewController") as! HomeFollowingViewController
            self.followingController!.view.frame = CGRectMake(0, 0, self.baseView.bounds.width, self.baseView.bounds.height-20)
            self.baseView.addSubview(self.followingController!.view)
            //self.followingController?.view.hidden = false
            //self.exploreController?.view.hidden = false
        }
    }
    
    var shapeLayer = CAShapeLayer()
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {
        //design the path
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addLineToPoint(end)

        //design path in layer
        
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = lineColor.CGColor
        shapeLayer.lineWidth = 3.0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let identifier = segue.identifier
        //let navigationController = segue.destinationViewController as! UINavigationController
        //print("identifier " + identifier!)
        if (identifier != nil && identifier == "gotoUserProfile_") {
            //let navigationController = segue.destinationViewController as! UINavigationController
            //print(segue.destinationViewController)
            //print(navigationController.viewControllers)
            let vController = segue.destinationViewController as! UserProfileViewController
            vController.userId = (constants.userInfo?.id)!
        } else if (identifier != nil && identifier == "gotoUserProfile") {
            //let navigationController = segue.destinationViewController as! UINavigationController
            let vController = segue.destinationViewController as! UserProfileViewController
            vController.userId = (constants.userInfo?.id)!
        } else if (identifier != nil && identifier == "gotouserchat") {
            let vController = segue.destinationViewController as! ConversationsViewController
            vController.userId = (constants.userInfo?.id)!
        } else if (identifier != nil && identifier == "sellProduct") {
        } else if (identifier != nil && identifier == "badge") {
        }
    }
    
    func goToProfile(sender:UITapGestureRecognizer) {
        self.performSegueWithIdentifier("gotoUserProfile", sender: nil)
    }
    
    func goToProfile() {
        self.performSegueWithIdentifier("gotoUserProfile", sender: nil)
    }
}
