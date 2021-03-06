//
//  WelcomeViewController.swift
//  babybox
//
//  Created by Mac on 06/12/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

import UIKit
import PhotoSlider

class WelcomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoSliderDelegate {

    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet var tableView:UITableView!
    
    var collectionView:UICollectionView!
    
    var images = [
        UIImage(named: "welcome_1")!,
        UIImage(named: "welcome_2")!,
        UIImage(named: "welcome_3")!
    ]
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.toolbarHidden = true
        self.navigationController?.navigationBarHidden = true

        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        let color = Color.PINK.CGColor
        self.signUpBtn.backgroundColor = Color.CLEAR

        ViewUtil.displayRoundedCornerView(self.loginBtn, bgColor: Color.PINK)
        ViewUtil.displayRoundedCornerView(self.signUpBtn)
        self.signUpBtn.layer.borderColor = color
        self.signUpBtn.setTitleColor(Color.PINK, forState: UIControlState.Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "signup") {
            self.navigationController?.navigationBar.hidden = false
        }
        return true
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell01")!
        
        self.collectionView = cell.viewWithTag(1) as! UICollectionView
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView.frame.size.height
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("hcell", forIndexPath: indexPath) as! ImageCollectionViewCell
        let imageView = cell.imageView
        imageView.image = self.images[indexPath.row]
        cell.pageControl.numberOfPages = self.images.count
        cell.pageControl.currentPage = indexPath.row
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.tableView.frame.size.width, height: self.tableView.frame.size.height)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: - PhotoSliderDelegate
    
    func photoSliderControllerWillDismiss(viewController: PhotoSlider.ViewController) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        let indexPath = NSIndexPath(forItem: viewController.currentPage, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
    }
}
