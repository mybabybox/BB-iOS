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
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
            self.backButtonPressed()
        }
        SwiftEventBus.unregister(self)
    }
    
    //MARK:  Memory Warning method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Set Notification Data Source
    func setNotificationDataSource(){
        
        let settings: SettingVM = (UserInfoCache.getUser()?.settings)!
        
        let emailNotiifcationList = [
            NotificationVM(title: Constants.SETTING_EMAIL_NOTIF_NEW_PRODUCT, isEnabled: settings.emailNewPost),
            NotificationVM(title: Constants.SETTING_EMAIL_NOTIF_NEW_CHAT, isEnabled: settings.emailNewConversation),
            NotificationVM(title: Constants.SETTING_EMAIL_NOTIF_NEW_COMMENT, isEnabled: settings.emailNewComment),
            //NotificationVM(title: Constants.SETTING_EMAIL_NOTIF_NEW_PROMOTIONS, isEnabled: settings.emailNewPromotions)
        ]
        
        let pushNotiifcationList = [
            NotificationVM(title: Constants.SETTING_PUSH_NOTIF_NEW_CHAT, isEnabled: settings.pushNewConversation),
            NotificationVM(title: Constants.SETTING_PUSH_NOTIF_NEW_COMMENT, isEnabled: settings.pushNewComment),
            NotificationVM(title: Constants.SETTING_PUSH_NOTIF_NEW_FOLLOW, isEnabled: settings.pushNewFollow),
            //NotificationVM(title: Constants.SETTING_PUSH_NOTIF_NEW_FEEDBACK, isEnabled: settings.pushNewFeedback),
            //NotificationVM(title: Constants.SETTING_PUSH_NOTIF_NEW_PROMOTIONS, isEnabled: settings.pushNewPromotions)
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
        let sectionsArray = self.notificationDataSource[indexPath.section] as? [NotificationVM]
        let notification = sectionsArray![indexPath.row]
        cell.setUIWithDataSource(notification)
        return cell;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationViewCell
        cell.isEnabledSwitch.setOn(!cell.isEnabledSwitch.on, animated: true)
    }
    
    func backButtonPressed() {
        let settings:SettingVM  = UserInfoCache.getUser()!.settings
        let emailNotifications = self.notificationDataSource[0] as! [NotificationVM]
        let pushNotifications = self.notificationDataSource[1] as! [NotificationVM]
        
        for i in 0...emailNotifications.count - 1 {
            let notifItem = emailNotifications[i]
            switch notifItem.title {
                case Constants.SETTING_EMAIL_NOTIF_NEW_PRODUCT:
                    settings.emailNewPost = notifItem.isEnabled
                case Constants.SETTING_EMAIL_NOTIF_NEW_CHAT:
                    settings.emailNewConversation = notifItem.isEnabled
                case Constants.SETTING_EMAIL_NOTIF_NEW_COMMENT:
                    settings.emailNewComment = notifItem.isEnabled
                case Constants.SETTING_EMAIL_NOTIF_NEW_PROMOTIONS:
                    settings.emailNewPromotions = notifItem.isEnabled
                default: break
            }
        }
        
        for i in 0...pushNotifications.count - 1 {
            let notifItem = pushNotifications[i]
            switch notifItem.title {
                case Constants.SETTING_PUSH_NOTIF_NEW_CHAT:
                    settings.pushNewConversation = notifItem.isEnabled
                case Constants.SETTING_PUSH_NOTIF_NEW_COMMENT:
                    settings.pushNewComment = notifItem.isEnabled
                case Constants.SETTING_PUSH_NOTIF_NEW_FOLLOW:
                    settings.pushNewFollow = notifItem.isEnabled
                case Constants.SETTING_PUSH_NOTIF_NEW_FEEDBACK:
                    settings.pushNewFeedback = notifItem.isEnabled
                case Constants.SETTING_PUSH_NOTIF_NEW_PROMOTIONS:
                    settings.pushNewPromotions = notifItem.isEnabled
                default: break
            }
        }
        
        ApiController.instance.editUserNotificationSettings(settings)
    }
}
