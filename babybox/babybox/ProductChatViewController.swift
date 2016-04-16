//
//  ProductChatViewController.swift
//  BabyBox
//
//  Created by admin on 18/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class ProductChatViewController: UIViewController {
    
    @IBOutlet weak var postLayoutView: UIView!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    
    @IBOutlet weak var tipText: UILabel!
    @IBOutlet weak var postPrice: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var soldText: UILabel!
    @IBOutlet weak var sellText: UILabel!
    @IBOutlet weak var buyText: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var conversationTableView: UITableView!
    
    var conversations: [ConversationVM] = []
    
    var postItem: ConversationVM? = nil
    var loading: Bool = false
    var loadedAll: Bool = false
    var postId: Int = 0
    var viewCellIdentifier: String = "conversationsCollectionViewCell"
    var deleteCellIndex: NSIndexPath?
    var refreshControl = UIRefreshControl()
    var updateOpenedConversation = false
    var currentIndex: NSIndexPath?
    var lcontentSize = CGFloat(0.0)
    let DEFAULT_SEPERATOR_SPACING = CGFloat(5.0)
    let DEFAULT_TABLEVIEW_CELL_HEIGHT = CGFloat(70.0)
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if currentIndex != nil {
            let item = self.conversations[(currentIndex?.row)!]
            item.unread = 0
            self.conversations[(currentIndex?.row)!] = item
            self.conversationTableView.reloadRowsAtIndexPaths([currentIndex!], withRowAnimation: UITableViewRowAnimation.Automatic)
            currentIndex = nil
        }
        self.updateOpenedConversation = false
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.opaque = true
        self.navigationItem.title = NSLocalizedString("view_chat", comment: "")
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: Color.WHITE]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        ViewUtil.showActivityLoading(self.activityLoading)
        
        ApiFacade.getProductConversations(postId, successCallback: onSuccessGetProductConversation, failureCallback: onFailure)
        loading = true
        self.tipText.hidden = true
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.conversationTableView.addSubview(refreshControl)
        
        self.conversationTableView.separatorColor = Color.LIGHT_GRAY
        self.conversationTableView.separatorStyle = .SingleLine
        self.conversationTableView.tableFooterView = UIView(frame: CGRectZero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender:AnyObject) {
        self.tipText.hidden = true
        self.conversations.removeAll()
        ApiFacade.getProductConversations(postId, successCallback: onSuccessGetProductConversation, failureCallback: onFailure)
    }
    
    // MARK: UITableViewDataSource and Delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("conversationTableCell")! as! ConversationTableViewCell
        
        let item = self.conversations[indexPath.row]
        cell.productTitle.text = item.postTitle
        cell.userDisplayName.text = item.userName
        cell.contentMode = .Redraw
        cell.userComment.numberOfLines = 0
        cell.userComment.text = item.lastMessage
        self.lcontentSize = cell.userComment.frame.size.height
        cell.userComment.sizeToFit()
        
        cell.photoLayout.hidden = !item.lastMessageHasImage
        cell.unreadComments.text = String(item.unread)
        cell.photoLayout.backgroundColor = UIColor.clearColor()
        cell.unreadComments.hidden = true
        cell.layer.borderColor = UIColor.clearColor().CGColor
        cell.layer.backgroundColor = UIColor.clearColor().CGColor
        
        if currentIndex == nil {
            if item.unread > 0 {
                ViewUtil.displayCircularView(cell.unreadComments)
                cell.unreadComments.backgroundColor = Color.RED
                cell.layer.borderColor = Color.PINK.CGColor
                cell.layer.backgroundColor = Color.LIGHT_PINK_3.CGColor
                cell.unreadComments.hidden = false
            }
        }
        
        cell.comment.text = NSDate(timeIntervalSince1970:Double(item.lastMessageDate) / 1000.0).timeAgo
        ImageUtil.displayThumbnailProfileImage(self.conversations[indexPath.row].userId, imageView: cell.postImage)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return DEFAULT_TABLEVIEW_CELL_HEIGHT + self.lcontentSize + DEFAULT_SEPERATOR_SPACING
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("MessagesViewController") as? MessagesViewController
        let conversation = self.conversations[indexPath.row]
        vController?.conversation = conversation
        vController?.conversationViewController = self
        ViewUtil.resetBackButton(self.navigationItem)
        self.currentIndex = indexPath
        self.navigationController?.pushViewController(vController!, animated: true)
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteCellIndex = indexPath
            let conversationToDelete = self.conversations[indexPath.row]
            confirmDelete(conversationToDelete)
        }
    }
    
    func confirmDelete(conversation: ConversationVM) {
        let alert = UIAlertController(title: NSLocalizedString("delete_conversation_msg", comment: ""), message: "Are you sure you want to delete \(conversation.userName):\(conversation.postTitle)?", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .Destructive, handler: handleDeleteConversation)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: cancelDeleteConversation)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleDeleteConversation(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteCellIndex {
            ApiFacade.deleteConversation(self.conversations[indexPath.row].id, successCallback: onSuccessDeleteConversation, failureCallback: onFailure)
        }
    }
    
    func cancelDeleteConversation(alertAction: UIAlertAction!) {
        deleteCellIndex = nil
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    func onFailure(message: String) {
        ViewUtil.showDialog(NSLocalizedString("error", comment: ""), message: message, view: self)
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func onSuccessGetProductConversation(_conversations: [ConversationVM]) {
        if (!_conversations.isEmpty) {
            if (postItem == nil) {
                postItem = _conversations[0]
                self.renderPostView()
            }
            self.conversations.appendContentsOf(_conversations)
            self.conversationTableView.reloadData()
        } else {
            loadedAll = true
            if (conversations.count <= 0) {
                self.tipText.hidden = false
                self.conversationTableView.hidden = true
            }
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
        self.refreshControl.endRefreshing()
    }
    
    func onSuccessDeleteConversation(responseString: String) {
        self.conversations.removeAtIndex((deleteCellIndex?.row)!)
        //self.conversationTableView.deleteRowsAtIndexPaths([deleteCellIndex!], withRowAnimation: .Automatic)
        if (conversations.count <= 0) {
            self.tipText.hidden = false
            self.conversationTableView.hidden = true
        }
        deleteCellIndex = nil
        self.conversationTableView.reloadData()
        self.view.makeToast(message: NSLocalizedString("confirm_delete_conversation", comment: ""))
    }
    
    func renderPostView() {
        self.postTitle.text = postItem?.postTitle
        self.postPrice.text = "\(Constants.CURRENCY_SYMBOL)\(String(stringInterpolationSegment: Int(postItem!.postPrice)))"
        ImageUtil.displayPostImage((postItem?.postImage)!, imageView: self.postImg);
        self.setConversationImageTag()
    }
    
    func setConversationImageTag() {
        if (postItem!.postSold) {
            self.soldText.hidden = false
        } else if (postItem!.postOwner){
            self.sellText.hidden = false
        } else {
            self.buyText.hidden = false
        }
    }
    
}
