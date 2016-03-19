//
//  ProductNavigationController.swift
//  babybox
//
//  Created by admin on 19/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class ProductNavigationController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNavigationComponent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initNavigationComponent() {
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        let editProductImg: UIButton = UIButton()
        editProductImg.setTitle("Edit", forState: UIControlState.Normal)
        
        editProductImg.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        editProductImg.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        editProductImg.frame = CGRectMake(0, 0, 35, 35)
        editProductImg.addTarget(self, action: "onClickEditBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        let editProductBarBtn = UIBarButtonItem(customView: editProductImg)
        self.navigationItem.rightBarButtonItems = [editProductBarBtn]
        
        //self.navigationItem.leftItemsSupplementBackButton = true
        //self.navigationItem.leftBarButtonItems = []
        
    }
    
    func onClickEditBtn(sender: AnyObject?) {
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("editProductViewController")
        vController?.hidesBottomBarWhenPushed = true
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController!, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
