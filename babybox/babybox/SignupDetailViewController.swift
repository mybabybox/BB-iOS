//
//  SignupDetailViewController.swift
//  babybox
//
//  Created by Mac on 08/02/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class SignupDetailViewController: UIViewController, UITextFieldDelegate, SSRadioButtonControllerDelegate {

    @IBOutlet weak var headingTxt: UITextView!
    @IBOutlet weak var noBaby: UIButton!
    @IBOutlet weak var fathers: UIButton!
    @IBOutlet weak var motherToBe: UIButton!
    @IBOutlet weak var children: NSLayoutConstraint!
    @IBOutlet weak var father: UIButton!
    @IBOutlet weak var mom: UIButton!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var location: UIButton!
    @IBOutlet weak var childrenList: UIButton!
    var radioButtonController: SSRadioButtonsController?
    let locationDropDown = DropDown()
    let childDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        self.locationDropDown.selectionAction = { [unowned self] (index, item) in
            self.location.setTitle(item, forState: .Normal)
        }
        self.locationDropDown.anchorView = self.location
        self.locationDropDown.bottomOffset = CGPoint(x: 0, y:self.location.bounds.height)
        self.locationDropDown.direction = .Top
        
        self.childDropDown.selectionAction = { [unowned self] (index, item) in
            self.childrenList.setTitle(item, forState: .Normal)
        }
        self.childDropDown.anchorView = self.childrenList
        self.childDropDown.bottomOffset = CGPoint(x: 0, y:self.childrenList.bounds.height)
        self.childDropDown.direction = .Top
        
        // Do any additional setup after loading the view.
        radioButtonController = SSRadioButtonsController(buttons: mom, father, motherToBe, fathers, noBaby)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        
        self.locationDropDown.dataSource = []
        
        //for index in 0...DistrictCache.getDistricts().count {
         //   self.locationDropDown.dataSource.append(DistrictCache.getDistricts()[0].displayName)
        //}
        
        self.childDropDown.dataSource = [
            "0", "1", "2", "3", "4", "More than 5"
        ]
        //self.location.layer.borderColor = UIColor.darkGrayColor().CGColor
        //self.location.layer.borderWidth = 1.0
        
        //self.childrenList.layer.borderColor = UIColor.darkGrayColor().CGColor
        //self.childrenList.layer.borderWidth = 1.0
        
    }

    override func viewDidLayoutSubviews() {
        //let contentSize = self.headingTxt.sizeThatFits(self.headingTxt.bounds.size)
       // var frame = self.headingTxt.frame
       // frame.size.height = contentSize.height
       // self.headingTxt.frame = frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSubmit(sender: AnyObject) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func ShoworDismiss(sender: AnyObject) {
        
        if self.locationDropDown.hidden {
            self.locationDropDown.show()
        } else {
            self.locationDropDown.hide()
        }
    }
}
