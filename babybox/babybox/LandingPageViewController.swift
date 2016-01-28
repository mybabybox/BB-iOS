//
//  LandingPageViewController.swift
//  babybox
//
//  Created by Mac on 06/12/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

import UIKit

class LandingPageViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var scrollVew: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollVew.pagingEnabled = true
        self.scrollVew.frame=CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        let scrollViewWidth:CGFloat = self.scrollVew.frame.width
        let scrollViewHeight:CGFloat = self.scrollVew.frame.height
        
        let tutorialImg_1 = UIImageView(frame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight))
        tutorialImg_1.image=UIImage(named:"Welcome_1")
        self.scrollVew.addSubview(tutorialImg_1)
        
        let tutorialImg_2 = UIImageView(frame:CGRectMake(scrollViewWidth, 0, scrollViewWidth, scrollViewHeight))
        tutorialImg_2.image=UIImage(named:"Welcome_2")
        self.scrollVew.addSubview(tutorialImg_2)
        
        let tutorialImg_3 = UIImageView(frame:CGRectMake(scrollViewWidth*2, 0, scrollViewWidth, scrollViewHeight))
        tutorialImg_3.image=UIImage(named:"Welcome_3")
        self.scrollVew.addSubview(tutorialImg_3)
        
        self.scrollVew.contentSize = CGSizeMake(self.scrollVew.frame.width * 6, self.scrollVew.frame.height)
        self.scrollVew.delegate = self
        self.pageControl.currentPage = 0
        
        let color = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF76A4).CGColor
        self.signUpBtn.backgroundColor = UIColor.clearColor()
        self.signUpBtn.layer.cornerRadius = 5
        self.signUpBtn.layer.borderWidth = 1
        self.signUpBtn.layer.borderColor = color
        
        self.loginBtn.layer.cornerRadius = 5
        self.loginBtn.layer.borderWidth = 1
        self.loginBtn.layer.borderColor = color
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        print("going to login..", terminator: "")
        return true
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print("inside scroll view .. ")
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
        var currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        print("current age")
        print(currentPage)
        if (currentPage > 2.0) {
            print("matched")
            currentPage = 0.0
        }
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage)
        // Change the text accordingly
        if Int(currentPage) == 0{
            //textView.text = "Sweettutos.com is your blog of choice for Mobile tutorials"
        }else if Int(currentPage) == 1{
            //textView.text = "I write mobile tutorials mainly targeting iOS"
        }else if Int(currentPage) == 2{
        }
    }
    
}
