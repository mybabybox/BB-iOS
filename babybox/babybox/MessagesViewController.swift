//
//  MessagesViewController.swift
//  babybox
//
//  Created by Mac on 06/12/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

import UIKit
import PhotoSlider
import SwiftEventBus
import ALCameraViewController

class MessagesViewController: UIViewController, UITextFieldDelegate, PhotoSliderDelegate, UIScrollViewDelegate {
        
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var prodImg: UIImageView!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var sellTextLbl: UILabel!
    @IBOutlet weak var buyTextLbl: UILabel!
    @IBOutlet weak var soldTextLbl: UILabel!
    @IBOutlet weak var messageComposingView: UIView!
    @IBOutlet weak var messageCointainerScroll: UIScrollView!
    @IBOutlet weak var buttomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var uploadImgSrc: UIImageView!
    
    var offset: Int64 = 0
    var conversation: ConversationVM? = nil
    var selectedImage : UIImage?
    var lastChatBubbleY: CGFloat = 40.0
    var internalPadding: CGFloat = 16.0
    var lastMessageType: BubbleDataType?
    let croppingEnabled: Bool = true
    let libraryEnabled: Bool = true
    var conversationViewController: ConversationsViewController?
    var messages: [MessageVM] = []
    var loadMoreMessages: Bool = false
    var lastItemPosition = 0
    
    //var loading: Bool = false
    //var loadingAll: Bool = false
    
    static var instance: MessagesViewController?
    
    override func viewDidDisappear(animated: Bool) {
        SwiftEventBus.unregister(self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MessagesViewController.instance = self
        messageCointainerScroll.delegate = self
        
        SwiftEventBus.unregister(self)
        self.navigationItem.title = self.conversation?.userName
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: Color.WHITE]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        sendButton.enabled = true
        SwiftEventBus.unregister(self)
        SwiftEventBus.onMainThread(self, name: "getMessagesSuccess") { result in
            // UI thread
            let resultDto = result.object as! MessageResponseVM
            self.handleChatMessageResponse(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "newMessageSuccess") { result in
            self.uploadImgSrc.image = nil
            self.view.makeToast(message: "Message added successfully.")
        }
        
        SwiftEventBus.onMainThread(self, name: "newMessageFailed") { result in
            self.view.makeToast(message: "Error upload message")
        }
        
        ViewUtil.showActivityLoading(self.activityLoading)
        
        ApiController.instance.getMessages((self.conversation?.id)!, offset: offset)
        offset++
        self.messageCointainerScroll.contentSize = CGSizeMake(CGRectGetWidth(messageCointainerScroll.frame), lastChatBubbleY + internalPadding)
        self.addKeyboardNotifications()
        
        ImageUtil.displayPostImage(self.conversation!.postImage, imageView: prodImg)
        self.prodName.text = self.conversation?.postTitle
        self.prodPrice.text = Constants.CURRENCY_SYMBOL + String(self.conversation!.postPrice.toIntMax())
        self.soldTextLbl.hidden = !self.conversation!.postSold
        self.buyTextLbl.hidden = self.conversation!.postOwner
        self.sellTextLbl.hidden = !self.conversation!.postOwner
        
        let userProfileBtn: UIButton = UIButton()
        userProfileBtn.setImage(UIImage(named: "w_profile"), forState: UIControlState.Normal)
        userProfileBtn.addTarget(self, action: "onClickProfileBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        userProfileBtn.frame = CGRectMake(0, 0, 35, 35)
        let userProfileBarBtn = UIBarButtonItem(customView: userProfileBtn)
        self.navigationItem.rightBarButtonItems = [userProfileBarBtn]
        
        ViewUtil.displayRoundedCornerView(self.sendButton)
        self.sendButton.layer.borderWidth = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func addKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
        
    // MARK:- Notification
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            //self.buttomLayoutConstraint = keyboardFrame.size.height
            self.buttomLayoutConstraint.constant = keyboardFrame.size.height
            
            }) { (completed: Bool) -> Void in
                self.moveToFirstMessage()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.buttomLayoutConstraint.constant = 0.0
            }) { (completed: Bool) -> Void in
                self.moveToFirstMessage()
        }
    }
    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        let msgCreatDt = NSDate(timeIntervalSinceNow: NSDate().timeIntervalSinceNow / 1000.0)
        let bubbleData:ChatBubbleData?
        if (textField.text == nil) {
            textField.text = ""
        }
        if (self.uploadImgSrc.image == nil) {
            bubbleData = ChatBubbleData(text: textField.text, image: nil, date: msgCreatDt, type: .Mine, buyerId: -1, imageId: -1)
            addChatBubble(bubbleData!)
        } else {
            bubbleData = ChatBubbleData(text: textField.text, image: self.uploadImgSrc.image!, date: msgCreatDt, type: .Mine, buyerId: -1, imageId: -1)
            
            addChatBubble(bubbleData!)
        }
        textField.resignFirstResponder()
        
        if self.conversationViewController != nil {
            self.conversationViewController!.updateOpenedConversation = true
        }
        if (self.uploadImgSrc.image == nil) {
            ApiController.instance.newMessage(self.conversation!.id, message: bubbleData!.text!, imagePath: "")
            ConversationCache.update(self.conversation!.id, successCallback: nil, failureCallback: nil)
        } else {
            ApiController.instance.newMessage(self.conversation!.id, message: bubbleData!.text!, imagePath: self.uploadImgSrc.image!)
        }
        self.moveToFirstMessage()
    }
        
    @IBAction func cameraButtonClicked(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: "Take Photo:", preferredStyle: .ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let cameraViewController = ALCameraViewController(croppingEnabled: self.croppingEnabled, allowsLibraryAccess: self.libraryEnabled) { (image) -> Void in
                self.uploadImgSrc.image = image
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            self.presentViewController(cameraViewController, animated: true, completion: nil)
        })
        
        let photoGalleryAction = UIAlertAction(title: "Photo Album", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let libraryViewController = ALCameraViewController.imagePickerViewController(self.croppingEnabled) { (image) -> Void in
                self.uploadImgSrc.image = image
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.presentViewController(libraryViewController, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoGalleryAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        //self.presentViewController(imagePicker, animated: true, completion: nil)//4
    }
    
    func addChatBubble(data: ChatBubbleData) {
        let padding:CGFloat = lastMessageType == data.type ? internalPadding/3.0 :  internalPadding
        
        let chatBubble = ChatBubble(data: data, startY:lastChatBubbleY + padding)
        self.messageCointainerScroll.addSubview(chatBubble)
        lastChatBubbleY = CGRectGetMaxY(chatBubble.frame)
        
        self.messageCointainerScroll.contentSize = CGSizeMake(CGRectGetWidth(messageCointainerScroll.frame), lastChatBubbleY + internalPadding)
        //self.moveToFirstMessage()
        lastMessageType = data.type
        textField.text = ""
    }
    
    func moveToFirstMessage() {
        if messageCointainerScroll.contentSize.height > CGRectGetHeight(messageCointainerScroll.frame) {
            let contentOffSet = CGPointMake(0.0, messageCointainerScroll.contentSize.height - CGRectGetHeight(messageCointainerScroll.frame))
            self.messageCointainerScroll.setContentOffset(contentOffSet, animated: false)
        }
    }
    
    func moveToLastMessage() {
        let frame = self.messageCointainerScroll.subviews[lastItemPosition - 1].frame
        //self.messageCointainerScroll.scrollRectToVisible(frame, animated: false)
        var yOffset = frame.origin.y
        if frame.origin.y > 50 {
            yOffset = frame.origin.y - 50
        }
        let contentOffSet = CGPointMake(0.0, yOffset)
        self.messageCointainerScroll.setContentOffset(contentOffSet, animated: false)
    }
    
    func getRandomChatDataType() -> BubbleDataType {
        return BubbleDataType(rawValue: Int(arc4random() % 2))!
    }
    
    func textField(txtField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var text: String
        if string.characters.count > 0 {
            text = String(format:"%@%@",txtField.text!, string)
        } else {
            let string = txtField.text! as NSString
            text = string.substringToIndex(string.length - 1) as String
        }
        return true
    }
    
    @IBAction func onClickProdItem(sender: AnyObject) {
        
        let feedItem: PostVMLite = PostVMLite()
        feedItem.id = (self.conversation?.postId)!
        
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("ProductViewController") as? ProductViewController
        vController!.feedItem = feedItem
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController!, animated: true)
        
    }
    //MARK: Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func handleChatMessageResponse(result: MessageResponseVM) {
        
        lastItemPosition = result.messages.count
        
        for uiView in self.messageCointainerScroll.subviews {
            uiView.removeFromSuperview()
        }
        
        self.messageCointainerScroll.contentSize = CGSizeMake(0, 0)
        self.lastChatBubbleY = 40.0
        self.messages.appendContentsOf(result.messages)
        var totalMessages = self.messages
        
        totalMessages.sortInPlace({ $0.createdDate < $1.createdDate })
        
        for var i = 0; i < totalMessages.count; i++ {
            let message: MessageVM = totalMessages[i]
            let messageDt = NSDate(timeIntervalSince1970:Double(message.createdDate) / 1000.0)
            if UserInfoCache.getUser()!.id == message.senderId {
                if (message.hasImage) {
                    let chatBubbleDataMine = ChatBubbleData(text: message.body, image: nil, date: messageDt, type: .Mine, buyerId: -1, imageId: message.image)
                    addChatBubble(chatBubbleDataMine)
                } else {
                    let chatBubbleDataMine = ChatBubbleData(text: message.body, image: nil, date: messageDt, type: .Mine, buyerId: -1, imageId: -1)
                    addChatBubble(chatBubbleDataMine)
                }
                
            } else {
                if (message.hasImage) {
                    let chatBubbleDataOpponent = ChatBubbleData(text: message.body, image: nil, date: messageDt, type: .Opponent, buyerId: message.senderId, imageId: message.image)
                    addChatBubble(chatBubbleDataOpponent)
                } else {
                    let chatBubbleDataOpponent = ChatBubbleData(text: message.body, image: nil, date: messageDt, type: .Opponent, buyerId: message.senderId, imageId: -1)
                    addChatBubble(chatBubbleDataOpponent)
                }
            }
            
        }
        
        if (result.messages.count >= Constants.CONVERSATION_MESSAGE_COUNT) {
            addMoreMessageLoaderLayout()
        } else {
            removeMoreMessageLoaderLayout()
        }
        
        if (!loadMoreMessages) {
            self.moveToFirstMessage()
        } else {
            self.moveToLastMessage()
        }
        
        ViewUtil.hideActivityLoading(self.activityLoading)
        
    }
    
    func onClickProfileBtn(sender: AnyObject?) {
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = (self.conversation?.userId)!
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController, animated: true)
    }
    
    @IBAction func onClickRemoveImage(sender: AnyObject) {
        self.uploadImgSrc.image = nil
    }
    
    func handleCroppedImage(notification: NSNotification) {
        print("")
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - PhotoSliderDelegate
    
    func photoSliderControllerWillDismiss(viewController: PhotoSlider.ViewController) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    func addMoreMessageLoaderLayout() {
        let loaderLayout: UIButton = UIButton(frame: CGRectMake(0, 0, self.view.frame.width, 40))
        loaderLayout.setTitle("LOAD EARLIER MESSAGES", forState: .Normal)
        loaderLayout.addTarget(self, action: "loadMoreMessages:", forControlEvents: UIControlEvents.TouchUpInside)
        loaderLayout.layer.backgroundColor = Color.LIGHT_GRAY.CGColor
        let titleFont : UIFont = UIFont.systemFontOfSize(12.0)
        loaderLayout.titleLabel?.font = titleFont
        self.messageCointainerScroll.insertSubview(loaderLayout, atIndex: 0)
        self.messageCointainerScroll.contentSize = CGSizeMake(CGRectGetWidth(messageCointainerScroll.frame), lastChatBubbleY + internalPadding)
    }
    
    func removeMoreMessageLoaderLayout() {
       self.messageCointainerScroll.subviews[0].removeFromSuperview()
    }
    
    
    func loadMoreMessages(sender: AnyObject?) {
        //
        ApiController.instance.getMessages((self.conversation?.id)!, offset: self.offset)
        ViewUtil.showActivityLoading(self.activityLoading)
        self.offset++
        loadMoreMessages = true
    }
    var _contentSizeO: CGPoint = CGPointMake(0.0, 0.0)
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
         _contentSizeO = CGPointMake(scrollView.frame.origin.x, scrollView.frame.origin.y)
    }
    
}