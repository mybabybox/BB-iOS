//
//  NotificationSettingsViewController.swift
//  BabyBox
//
//  Created by admin on 30/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class NotificationSettingsViewController: UIViewController {

    //MARK : Params
    var notificationDataSource : [AnyObject]!
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNotificationDataSource()
        
        SwiftEventBus.onMainThread(self, name: "editNotificationSettingsSuccess") { result in
            SwiftEventBus.unregister(self)
            let resultDto: UserVM = result.object as! UserVM
            UserInfoCache.getUser()!.settings = resultDto.settings
        }
        
        SwiftEventBus.onMainThread(self, name: "editNotificationSettingsFailed") { result in
            SwiftEventBus.unregister(self)
            self.view.makeToast(message: "Error updating user notification settings")
        }
        
        //let backbtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonPressed:")
        //navigationItem.backBarButtonItem = backbtn
        
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
            self.backButtonPressed()
        }
    }
    
    //MARK:  Memory Warning method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: Set Notification Data Source
    func setNotificationDataSource(){
        
        let settings: SettingVM = (UserInfoCache.getUser()?.settings)!
        
        
        let emailNotiifcationList = [
            NotificationVM(title:"New product listed",isEnabled:settings.emailNewPost),
            NotificationVM(title:"New chat",isEnabled:settings.emailNewConversation),
            NotificationVM(title:"New comment on your product listings",isEnabled:settings.emailNewComment),
            NotificationVM(title:"New promotions",isEnabled:settings.emailNewPromotion)
        ]
        
        let pushNotiifcationList = [
            NotificationVM(title:"New chat",isEnabled:settings.pushNewConversion),
            NotificationVM(title:"New comment on your product listings",isEnabled:settings.pushNewComment),
            NotificationVM(title:"New follower",isEnabled:settings.pushNewFollow),
            NotificationVM(title:"New feedback",isEnabled:settings.pushNewFeedback),
            NotificationVM(title:"New promotions",isEnabled:settings.pushNewPromotions)
        ]
        
        self.notificationDataSource = [emailNotiifcationList,pushNotiifcationList]
    }
    // MARK: UITableViewDataSource and Delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.notificationDataSource.count;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationDataSource[section].count;
    }
    func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String{
        if section == 0 {
            return "Email Notifications"
        }else if section == 1 {
            return "Push Notifications"
        }
        return ""
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell")! as! NotificationViewCell
        let sectionsArray = self.notificationDataSource[indexPath.section]
        let notification = sectionsArray[indexPath.row] as! NotificationVM
        cell.setUIWithDataSource(notification)
        return cell;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationViewCell
        cell.isEnabledSwitch.setOn(!cell.isEnabledSwitch.on, animated: true)
    }
    
    func backButtonPressed() {
        //Call the api...
        NSLog("")
        
        let settings:SettingVM  = UserInfoCache.getUser()!.settings
        let emailNotifications = self.notificationDataSource[0] as! [NotificationVM]
        let pushNotifications = self.notificationDataSource[1] as! [NotificationVM]
        
        for i in 0...emailNotifications.count - 1 {
            let notifItem = emailNotifications[i]
            switch notifItem.title {
                case "New product listed":
                    settings.emailNewPost = notifItem.isEnabled
                case "New chat":
                    settings.emailNewConversation = notifItem.isEnabled
                case "New comment on your product listings":
                    settings.emailNewComment = notifItem.isEnabled
                case "New promotions":
                    settings.emailNewPromotion = notifItem.isEnabled
                default: break
            }
        }
        
        for i in 0...pushNotifications.count - 1 {
            let notifItem = pushNotifications[i]
            switch notifItem.title {
                case "New chat":
                    settings.pushNewConversion = notifItem.isEnabled
                case "New comment on your product listings":
                    settings.pushNewComment = notifItem.isEnabled
                case "New follower":
                    settings.pushNewFollow = notifItem.isEnabled
                case "New feedback":
                    settings.pushNewFeedback = notifItem.isEnabled
                case "New promotions":
                    settings.pushNewPromotions = notifItem.isEnabled
                default: break
            }
        }
        ApiController.instance.editUserNotificationSettings(settings)
        NSLog("")
    }
}
