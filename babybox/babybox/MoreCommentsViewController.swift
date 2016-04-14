//
//  MoreCommentsViewController.swift
//  BabyBox
//
//  Created by admin on 13/04/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class MoreCommentsViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var tipText: UILabel!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var postCommentBtn: UIButton!
    var viewCellIdentifier: String = "commentTableCell"
    var refreshControl = UIRefreshControl()
    var deleteCellIndex: NSIndexPath?
    
    var comments: [CommentVM]? = []
    var collectionViewCellSize : CGSize?
    var loading: Bool = false
    var loadedAll: Bool = false
    var postId: Int = 0
    var offset: Int64 = 0
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewUtil.showActivityLoading(self.activityLoading)
        ViewUtil.displayRoundedCornerView(self.postCommentBtn, bgColor: Color.GRAY)
        self.commentText.placeholder = "Enter Comment"
        self.commentText.delegate = self
        
        ApiFacade.getComments(self.postId, offset: offset, successCallback: onSuccessGetComment, failureCallback: onFailureGetComments)
        
        self.loading = true
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.commentsTableView.addSubview(refreshControl)
        
        self.commentsTableView.separatorColor = Color.LIGHT_GRAY
        self.commentsTableView.separatorStyle = .SingleLine
        self.commentsTableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    // MARK: UITableViewDataSource and Delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(viewCellIdentifier)! as! CommentTableViewCell
        
        let comment = self.comments![indexPath.row]
        //ImageUtil.displayThumbnailProfileImage(comment.ownerId, imageView: cell.userImg)
        //cell.userName.text = comment.ownerName
        ImageUtil.displayThumbnailProfileImage(comment.ownerId, buttonView: cell.userImgBtn)
        
        cell.titleBtn.setTitle(comment.ownerName, forState: .Normal)
        cell.commentText.text = comment.body
        if (comment.id != -1) {
            cell.commentTime.text = NSDate(timeIntervalSince1970:Double(comment.createdDate) / 1000.0).timeAgo
        } else {
            cell.commentTime.text = NSDate(timeIntervalSinceNow: comment.createdDate / 1000.0).timeAgo
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*let vController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = self.comments![indexPath.row].ownerId
        self.navigationController?.pushViewController(vController, animated: true)*/
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.comments![indexPath.row].ownerId == UserInfoCache.getUser()!.id {
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteCellIndex = indexPath
            let commentToDelete = self.comments![indexPath.row]
            confirmDelete(commentToDelete)
        }
    }
    
    func confirmDelete(comment: CommentVM) {
        let alert = UIAlertController(title: "Delete Comment", message: "Are you sure you want to delete comment?", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteComment)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeleteComment)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleDeleteComment(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteCellIndex {
            ViewUtil.showGrayOutView(self, activityLoading: self.activityLoading)
            //ApiController.instance.deleteComment(self.comments![(indexPath.row)].id)
            ApiFacade.deleteComment(self.comments![(indexPath.row)].id, successCallback: onSuccessDeleteComment, failureCallback: onFailureDeleteComment)
        }
    }
    
    func cancelDeleteComment(alertAction: UIAlertAction!) {
        deleteCellIndex = nil
    }
    
    func refresh(sender:AnyObject) {
        offset = 0
        self.comments?.removeAll()
        ApiFacade.getComments(self.postId, offset: offset, successCallback: onSuccessGetComment, failureCallback: onFailureGetComments)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                ViewUtil.showActivityLoading(self.activityLoading)
                loading = true
                if (!self.comments!.isEmpty) {
                    self.offset += 1
                }
                ApiFacade.getComments(self.postId, offset: offset, successCallback: onSuccessGetComment, failureCallback: onFailureGetComments)
                
            }
        }
    }
    
    @IBAction func onClickSaveBtn(sender: AnyObject) {
        
        if self.commentText.text!.isEmpty {
            ViewUtil.makeToast("Please enter a comment", view: self.view)
            return
        }
        ApiFacade.postComment(self.postId, commentText: self.commentText.text!, successCallback: onSuccessAddComment, failureCallback: onFailureAddComment)
    }
    
    func onSuccessGetComment(_comments: [CommentVM]) {
        
        if (!_comments.isEmpty) {
            if (self.comments!.count == 0) {
                self.comments = _comments
            } else {
                self.comments!.appendContentsOf(_comments)
            }
            self.commentsTableView.reloadData()
        } else {
            loadedAll = true
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
        self.refreshControl.endRefreshing()
    }
    
    func onSuccessAddComment(response: String) {
        let _nComment = CommentVM()
        _nComment.ownerId = UserInfoCache.getUser()!.id
        _nComment.body = self.commentText.text!
        _nComment.ownerName = UserInfoCache.getUser()!.displayName
        _nComment.deviceType = "iOS"
        _nComment.createdDate = NSDate().timeIntervalSinceNow
        _nComment.id = -1
        self.comments!.append(_nComment)
        //self.comments!.sortInPlace({ $0.createdDate < $1.createdDate })
        self.commentText.text = ""
        self.commentsTableView.reloadData()
        //self.performSegueWithIdentifier("unwindToProductScreen", sender: self)
        
    }
    
    func onSuccessDeleteComment(response: String) {
        if self.deleteCellIndex != nil {
            self.comments?.removeAtIndex((self.deleteCellIndex?.row)!)
            self.commentsTableView.contentInset =  UIEdgeInsetsZero
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            self.commentsTableView.reloadData()
            self.view.makeToast(message: "Comment delete successfully", duration: ViewUtil.SHOW_TOAST_DURATION_SHORT, position: ViewUtil.DEFAULT_TOAST_POSITION)
        } else {
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
        }
        
        self.deleteCellIndex = nil
    }
    
    func onFailureGetComments(message: String) {
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
        ViewUtil.showDialog("Error", message: message, view: self)
    }
    
    func onFailureDeleteComment(message: String) {
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
        ViewUtil.showDialog("Error", message: message, view: self)
    }
    
    func onFailureAddComment(message: String) {
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
        ViewUtil.showDialog("Error", message: message, view: self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool { // called when 'return' key pressed. return NO to ignore.
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onClickUser(sender: AnyObject) {
        
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! CommentTableViewCell
        
        let indexPath = self.commentsTableView.indexPathForCell(cell)!
        
        let vController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = self.comments![indexPath.row].ownerId
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    
}
