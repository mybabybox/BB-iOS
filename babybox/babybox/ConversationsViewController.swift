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

    var userId: Int = 0
    var currentIndex: Int = 0
    var viewCellIdentifier: String = "conversationsCollectionViewCell"
    var conversations: [ConversationVM] = []
    var myDate: NSDate = NSDate()
    var id: Double!
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
        
        self.navigationItem.title = "Chats"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
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
            ViewUtil.showActivityLoading(self!.activityLoading)
            self!.reload()
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        NotificationCounter.mInstance.refresh()
        SwiftEventBus.unregister(self)
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewCellIdentifier, forIndexPath: indexPath) as! ConversationsCollectionViewCell
        if self.conversations.isEmpty {
            return cell
        }
        
        let item = self.conversations[indexPath.row]
        cell.productTitle.text = item.postTitle
        cell.userDisplayName.text = item.userName
        cell.contentMode = .Redraw
        cell.userComment.numberOfLines = 0
        cell.userComment.text = item.lastMessage
        cell.userComment.sizeToFit()
        
        if item.postOwner == false {
            cell.BuyText.hidden = true
            cell.SellText.hidden=false
            
        } else if(item.postOwner == true){
            cell.SellText.hidden = true
            cell.BuyText.hidden = false
        }
        
        cell.comment.text = NSDate(timeIntervalSince1970:Double(item.lastMessageDate) / 1000.0).timeAgo
        ImageUtil.displayPostImage(self.conversations[indexPath.row].postImage, imageView: cell.productImage)
        ImageUtil.displayThumbnailProfileImage(self.conversations[indexPath.row].userId, imageView: cell.postImage)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewCellSize!
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //self.currentIndex = indexPath.row
        //self.performSegueWithIdentifier("showConversationsDetails", sender: nil)
        
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("MessagesViewController") as? MessagesViewController
        let conversation = self.conversations[indexPath.row]
        vController?.conversation = conversation
        vController?.conversationViewController = self
        ViewUtil.resetBackButton(self.navigationItem)
        ConversationCache.openedConversation = conversation
        self.navigationController?.pushViewController(vController!, animated: true)
    }
    
    func handleGetConversationsSuccess(conversation: [ConversationVM]) {
        
        if (!conversation.isEmpty) {
            if (self.conversations.count == 0) {
                self.conversations = conversation
            } else {
                self.conversations.appendContentsOf(conversation)
            }
            self.collectionView.reloadData()
        } else {
            loadedAll = true
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
        
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
                if (!self.conversations.isEmpty) {
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
    
    func clearActivities() {
        self.loading = false
        self.loadedAll = false
        self.conversations.removeAll()
        self.conversations = []
        self.offset = 0
    }
    
    func reload() {
        ViewUtil.showActivityLoading(self.activityLoading)
        clearActivities()
        ConversationCache.load(offset, successCallback: handleGetConversationsSuccess, failureCallback: handleError)
        self.loading = true
    }
    
    func handleError(message: String) {
        ViewUtil.showDialog("Error", message: message, view: self)
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
}
