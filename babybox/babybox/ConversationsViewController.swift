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
class ConversationsViewController: CustomNavigationController {
    //showConversationsDetails
    var userId: Int = 0
    var currentIndex: Int = 0
    var viewCellIdentifier: String = "conversationsCollectionViewCell"
    var conversations: [ConversationVM] = []
    var myDate: NSDate = NSDate()
    var id: Double!
    @IBOutlet weak var productImage: UIImageView!
    
    //todo create instance of collectionview
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidAppear(animated: Bool) {
        self.conversations = []
        self.myDate = NSDate()
        ApiController.instance.getConversation()
    }
    
    override func viewDidLoad() {
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        SwiftEventBus.onMainThread(self, name: "conversationsSuccess") { result in
            // UI thread
            if result != nil {
                let resultDto: [ConversationVM] = result.object as! [ConversationVM]
                self.handleConversation(resultDto)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "conversationsFailed") { result in
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        NotificationCounter.mInstance.refresh()
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
        
        cell.productTitle.text = self.conversations[indexPath.row].postTitle
        cell.userDisplayName.text = self.conversations[indexPath.row].userName
        cell.userComment.text = self.conversations[indexPath.row].lastMessage
        
        if(self.conversations[indexPath.row].postOwner == false){
            cell.BuyText.hidden = true
            cell.SellText.hidden=false
            
        }else if(self.conversations[indexPath.row].postOwner == true){
            cell.SellText.hidden = true
            cell.BuyText.hidden = false
        }
        
        let time = self.conversations[indexPath.row].lastMessageDate / 1000
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(time))
        
        let time1 = date.timeAgo

        cell.comment.text = time1
        ImageUtil.displayPostImage(self.conversations[indexPath.row].postImage, imageView: cell.productImage)
        ImageUtil.displayThumbnailProfileImage(self.conversations[indexPath.row].postImage, imageView: cell.postImage)
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.currentIndex = indexPath.row
        self.performSegueWithIdentifier("showConversationsDetails", sender: nil)
    }
    
    func handleConversation(conversation: [ConversationVM]) {
        self.conversations = conversation
        self.collectionView.reloadData()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //
        let vController = segue.destinationViewController as! MessagesViewController
        vController.conversationId = self.conversations[self.currentIndex].id
    }
}
