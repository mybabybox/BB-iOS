//
//  ProductDetailsViewController.swift
//  Baby Box
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus

class ProductDetailsViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var uiScrollView: UIScrollView!
    var productModel: PostModel = PostModel()
    
    
    var likeFlag: Bool = false
    var id: Double!
    
    var productInfo: [PostCatModel] = []
    
    var fromPage: String = ""
    var items: [String] = [] //comment items
    var category: CategoryModel?
    //handling back button from 3 different
   
    //@IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var postCommentButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField! = nil
    @IBOutlet weak var ownerNumFollowers: UILabel!
    @IBOutlet weak var ownerNumProducts: UILabel!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var onClickCancel: UIButton!
    @IBAction func onClickOk(sender: AnyObject) {
    }
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var onClickBack: UIBarButtonItem!
    @IBOutlet weak var commentTable: UITableView!
    
    @IBAction func onClickLikeOrUnlikeButton(sender: AnyObject) {
        
         let count = Int((self.likeCountLabel.text!))
        if(self.likeFlag == false){
            self.likeButton.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = true
            ApiControlller().likePost(String(Int(self.id)))
            self.likeCountLabel.text = String(count! + 1)
            
        }else{
            self.likeButton.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = false
            ApiControlller().unlikePost(String(Int(self.id)))
            self.likeCountLabel.text = String(count! - 1)
        }
    }

    
    override func viewDidAppear(animated: Bool) {
        print("Show the detail of selected product view.... ", terminator: "");
        print(productModel, terminator: "")
        
        self.productTitle.text = productModel.title
        self.productPrice.text = "\(constants.currencySymbol) \(String(stringInterpolationSegment: productModel.price))"
        self.likeCountLabel.text = String(productModel.numLikes)
        self.id = Double(productModel.id)
        self.ownerName.text = productModel.ownerName
        
        if(productModel.isLiked == false){
            self.likeButton.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = false
        }else {
            self.likeButton.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            self.likeFlag = true
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if (self.productModel.hasImage) {
                let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(self.productModel.images[0])
                let imageUrl  = NSURL(string: imagePath);
                let imageData = NSData(contentsOfURL: imageUrl!)
                print(imageUrl, terminator: "")
                dispatch_async(dispatch_get_main_queue(), {
                    if (imageData != nil) {
                        self.productImageView.image = UIImage(data: imageData!)
                    }
                });
            }
        })
        
    }
    
    /*override func viewDidLayoutSubviews() {
        self.uiScrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 2000)
    }*/
    
    override func viewDidLoad() {
        
        self.commentTextField.delegate=self
        self.commentTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.navigationController?.toolbar.hidden = true
        SwiftEventBus.onMainThread(self, name: "productDetailsReceivedSuccess") { result in
            // UI thread
            print("catch the event...............", terminator: "")
            let resultDto: [PostCatModel] = result.object as! [PostCatModel]
            print(resultDto, terminator: "")
            self.handleGetProductDetailsSuccess(resultDto)
        }
       
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    func handleGetProductDetailsSuccess(result: [PostCatModel]) {
        print("handling success...", terminator: "")
        for value in result {
            self.productInfo.append(value)
        }
        
        for comment in self.productInfo[0].latestComments {
                self.items.append(comment.body)
        }
        self.commentTable.reloadData()
        
        self.productDescriptionLabel.text = self.productInfo[0].body
        self.ownerNumProducts.text = String(self.productInfo[0].ownerNumProducts)
        self.ownerNumFollowers.text = String(self.productInfo[0].ownerNumFollowers)
    }
    
    @IBAction func postComment(sender: AnyObject) {
        print("comment is....", terminator: "")
        print(self.commentTextField.text, terminator: "")
        self.submitComment()
    }
    
    func submitComment() {
        self.items.append(self.commentTextField.text!)
        //print(self.items)
        
        self.commentTable.reloadData()
        
        ApiControlller().postComment(String(Int(self.id)), comment: self.commentTextField.text!)
        self.commentTextField.text = ""
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.commentTable.dequeueReusableCellWithIdentifier("cell")! 
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!", terminator: "")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    @IBAction func onClickBack(sender: AnyObject) {
        if self.fromPage == "homeexplore" {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("initialSegmentViewController") as! InitialHomeSegmentedController
            secondViewController.activeSegment = 0
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }else if self.fromPage == "homefollowing" {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("initialSegmentViewController") as! InitialHomeSegmentedController
            secondViewController.activeSegment = 1
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }else if self.fromPage == "categorydetails" {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("myCategoryDetailView") as! CategoryDetailsViewController
            secondViewController.categories = self.category!
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        
    }
    
    /*
    @IBOutlet weak var messageTableView: UITableView!
    var comments : [String]? = ["This is my first comments !!!", "This is my second comments !!!"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTableView.estimatedRowHeight = 300.0
        self.messageTableView.rowHeight = UITableViewAutomaticDimension
        self.messageTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch section {
        case 0:
            rows = 2
        case 1:
            rows = 2
        case 2:
            rows = (comments?.count)!+1
            
        default:
            rows = 1
        }
        return rows
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var reuseidentifier = ""
        switch indexPath.section {
        case 0:
            if indexPath.row == 0{
                reuseidentifier = "cell1"
            }else{
                reuseidentifier = "cell2"
            }
        case 1:
            reuseidentifier = ""
            if indexPath.row == 0{
                reuseidentifier = "cell3"
            }else{
                reuseidentifier = "cell4"
            }
        case 2:
            reuseidentifier = ""
            if indexPath.row != comments?.count{
                reuseidentifier = "mCell1"
            }else{
                reuseidentifier = "mCell2"
            }
        default:
            reuseidentifier = ""
        }
        if indexPath.section == 2 {
            let cell:MessageTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseidentifier, forIndexPath: indexPath) as!  MessageTableViewCell
            if indexPath.row == (comments?.count)! {
                cell.btnPostComments.tag = indexPath.row
                cell.btnPostComments.addTarget(self, action: "PostComments:", forControlEvents: UIControlEvents.TouchUpInside)
            }else{
                cell.lblComments.text = comments![indexPath.row]
                cell.btnDeleteComments.tag = indexPath.row
                cell.btnDeleteComments.addTarget(self, action: "DeleteComments:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            return cell
        }else{
            let cell:DetailsTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseidentifier, forIndexPath: indexPath) as!  DetailsTableViewCell
            cell.productImage.image
                = UIImage(named: "ic_accept")
            
            return cell
        }
        
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return nil
        }else{
            let returnedView = UIView(frame: CGRectMake(0, 0, self.messageTableView.bounds.width, 15.0))
            returnedView.backgroundColor = UIColor.darkGrayColor()
            return returnedView
        }
        
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.0
        }else{
            return 15.0
        }
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    //MARK: Button Press Events
    func DeleteComments(button: UIButton){
        comments?.removeAtIndex(button.tag)
        self.messageTableView.reloadData()
        self.messageTableView.contentInset =  UIEdgeInsetsZero
    }
    func PostComments(button: UIButton){
        let cell: MessageTableViewCell = button.superview!.superview as! MessageTableViewCell
        comments?.append(cell.txtEnterComments.text!)
        self.messageTableView.reloadData()
        cell.txtEnterComments.text = ""
        messageTableView.contentInset =  UIEdgeInsetsZero
    }
    //MARK: UITextfield Delegate
    func textFieldDidBeginEditing(textField: UITextField){
        self.messageTableView.contentInset =  UIEdgeInsetsMake(0, 0, 250, 0);
        self.messageTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: (comments?.count)!, inSection:2), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
    }
    */
}