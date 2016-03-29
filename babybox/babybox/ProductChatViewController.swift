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
    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var tipText: UILabel!
    @IBOutlet weak var postPrice: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var soldText: UILabel!
    @IBOutlet weak var sellText: UILabel!
    @IBOutlet weak var buyText: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    var conversations: [ConversationVM] = []
    var collectionViewCellSize : CGSize?
    var postItem: ConversationVM? = nil
    var loading: Bool = false
    var loadedAll: Bool = false
    var postId: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewUtil.showActivityLoading(self.activityLoading)
        
        SwiftEventBus.onMainThread(self, name: "productConversationsSuccess") { result in
            SwiftEventBus.unregister(self)
            let conversations = result.object as! [ConversationVM]
            self.handleProductConversations(conversations)
        }
        
        SwiftEventBus.onMainThread(self, name: "productConversationsFailed") { result in
            SwiftEventBus.unregister(self)
            self.view.makeToast(message: "Error getting Product Conversations!")
        }
        
        setCollectionViewSizesInsetsForTopView()
        ApiController.instance.getPostConversations(postId)
        self.loading = true
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        self.uiCollectionView.collectionViewLayout = flowLayout
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return conversations.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("productChatViewCell", forIndexPath: indexPath) as! ProductChatViewCell
        
        let conversationItem = self.conversations[indexPath.row]
        cell.contentMode = UIViewContentMode.Redraw
        cell.sizeToFit()
        cell.recentComment.numberOfLines = 0
        cell.recentComment.sizeToFit()
        ImageUtil.displayThumbnailProfileImage(conversationItem.userId, imageView: cell.userImg)
        cell.userName.text = conversationItem.userName
        cell.commentTimeAgo.text = NSDate(timeIntervalSince1970:Double(conversationItem.lastMessageDate) / 1000.0).timeAgo
        cell.commentTimeAgo.sizeToFit()
        cell.recentComment.text = conversationItem.lastMessage
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        collectionViewCellSize = CGSizeMake(self.view.bounds.width, 75)
    }
    
    func handleProductConversations(resultDto: [ConversationVM]) {
        if (!resultDto.isEmpty) {
            if (postItem == nil) {
                postItem = resultDto[0]
                self.renderPostView()
            }
            
            if (self.conversations.count == 0) {
                self.conversations = resultDto
            } else {
                self.conversations.appendContentsOf(resultDto)
            }
            uiCollectionView.reloadData()
        } else {
            loadedAll = true
        }
        loading = false
        ViewUtil.hideActivityLoading(self.activityLoading)
        self.noResultHandler()
    }
    
    func noResultHandler() {
        if (self.conversations.isEmpty) {
            self.tipText.hidden = false
            self.uiCollectionView.hidden = true
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
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "conversationScreen") {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "conversationScreen") {
            let cell = sender as! ProductChatViewCell
            let indexPath = self.uiCollectionView!.indexPathForCell(cell)
            
            let vController = segue.destinationViewController as? MessagesViewController
            vController?.conversation = self.conversations[(indexPath?.row)!]
            ViewUtil.resetBackButton(self.navigationItem)
            vController!.hidesBottomBarWhenPushed = true
            
        }
    }
    
    // MARK: UIScrollview Delegate
    /*func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loadedAll && !loading) {
                ViewUtil.showActivityLoading(self.activityLoading)
                loading = true
                var offset: Int64 = 0
                ApiController.instance.getPostConversations(postId)
            }
        }
    }*/
}
