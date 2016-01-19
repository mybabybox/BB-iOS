//
//  CategoryDetailsViewController.swift
//  Baby Box
//
//  Created by Mac on 20/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus
import Kingfisher

class CategoryDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var categoryTips: UIView!
    @IBOutlet weak var popularBtnIns: UIButton!
    @IBOutlet weak var newestBtnIns: UIButton!
    @IBOutlet weak var lowToHighBtnIns: UIButton!
    @IBOutlet weak var highToLowBtnIns: UIButton!
    
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var catInfoView: UIView!
    
    var categories : CategoryModel = CategoryModel()
    var _controller: AbstractFeedViewController? = nil
    
    override func viewDidAppear(animated: Bool) {
        //self.popularBtnIns.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setSizesForFilterButtons()
        
        //Get the preferences for Explore Tip and if present hide the tip.
        self._controller = self.storyboard?.instantiateViewControllerWithIdentifier("abstractFeedController") as? AbstractFeedViewController
        if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.CATEGORY_TIPS)) {
            self.categoryTips.hidden = false
            _controller!.view.frame = CGRectMake(0, categoryTips.frame.height, self.view.frame.width, self.view.frame.height)
            SharedPreferencesUtil.getInstance().setScreenViewed(SharedPreferencesUtil.Screen.CATEGORY_TIPS)
        } else {
            self._controller!.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        }
        
        
        self._controller!.setFeedtype(FeedFilter.FeedType.CATEGORY_POPULAR)
        self._controller?.isHeaderView = true
        self._controller?.pageOffSet = 0
        self._controller?.selCategory = self.categories
        self.view.addSubview(self._controller!.view)
        self.navigationItem.hidesBackButton = true
        ApiControlller.apiController.getCategoriesFilterByPopularity(Int(categories.id), offSet: 0)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        let backImg: UIButton = UIButton()
        backImg.addTarget(self, action: "onClickBackBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        backImg.frame = CGRectMake(0, 0, 35, 35)
        backImg.layer.cornerRadius = 18.0
        backImg.layer.masksToBounds = true
        backImg.setImage(UIImage(named: "back"), forState: UIControlState.Normal)
        
        let sellBtn: UIButton = UIButton()
        sellBtn.setImage(UIImage(named: "new_post"), forState: UIControlState.Normal)
        sellBtn.addTarget(self, action: "onClickSellBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        sellBtn.frame = CGRectMake(0, 0, 35, 35)
        let sellBarBtn = UIBarButtonItem(customView: sellBtn)
        
        let backBarBtn = UIBarButtonItem(customView: backImg)
        self.navigationItem.leftBarButtonItems = [backBarBtn]
        self.navigationItem.rightBarButtonItems = [sellBarBtn]
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("view disappeared", terminator: "")
        
    }
    
    @IBAction func onClickPopular(sender: AnyObject) {
        _controller?.pageOffSet = 0
        _controller?.setFeedtype(FeedFilter.FeedType.CATEGORY_POPULAR)
        _controller?.products = []
        
        ApiControlller.apiController.getCategoriesFilterByPopularity(Int(categories.id), offSet: 0)
        self.setBtnBackgroundAndText()
        self.popularBtnIns.backgroundColor = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF99B8)
        self.popularBtnIns.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    @IBAction func onClickNewest(sender: AnyObject) {
        _controller?.pageOffSet = 0
        _controller?.setFeedtype(FeedFilter.FeedType.CATEGORY_NEWEST)
        _controller?.products = []
        
        ApiControlller.apiController.getCategoriesFilterByNewestPrice(Int(categories.id), offSet: 0)
        self.setBtnBackgroundAndText()
        self.newestBtnIns.backgroundColor = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF99B8)
        self.newestBtnIns.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    @IBAction func onClickLowToHl(sender: AnyObject) {
        _controller?.pageOffSet = 0
        _controller?.setFeedtype(FeedFilter.FeedType.CATEGORY_PRICE_LOW_HIGH)
        _controller?.products = []
        
        ApiControlller.apiController.getCategoriesFilterByLhPrice(Int(categories.id), offSet: 0)
        self.setBtnBackgroundAndText()
        self.lowToHighBtnIns.backgroundColor = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF99B8)
        self.lowToHighBtnIns.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    @IBAction func onClickHlToLow(sender: AnyObject) {
        _controller?.pageOffSet = 0
        _controller?.setFeedtype(FeedFilter.FeedType.CATEGORY_PRICE_HIGH_LOW)
        _controller?.products = []
        
        ApiControlller.apiController.getCategoriesFilterByHlPrice(Int(categories.id), offSet: 0)
        self.setBtnBackgroundAndText()
        self.highToLowBtnIns.backgroundColor = BabyboxUtils.babyBoxUtils.UIColorFromRGB(0xFF99B8)
        self.highToLowBtnIns.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func setBtnBackgroundAndText() {
        let red = CGFloat(255.0)
        let green = CGFloat(255.0)
        let blue = CGFloat(255.0)
        let alpha = CGFloat(1.0)
        
        self.highToLowBtnIns.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        self.lowToHighBtnIns.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        self.newestBtnIns.backgroundColor =  UIColor(red: red, green: green, blue: blue, alpha: alpha)
        self.popularBtnIns.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
        self.highToLowBtnIns.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        self.lowToHighBtnIns.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        self.newestBtnIns.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        self.popularBtnIns.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        
    }
    
    func setSizesForFilterButtons() {
        let availableWidthForButtons:CGFloat = self.view.bounds.width - 40
        let buttonWidth :CGFloat = availableWidthForButtons / 4
        let buttonHeight = CGFloat(25)
        let filterButtonSize = CGSizeMake(buttonWidth, buttonHeight)
        
        /*self.popularBtnIns.frame.size = filterButtonSize
        self.newestBtnIns.frame.size = filterButtonSize
        self.lowToHighBtnIns.frame.size = filterButtonSize
        self.highToLowBtnIns.frame.size = filterButtonSize*/
    }
    
    func onClickBackBtn(sender: AnyObject?) {
        let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("initialSegmentViewController") as! InitialHomeSegmentedController
        secondViewController.activeSegment = 0
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    func onClickSellBtn(sender: AnyObject?) {
        print("calling here...onClickSellBtn")
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("sellProductsViewController")
        self.navigationController?.pushViewController(vController!, animated: true)
    }
    
    @IBAction func onClickCloseTip(sender: AnyObject) {
        self.categoryTips.hidden = true
        _controller!.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
    }
}