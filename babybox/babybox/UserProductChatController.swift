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
class UserProductChatController: UIViewController {
    
    var userId: Int = 0
    
    var viewCellIdentifier: String = "userProductsChatCollectionView"
    var conversations: [ConversationVM] = []
    
    //todo create instance of collectionview
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        ApiControlller.apiController.getConversation()
        
        SwiftEventBus.onMainThread(self, name: "conversationsSuccess") { result in
            // UI thread
            if result != nil {
                let resultDto: [ConversationVM] = result.object as! [ConversationVM]
                print("success")
                print(resultDto)
                self.handleConversation(resultDto)
                
                //reload the collectionview
                self.collectionView.reloadData()
                
                
            } else {
                print("null value")
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "conversationsFailed") { result in
            // UI thread
            
            print("fail......")
        }
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewCellIdentifier, forIndexPath: indexPath) as! UserProductChatCollectionViewCell
        
        //todo - this method called when reloading the colleciton view 
        //set variables of UserProductChatCollectionViewCell 
        cell.productTitle.text = self.conversations[indexPath.row].postTitle
        
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
    }
    
    func handleConversation(conversation: [ConversationVM]) {
        self.conversations = conversation
        
    }
}