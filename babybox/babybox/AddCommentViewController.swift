//
//  AddCommentViewController.swift
//  BabyBox
//
//  Created by admin on 13/04/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class AddCommentViewController: UIViewController {

    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var postCommentBtn: UIButton!
    
    var postId: Int?
    var postedComment: CommentVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewUtil.displayRoundedCornerView(self.postCommentBtn, bgColor: Color.GRAY)
        self.commentText.placeholder = "Enter Comment"
        self.commentText.text = ""
        self.commentText.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickSaveBtn(sender: AnyObject) {
        if self.commentText.text!.isEmpty {
            ViewUtil.makeToast("Please enter a comment", view: self.view)
            return
        }
        ApiFacade.postComment(self.postId!, commentText: self.commentText.text!, successCallback: onSuccessAddComment, failureCallback: onFailure)
        
    }
    
    func onSuccessAddComment(response: String) {
        let _nComment = CommentVM()
        _nComment.ownerId = UserInfoCache.getUser()!.id
        _nComment.body = self.commentText.text!
        _nComment.ownerName = UserInfoCache.getUser()!.displayName
        _nComment.deviceType = "iOS"
        _nComment.createdDate = NSDate().timeIntervalSinceNow
        _nComment.id = -1
        self.postedComment = _nComment
        self.performSegueWithIdentifier("unwindToProductScreen", sender: self)
        
        /*let vController = self.storyboard!.instantiateViewControllerWithIdentifier("MessagesViewController") as! MessagesViewController
        vController.conversation = conversation
        vController.offered = true
        vController.offeredPrice = Double(self.commentText.text!)!
        ViewUtil.resetBackButton(self.navigationItem)
        ViewUtil.pushViewControllerAndPopSelf(vController, toPop: self)*/
        //unwind segue.
    }
    
    func onFailure(message: String) {
        ViewUtil.showDialog("Error", message: message, view: self)
    }

}
