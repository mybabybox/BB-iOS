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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.exploreController = storyboard.instantiateViewControllerWithIdentifier("HomeExploreViewController") as! HomeExploreViewController
        
        self.followingController = storyboard.instantiateViewControllerWithIdentifier("homefollowingViewController") as! HomeFollowingViewController
        
        //self.segController.setDividerImage(UIImage(named: "front"), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
        
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
        
        self.navigationController?.navigationBar.hidden = true
        
        self.baseView.addSubview(self.exploreController!.view)
        self.exploreController?.view.frame = CGRectMake(0, 0, self.baseView.bounds.width, self.baseView.bounds.height-20)
        
        self.baseView.addSubview(self.followingController!.view)
        self.followingController?.view.frame = CGRectMake(0, 0, self.baseView.bounds.width, self.baseView.bounds.height-20)
        
        let _tapGesture = UITapGestureRecognizer(target: self, action: "goToProfile:")
        let tapGesture = UITapGestureRecognizer(target: self, action: "goToProfile:")
        self.userName.addGestureRecognizer(_tapGesture)
        self.userImg.addGestureRecognizer(_tapGesture)
        //http://rshankar.com/uigesturerecognizer-in-swift/ swipe gesture
    
    }
    
    override func viewDidAppear(animated: Bool){
        self.segController.selectedSegmentIndex = 0
        self.segAction(self.segController)
            
        let imagePath =  constants.imagesBaseURL + "/image/get-mini-profile-image-by-id/" + String(constants.userInfo?.id)
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
        
        if(self.segController.selectedSegmentIndex == 0){
            //self.exploreController!.view.hidden = false
            //self.followingController!.view.hidden = true
            
//            self.bottomLayer?.removeFromSuperlayer()
//            //self.segController.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forState: UIControlState.Highlighted, barMetrics: UIBarMetrics.Default)
//            
//            self.bottomLayer = CALayer()
//            self.bottomLayer?.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [255/255, 118/255, 164/255, 1.0])
//            self.bottomLayer?.borderWidth = 3
//            
//            // Calculating frame
//            
//            let width = self.segController.frame.size.width/2
//            let x = self.topbarView.bounds.size.width/3
//            let y = self.segController.frame.size.height - (self.bottomLayer?.borderWidth)!
//            self.bottomLayer?.frame = CGRectMake(x, y,width, (self.bottomLayer?.borderWidth)!)
//            
//            self.segController.layer.addSublayer(self.bottomLayer!)
            
            let y = CGFloat(self.segController.frame.height)
            var start: CGPoint = CGPoint(x: 0, y: y)
            var end: CGPoint = CGPoint(x: self.segController.frame.size.width / 2 , y: y)

            var color: UIColor = UIColor(red: 255/255, green: 118/255, blue: 164/255, alpha: 1.0)
            self.drawLineFromPoint(start, toPoint: end, ofColor: color, inView: self.segController)
            

            self.followingController!.view.removeFromSuperview()
            self.baseView.addSubview(self.exploreController!.view)
            self.exploreController?.view.frame = CGRectMake(0, 0, self.baseView.bounds.width, self.baseView.bounds.height-20)
            
        } else{
            //self.exploreController!.view.hidden = true
            //self.followingController!.view.hidden = false
    
//            self.bottomLayer?.removeFromSuperlayer()
//            
//            self.bottomLayer = CALayer()
//            self.bottomLayer?.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [255/255, 118/255, 164/255, 1.0])
//            self.bottomLayer?.borderWidth = 3
//            
//            // Calculating frame
//            let width = self.segController.frame.size.width/3
//            let x = self.segController.frame.size.width/3;
//            let y = self.segController.frame.size.height - (self.bottomLayer?.borderWidth)!
//            self.bottomLayer?.frame = CGRectMake(x, y,width, (self.bottomLayer?.borderWidth)!)
//            
//            self.segController.layer.addSublayer(self.bottomLayer!)
    
            let y = CGFloat(self.segController.frame.height)
            var start: CGPoint = CGPoint(x: self.segController.frame.size.width / 2, y: y)
            var end: CGPoint = CGPoint(x: self.segController.frame.size.width, y: y)
            
            
            var color: UIColor = UIColor(red: 255/255, green: 118/255, blue: 164/255, alpha: 1.0)
            self.drawLineFromPoint(start, toPoint: end, ofColor: color, inView: self.segController)
            
            
            self.exploreController!.view.removeFromSuperview()
            self.baseView.addSubview(self.followingController!.view)
            self.followingController?.view.frame = CGRectMake(0, 0, self.baseView.bounds.width, self.baseView.bounds.height-20)
        }
    }
    
    var shapeLayer = CAShapeLayer()
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {
        //design the path
        var path = UIBezierPath()
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
        print("identifier " + identifier!)
        if (identifier == "gotoUserProfile_") {
            //let navigationController = segue.destinationViewController as! UINavigationController
            //print(segue.destinationViewController)
            //print(navigationController.viewControllers)
            let vController = segue.destinationViewController as! UserProfileViewController
            vController.userId = (constants.userInfo?.id)!
        } else if (identifier == "gotoUserProfile") {
            //let navigationController = segue.destinationViewController as! UINavigationController
            let vController = segue.destinationViewController as! UserProfileViewController
            vController.userId = (constants.userInfo?.id)!
        } else if (identifier == "gotouserchat") {
            let vController = segue.destinationViewController as! ConversionViewController
            vController.userId = (constants.userInfo?.id)!
        } else if (identifier == "sellProduct") {
        } else if (identifier == "badge") {
        }
    }
    
    func goToProfile(sender:UITapGestureRecognizer) {
        self.performSegueWithIdentifier("gotoUserProfile", sender: nil)
    }
    
    func goToProfile() {
        self.performSegueWithIdentifier("gotoUserProfile", sender: nil)
    }
}
