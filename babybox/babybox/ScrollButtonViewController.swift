//
//  ScrollButtonViewController.swift
//  BabyBox
//
//  Created by Anshul Gupta on 1/6/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class ScrollButtonViewController: UIViewController,UIScrollViewDelegate {

    var button1: UIButton? = nil
    var button2: UIButton? = nil
    var button3: UIButton?=nil
    
    var barView: UIView = UIView()
    
    
    @IBOutlet var changeTabBar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createButton1();
        createButton2();
        createButton3();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addFreind(sender: UIButton!){
        print("clicked...")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        //let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("Button1ViewController") as! Button1ViewController
        //self.presentViewController(nextViewController, animated:true, completion:nil)
    }
    func addFreind1(sender: UIButton!){
        print("clicked...")
    }
    func addFreind2(sender: UIButton!){
        print("clicked...")
    }
    
    func createButton1 () {
        self.button1 = UIButton();
        self.button1!.setTitle("Add1", forState: .Normal)
        self.button1!.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.button1!.frame = CGRectMake(10, 430, 46, 30)
        self.button1!.addTarget(self, action: "addFreind:", forControlEvents: UIControlEvents.TouchUpInside);
        self.barView.addSubview(button1!)
        self.view.addSubview(button1!);
        
    }
    
    func createButton2 () {
        button2 = UIButton();
        button2!.setTitle("Add2", forState: .Normal)
        button2!.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button2!.frame = CGRectMake(130, 430, 46, 30)
        self.button2!.addTarget(self, action: "addFreind1:", forControlEvents: UIControlEvents.TouchUpInside);
        self.barView.addSubview(button2!)
        //self.view.addSubview(button2!);
        self.view.addSubview(button2!);
    }
    
    func createButton3(){
        
        button3 = UIButton();
        button3!.setTitle("Add3", forState: .Normal)
        button3!.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button3!.frame = CGRectMake(250, 430, 46, 30)
        self.button3!.addTarget(self, action: "addFreind2:", forControlEvents: UIControlEvents.TouchUpInside);
        //self.barView.addSubview(button3!)
        self.barView.addSubview(button3!)
        self.view.addSubview(button3!);
        
        
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("here...")
        self.barView.hidden = true
        
    }
    
    func scrollViewDidEndDecelerating(scrollView:UIScrollView){
        print("here1111...")
        self.barView.hidden = false
    }
    
}