//
//  File.swift
//  babybox
//
//  Created by Mac on 15/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus

class ConversationsViewController: UIViewController {

    @IBOutlet weak var conversatioTableView: UITableView!
    @IBOutlet weak var tipText: UILabel!
    
    var userId: Int = 0
    var currentIndex: Int = 0
    var viewCellIdentifier: String = "conversationsCollectionViewCell"
    var myDate: NSDate = NSDate()
    var collectionViewCellSize : CGSize?
    var offset: Int64 = 0
    var loading: Bool = false
    var loadedAll: Bool = false
    var updateOpenedConversation = false
    var deleteCellIndex: NSIndexPath?
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    
    override func viewDidAppear(animated: Bool) {
        if self.updateOpenedConversation && ConversationCache.openedConversation != nil {
            ConversationCache.update(ConversationCache.openedConversation!.id, successCallback: handleUpdateConversationSuccess, failureCallback: nil)
        }
        self.updateOpenedConversation = false
        self.myDate = NSDate()
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func handleUpdateConversationSuccess(conversation: ConversationVM) {
        //collectionView.reloadData()
        self.conversatioTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.opaque = true
        self.navigationItem.title = "Chats"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: Color.WHITE]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        ViewUtil.showActivityLoading(self.activityLoading)
        
        ConversationCache.load(offset, successCallback: handleGetConversationsSuccess, failureCallback: handleError)
        
        loading = true
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.conversatioTableView.addSubview(refreshControl)
        
        self.conversatioTableView.separatorColor = Color.LIGHT_GRAY
        self.conversatioTableView.separatorStyle = .SingleLine
    }
    
    func refresh(sender:AnyObject) {
        offset = 0
        ConversationCache.load(offset, successCallback: handleGetConversationsSuccess, failureCallback: handleError)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NotificationCounter.mInstance.refresh(handleNotificationSuccess, failureCallback: handleNotificationError)
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
        
        // buy sell sold tag
        cell.soldText.hidden = !item.postSold
        cell.BuyText.hidden = !item.postSold && item.postOwner
        cell.SellText.hidden = !item.postSold && !item.postOwner
        
        cell.photoLayout.hidden = !item.lastMessageHasImage
        cell.unreadComments.text = String(item.unread)
        
        cell.unreadComments.hidden = true
        cell.layer.borderColor = UIColor.clearColor().CGColor
        cell.layer.backgroundColor = UIColor.clearColor().CGColor
        
        if(item.unread > 0) {
            //cell.unreadComments.layer.cornerRadius = cell.unreadComments.frame.height / 2
            //cell.unreadComments.layer.masksToBounds = true
            ViewUtil.displayCircularView(cell.unreadComments)
            cell.unreadComments.backgroundColor = Color.RED
            cell.layer.borderColor = Color.PINK.CGColor
            cell.layer.backgroundColor = Color.LIGHT_PING_3.CGColor
            cell.unreadComments.hidden = false
        }
        cell.comment.text = NSDate(timeIntervalSince1970:Double(item.lastMessageDate) / 1000.0).timeAgo
        ImageUtil.displayPostImage(ConversationCache.conversations[indexPath.row].postImage, imageView: cell.productImage)
        ImageUtil.displayThumbnailProfileImage(ConversationCache.conversations[indexPath.row].userId, imageView: cell.postImage)
        
        let cSelector = Selector("removeCell:")
        let UpSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
        UpSwipe.direction = UISwipeGestureRecognizerDirection.Left
        cell.addGestureRecognizer(UpSwipe)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("MessagesViewController") as? MessagesViewController
        let conversation = ConversationCache.conversations[indexPath.row]
        vController?.conversation = conversation
        vController?.conversationViewController = self
        ViewUtil.resetBackButton(self.navigationItem)
        ConversationCache.openedConversation = conversation
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
        let alert = UIAlertController(title: "Delete Conversation", message: "Are you sure you want to delete \(conversation.userName):\(conversation.postTitle)?", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteConversation)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeleteConversation)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleDeleteConversation(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteCellIndex {
            ConversationCache.delete(ConversationCache.conversations[indexPath.row].id, successCallback: deleteConversationHandler, failureCallback: deleteConversationError)
        }
    }
    
    func cancelDeleteConversation(alertAction: UIAlertAction!) {
        deleteCellIndex = nil
    }
    
    func handleGetConversationsSuccess(conversations: [ConversationVM]) {
        if (!conversations.isEmpty) {
            self.conversatioTableView.reloadData()
        } else {
            loadedAll = true
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
        
        if (ConversationCache.conversations.count <= 0) {
            self.tipText.hidden = false
            self.conversatioTableView.hidden = true
        }
        
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
                
                ConversationCache.load(offset, successCallback: handleGetConversationsSuccess, failureCallback: handleError)
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
        ConversationCache.load(offset, successCallback: handleGetConversationsSuccess, failureCallback: handleError)
        self.loading = true
    }
    
    func handleError(message: String) {
        ViewUtil.showDialog("Error", message: message, view: self)
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func handleNotificationSuccess(notifcationCounter: NotificationCounterVM) {
      //  ViewUtil.refreshNotifications((self.tabBarController?.tabBar)!, navigationItem: self.navigationItem)
    }
    
    func handleNotificationError(message: String) {
        NSLog(message)
    }
    
    func deleteConversationHandler(responseString: String) {
        self.conversatioTableView.deleteRowsAtIndexPaths([deleteCellIndex!], withRowAnimation: .Automatic)
        if (ConversationCache.conversations.count <= 0) {
            self.tipText.hidden = false
            self.conversatioTableView.hidden = true
        }
        deleteCellIndex = nil
        self.conversatioTableView.reloadData()
        //self.collectionView.reloadData()
        self.view.makeToast(message: "Conversation Deleted Successfully!")
    }
    
    func deleteConversationError(responseString: String) {
        NSLog("Error deleting Conversion", responseString)
        self.view.makeToast(message: "Error Deleting Conversation")
    }
    
}
