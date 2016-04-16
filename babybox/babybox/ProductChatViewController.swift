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
    
    var collectionViewCellSize : CGSize?
    var postItem: ConversationVM? = nil
    var loading: Bool = false
    var loadedAll: Bool = false
    var postId: Int = 0
    var viewCellIdentifier: String = "conversationsCollectionViewCell"
    var deleteCellIndex: NSIndexPath?
    var refreshControl = UIRefreshControl()
    var updateOpenedConversation = false
    var offset: Int64 = 0
    var currentIndex: NSIndexPath?
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.updateOpenedConversation && ConversationCache.openedConversation != nil {
            ConversationCache.update(ConversationCache.openedConversation!.id, successCallback: onSuccessUpdateConversation, failureCallback: onFailure)
        }
        if currentIndex != nil {
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
        
        ConversationCache.load(offset, successCallback: onSuccessGetConversations, failureCallback: onFailure)
        
        loading = true
        
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
        offset = 0
        ConversationCache.load(offset, successCallback: onSuccessGetConversations, failureCallback: onFailure)
    }
    
    override func viewDidDisappear(animated: Bool) {
        SwiftEventBus.unregister(self)
    }
    
    // MARK: UITableViewDataSource and Delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConversationCache.conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("conversationTableCell")! as! ConversationTableViewCell
        
        if ConversationCache.conversations.isEmpty {
            return cell
        }
        
        let item = ConversationCache.conversations[indexPath.row]
        cell.productTitle.text = item.postTitle
        cell.userDisplayName.text = item.userName
        cell.contentMode = .Redraw
        cell.userComment.numberOfLines = 0
        cell.userComment.text = item.lastMessage
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
        ImageUtil.displayThumbnailProfileImage(ConversationCache.conversations[indexPath.row].userId, imageView: cell.postImage)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("MessagesViewController") as? MessagesViewController
        let conversation = ConversationCache.conversations[indexPath.row]
        vController?.conversation = conversation
        vController?.conversationViewController = self
        ViewUtil.resetBackButton(self.navigationItem)
        ConversationCache.openedConversation = conversation
        self.currentIndex = indexPath
        self.navigationController?.pushViewController(vController!, animated: true)
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteCellIndex = indexPath
            let conversationToDelete = ConversationCache.conversations[indexPath.row]
            confirmDelete(conversationToDelete)
        }
    }
    
    func confirmDelete(conversation: ConversationVM) {
        let alert = UIAlertController(title: NSLocalizedString("", comment: "delete_conversation_msg"), message: "Are you sure you want to delete \(conversation.userName):\(conversation.postTitle)?", preferredStyle: .ActionSheet)
        
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
            ConversationCache.delete(ConversationCache.conversations[indexPath.row].id, successCallback: onSuccessDeleteConversation, failureCallback: onFailure)
        }
    }
    
    func cancelDeleteConversation(alertAction: UIAlertAction!) {
        deleteCellIndex = nil
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                ViewUtil.showActivityLoading(self.activityLoading)
                loading = true
                if (!ConversationCache.conversations.isEmpty) {
                    offset = offset + 1
                }
                
                ConversationCache.load(offset, successCallback: onSuccessGetConversations, failureCallback: onFailure)
            }
        }
    }
    
    func clear() {
        self.loading = false
        self.loadedAll = false
        self.offset = 0
        ConversationCache.clear()
    }
    
    func reload() {
        clear()
        ConversationCache.load(offset, successCallback: onSuccessGetConversations, failureCallback: onFailure)
        self.loading = true
    }
    
    func onFailure(message: String) {
        ViewUtil.showDialog("Error", message: message, view: self)
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func onSuccessGetConversations(conversations: [ConversationVM]) {
        if (!conversations.isEmpty) {
            if (postItem == nil) {
                postItem = conversations[0]
                self.renderPostView()
            }
            self.conversationTableView.reloadData()
        } else {
            loadedAll = true
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
        
        if (ConversationCache.conversations.count <= 0) {
            self.tipText.hidden = false
            self.conversationTableView.hidden = true
        }
        //self.noResultHandler()
        self.refreshControl.endRefreshing()
    }
    
    func onSuccessUpdateConversation(conversation: ConversationVM) {
        //collectionView.reloadData()
        self.conversationTableView.reloadData()
    }
    
    func onSuccessDeleteConversation(responseString: String) {
        self.conversationTableView.deleteRowsAtIndexPaths([deleteCellIndex!], withRowAnimation: .Automatic)
        if (ConversationCache.conversations.count <= 0) {
            self.tipText.hidden = false
            self.conversationTableView.hidden = true
        }
        deleteCellIndex = nil
        self.conversationTableView.reloadData()
        //self.collectionView.reloadData()
        self.view.makeToast(message: NSLocalizedString("confirm_delete_conversation", comment: ""))
    }
    
    func noResultHandler() {
        if (self.conversations.isEmpty) {
            self.tipText.hidden = false
            self.postLayoutView.hidden = true
        }
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
