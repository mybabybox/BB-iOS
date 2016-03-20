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
        
        let whatsupBtn: UIButton = UIButton()
        whatsupBtn.setImage(UIImage(named: "ic_whatsapp"), forState: UIControlState.Normal)
        whatsupBtn.addTarget(self, action: "onClickWhatsupBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        whatsupBtn.frame = CGRectMake(0, 0, 35, 35)
        let whatsupBarBtn = UIBarButtonItem(customView: whatsupBtn)
    
        let facebookBtn: UIButton = UIButton()
        facebookBtn.setImage(UIImage(named: "ic_facebook"), forState: UIControlState.Normal)
        facebookBtn.addTarget(self, action: "onClickFacebookLinkBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        facebookBtn.frame = CGRectMake(0, 0, 35, 35)
        let facebookBarBtn = UIBarButtonItem(customView: facebookBtn)
        
        let copyLinkBtn: UIButton = UIButton()
        copyLinkBtn.setImage(UIImage(named: "ic_link_copy"), forState: UIControlState.Normal)
        copyLinkBtn.addTarget(self, action: "onClickCopyLinkBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        copyLinkBtn.frame = CGRectMake(0, 0, 35, 35)
        let copyLinkBarBtn = UIBarButtonItem(customView: copyLinkBtn)
    
        self.navigationItem.rightBarButtonItems = [copyLinkBarBtn, facebookBarBtn, whatsupBarBtn]
        
        //self.navigationItem.leftItemsSupplementBackButton = true
        //self.navigationItem.leftBarButtonItems = []
        
    }
    
    /*func onClickEditBtn(sender: AnyObject?) {
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("editProductViewController")
        vController?.hidesBottomBarWhenPushed = true
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController!, animated: true)
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
