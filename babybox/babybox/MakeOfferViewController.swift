//
//  MakeOfferViewController.swift
//  BabyBox
//
//  Created by admin on 30/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class MakeOfferViewController: UIViewController {

    @IBOutlet weak var offerPrice: UITextField!
    @IBOutlet weak var saveOfferBtn: UIButton!
    
    var productInfo: PostVM? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewUtil.displayRoundedCornerView(self.saveOfferBtn, bgColor: Color.GRAY)
        self.offerPrice.keyboardType = .NumberPad
        self.offerPrice.placeholder = String(Int((self.productInfo!.price)))
        self.offerPrice.text = String(Int((self.productInfo!.price)))
        self.offerPrice.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickSaveBtn(sender: AnyObject) {
        if self.offerPrice.text!.isEmpty {
            ViewUtil.makeToast("Please make an offer", view: self.view)
            return
        }
        ConversationCache.open(self.productInfo!.id, successCallback: handleOpenConversationSuccess, failureCallback: handleError)
    }
    
    func handleOpenConversationSuccess(conversation: ConversationVM) {
        let vController = self.storyboard!.instantiateViewControllerWithIdentifier("MessagesViewController") as? MessagesViewController
        vController?.conversation = conversation
        vController?.offered = true
        vController?.offeredPrice = Double(self.offerPrice.text!)!
        ViewUtil.resetBackButton(self.navigationItem)
        
        self.navigationController?.pushViewController(vController!, animated: true)
        
	//remove this VC from navigation controller heirarchy to restrict user to come back to this VC when click on 
        //back button of next screen.
	
        var navControllers = self.navigationController?.viewControllers
        navControllers?.removeAtIndex((navControllers?.count)! - 2)
        self.navigationController?.viewControllers = navControllers!
        
    }
    
    func handleError(message: String) {
        ViewUtil.showDialog("Error", message: message, view: self)
    }
}
