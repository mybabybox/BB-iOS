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
    
    var productId: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewUtil.displayRoundedCornerView(self.saveOfferBtn, bgColor: Color.PINK)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickSaveBtn(sender: AnyObject) {
        //TODO - Logic for buy now button.
    }
}
