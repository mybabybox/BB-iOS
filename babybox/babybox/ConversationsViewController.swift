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

class ConversationsViewController: UIViewController, UIGestureRecognizerDelegate {

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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.opaque = true
        self.navigationItem.title = "Chats"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: Color.WHITE]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.setCollectionViewCellSize()
        
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 0.2
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(lpgr)
        
        ViewUtil.showActivityLoading(self.activityLoading)
        
        ConversationCache.load(offset, successCallback: handleGetConversationsSuccess, failureCallback: handleError)
        
        loading = true
        
        self.collectionView.addPullToRefresh({ [weak self] in
            self!.reload()
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        NotificationCounter.mInstance.refresh(handleNotificationSuccess, failureCallback: handleNotificationError)
        SwiftEventBus.unregister(self)
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ConversationCache.conversations.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewCellIdentifier, forIndexPath: indexPath) as! ConversationsCollectionViewCell
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
        if (item.postSold) {
            cell.soldText.hidden = !item.postSold
        } else {
            cell.BuyText.hidden = item.postOwner
            cell.SellText.hidden = !item.postOwner
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewCellSize!
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //self.currentIndex = indexPath.row
        //self.performSegueWithIdentifier("showConversationsDetails", sender: nil)
        
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("MessagesViewController") as? MessagesViewController
        let conversation = ConversationCache.conversations[indexPath.row]
        vController?.conversation = conversation
        vController?.conversationViewController = self
        ViewUtil.resetBackButton(self.navigationItem)
        ConversationCache.openedConversation = conversation
        self.navigationController?.pushViewController(vController!, animated: true)
    }
    
    func handleGetConversationsSuccess(conversations: [ConversationVM]) {
        if (!conversations.isEmpty) {
            self.collectionView.reloadData()
        } else {
            loadedAll = true
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
        
        if (ConversationCache.conversations.count <= 0) {
            self.tipText.hidden = false
            self.collectionView.hidden = true
        }
        
    }
    
    func setCollectionViewCellSize() {
        collectionViewCellSize = CGSizeMake(self.view.bounds.width, 80)
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                ViewUtil.showActivityLoading(self.activityLoading)
                loading = true
                if (!ConversationCache.conversations.isEmpty) {
                    offset = offset + 1 //Int64(self.conversations[self.conversations.count-1].unread)
                }
                
                ConversationCache.load(offset, successCallback: handleGetConversationsSuccess, failureCallback: handleError)
            }
        }
    }
    
    func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        
        if (gestureRecognizer.state != UIGestureRecognizerState.Ended){
            return
        }
        
        let p = gestureRecognizer.locationInView(self.collectionView)
        
        if let indexPath : NSIndexPath = (self.collectionView?.indexPathForItemAtPoint(p))!{
            //do whatever you need to do
            print("--")
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
    
    func removeCell(sender: UISwipeGestureRecognizer) {
        let cell = sender.view as! UICollectionViewCell
        let i = self.collectionView.indexPathForCell(cell)!.item
        //
        ConversationCache.delete(ConversationCache.conversations[i].id, successCallback: deleteConversationHandler, failureCallback: deleteConversationError)
        if (ConversationCache.conversations.count <= 0) {
            self.tipText.hidden = false
            self.collectionView.hidden = true
        }
    }
    
    func deleteConversationHandler(responseString: String) {
        self.collectionView.reloadData()
        self.view.makeToast(message: "Conversation Deleted Successfully!")
    }
    
    func deleteConversationError(responseString: String) {
        NSLog("Error deleting Conversion", responseString)
        self.view.makeToast(message: "Error Deleting Conversation")
    }
    
}
