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
    //showConversationsDetails
    var userId: Int = 0
    var currentIndex: Int = 0
    var viewCellIdentifier: String = "conversationsCollectionViewCell"
    var conversations: [ConversationVM] = []
    var myDate: NSDate = NSDate()
    
    //todo create instance of collectionview
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidAppear(animated: Bool) {
        self.conversations = []
        self.myDate = NSDate()
        ApiControlller.apiController.getConversation()
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        
        
        
        SwiftEventBus.onMainThread(self, name: "conversationsSuccess") { result in
            // UI thread
            if result != nil {
                let resultDto: [ConversationVM] = result.object as! [ConversationVM]
                print("success")
                print(resultDto)
                self.handleConversation(resultDto)
                
                
                
                
            } else {
                print("null value")
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "conversationsFailed") { result in
            // UI thread
            
            print("fail......")
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
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
        
        //todo - this method called when reloading the colleciton view 
        //set variables of ConversationsCollectionViewCell
        cell.productTitle.text = self.conversations[indexPath.row].postTitle
        cell.userDisplayName.text = self.conversations[indexPath.row].userName
        cell.userComment.text = self.conversations[indexPath.row].lastMessage
        
        let time = self.conversations[indexPath.row].lastMessageDate / 1000
        var date = NSDate(timeIntervalSince1970: NSTimeInterval(time))
        
        var time1 = self.myDate.offsetFrom(date)

        cell.comment.text = time1
        
        return cell
    }
    
        /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 1
        }
    
        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 1
        }*/
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        self.currentIndex = indexPath.row
        self.performSegueWithIdentifier("showConversationsDetails", sender: nil)
    }
    
    func handleConversation(conversation: [ConversationVM]) {
        self.conversations = conversation
        //reload the collectionview
        self.collectionView.reloadData()
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //
        var vController = segue.destinationViewController as! MessagesViewController
        vController.conversationId = self.conversations[self.currentIndex].id
    }
}

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        print("abceefghigjklmnopqrstuwxyz")
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
        print("in nsdaate......")
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date)) years ago"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date)) months ago"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date)) weeks ago"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date)) days ago"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date)) hours ago"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date)) minutes ago" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date)) seconds ago" }
        return ""
    }
}