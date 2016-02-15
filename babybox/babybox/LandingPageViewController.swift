//
//  LandingPageViewController.swift
//  babybox
//
//  Created by Mac on 06/12/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

import UIKit

class LandingPageViewController: UIViewController {

    @IBOutlet weak var uiContainerView: UIView!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    //@IBOutlet weak var scrollVew: UIScrollView!
    //@IBOutlet var pageControl: UIPageControl!
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.toolbar.hidden = true
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        let storyboard = UIStoryboard(name: "CarouselStoryboard", bundle: nil)
        let vc : MVEmbeddedCarouselViewController = storyboard.instantiateInitialViewController() as! MVEmbeddedCarouselViewController
        
        vc.imageLoader = imageViewLoadFromPath
        vc.imagePaths = [
            "welcome_1",
            "welcome_2",
            "welcome_3"
        ]
        // Then, add to view hierarchy
        vc.addAsChildViewController(self, attachToView:self.uiContainerView)
        
        
        let color = ImageUtil.imageUtil.UIColorFromRGB(0xFF76A4).CGColor
        self.signUpBtn.backgroundColor = UIColor.clearColor()
        ImageUtil.displayButtonRoundBorder(self.signUpBtn)
        self.signUpBtn.layer.borderColor = color
        
        ImageUtil.displayButtonRoundBorder(self.loginBtn)
        self.loginBtn.layer.borderColor = color
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        print("going to login..", terminator: "")
        if (identifier == "signup") {
            self.navigationController?.navigationBar.hidden = false
        }
        return true
    }
    
    var imageViewLoadFromPath: ((imageView: UIImageView, imagePath : String, completion: (newImage: Bool) -> ()) -> ()) = {
        (imageView: UIImageView, imagePath : String, completion: (newImage: Bool) -> ()) in
        
        var url = NSURL(string: imagePath)
        var image = UIImage(named: imagePath)
        imageView.image = image
        //imageView.kf_setImageWithURL(url!)
        
    }
    
    var imageViewLoadCached : ((imageView: UIImageView, imagePath : String, completion: (newImage: Bool) -> ()) -> ()) = {
        (imageView: UIImageView, imagePath : String, completion: (newImage: Bool) -> ()) in
        
        imageView.image = UIImage(named:imagePath)
        completion(newImage: imageView.image != nil)
    }
}
