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
    
    var conversation: ConversationVM? = nil
    var offered = false
    var offeredPrice: Double = -1
    
    var offset: Int64 = 0
    var selectedImage : UIImage?
    var lastChatBubbleY: CGFloat = 40.0
    var linePadding: CGFloat = 15.0
    var lastMessageType: BubbleDataType?
    let croppingEnabled: Bool = true
    let libraryEnabled: Bool = true
    var conversationViewController: ConversationsViewController?
    var messages: [MessageVM] = []
    var loadMoreMessages: Bool = false
    var lastItemPosition = 0
    var bubbleData: ChatBubbleData?
    
    //var loading: Bool = false
    //var loadingAll: Bool = false
    
    static var instance: MessagesViewController?
    
    override func viewDidDisappear(animated: Bool) {
        SwiftEventBus.unregister(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        registerEvents()
    }
    
    func registerEvents() {
        /*SwiftEventBus.onMainThread(self, name: "getMessagesSuccess") { result in
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            let resultDto = result.object as! MessageResponseVM
            self.handleChatMessageResponse(resultDto)
            
            if (self.offered) {
                self.newMessage("New offer: \(Int(self.offeredPrice))", image: nil, system: true)
            }
        }*/
        
        SwiftEventBus.onMainThread(self, name: "newMessageSuccess") { result in
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            if (self.bubbleData != nil) {
                self.addChatBubble(self.bubbleData!)
                self.moveToFirstMessage()
                self.reset()
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "newMessageFailed") { result in
            ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
            self.view.makeToast(message: "Error upload message")
            self.reset()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MessagesViewController.instance = self
        messageCointainerScroll.delegate = self
        
        SwiftEventBus.unregister(self)
        
        self.navigationItem.title = self.conversation?.userName
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: Color.WHITE]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        messageCointainerScroll.addGestureRecognizer(tap)
        
        sendButton.enabled = true
        
        registerEvents()
        
        ViewUtil.showActivityLoading(self.activityLoading)
        ApiFacade.getMessages((self.conversation?.id)!, offset: offset, successCallback: onSuccessGetMessages, failureCallback: onFailureGetMessages)
        //ApiController.instance.getMessages((self.conversation?.id)!, offset: offset)
        self.offset++
        self.messageCointainerScroll.contentSize = CGSizeMake(CGRectGetWidth(messageCointainerScroll.frame), lastChatBubbleY + linePadding)
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
        
    // MARK:- Notification
    
    func keyboardDidShow(notification: NSNotification) {
        self.moveToFirstMessage()
    }
    
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
    
    func newMessage(message: String, image: UIImage?, system: Bool = false) {
        let date = NSDate(timeIntervalSinceNow: NSDate().timeIntervalSinceNow / 1000.0)
        
        self.bubbleData = ChatBubbleData(text: message, image: image, date: date, type: .Me, buyerId: -1, imageId: -1, system: system)
        
        if self.conversationViewController != nil {
            self.conversationViewController!.updateOpenedConversation = true
        }
        
        ViewUtil.showGrayOutView(self, activityLoading: self.activityLoading)
        
        ApiController.instance.newMessage(self.conversation!.id, message: message, image: image, system: system)
        ConversationCache.update(self.conversation!.id, successCallback: nil, failureCallback: nil)
    }
    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        if self.uploadImgSrc.image == nil && (self.textField.text == nil || ViewUtil.trim(self.textField.text!).isEmpty) {
            //self.view.makeToast(message: "Please enter a message")
            return
        }
        if (self.textField.text == nil) {
            self.textField.text = ""
        }
        newMessage(ViewUtil.trim(textField.text!), image: self.uploadImgSrc.image)
    }
    
    @IBAction func cameraButtonClicked(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: "Take Photo:", preferredStyle: .ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let cameraViewController = ALCameraViewController(croppingEnabled: self.croppingEnabled, allowsLibraryAccess: self.libraryEnabled) { (image) -> Void in
                self.uploadImgSrc.image = image?.retainOrientation()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            self.presentViewController(cameraViewController, animated: true, completion: nil)
        })
        
        let photoGalleryAction = UIAlertAction(title: "Photo Album", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let libraryViewController = ALCameraViewController.imagePickerViewController(self.croppingEnabled) { (image) -> Void in
                self.uploadImgSrc.image = image?.retainOrientation()
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
        let padding:CGFloat = lastMessageType == data.type ? linePadding/3.0 : linePadding
        
        let chatBubble = ChatBubble(data: data, startY:lastChatBubbleY + padding)
        self.messageCointainerScroll.addSubview(chatBubble)
        lastChatBubbleY = CGRectGetMaxY(chatBubble.frame)
        
        self.messageCointainerScroll.contentSize = CGSizeMake(CGRectGetWidth(messageCointainerScroll.frame), lastChatBubbleY + linePadding)
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
        if frame.origin.y > Constants.MESSAGE_LOAD_MORE_BTN_HEIGHT {
            yOffset = frame.origin.y - Constants.MESSAGE_LOAD_MORE_BTN_HEIGHT
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
    
    func reset() {
        self.textField.text = ""
        self.uploadImgSrc.image = nil
        self.offered = false
        self.offeredPrice = -1
    }
    
    //MARK: Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func handleChatMessageResponse(result: MessageResponseVM) {
        
        if (result.messages.isEmpty) {
            ViewUtil.hideActivityLoading(self.activityLoading)
            return
        }
        
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
            let date = NSDate(timeIntervalSince1970:Double(message.createdDate) / 1000.0)
            if UserInfoCache.getUser()!.id == message.senderId {
                if (message.hasImage) {
                    let chatBubbleDataMine = ChatBubbleData(text: message.body, image: nil, date: date, type: .Me, buyerId: -1, imageId: message.image, system: message.system)
                    addChatBubble(chatBubbleDataMine)
                } else {
                    let chatBubbleDataMine = ChatBubbleData(text: message.body, image: nil, date: date, type: .Me, buyerId: -1, imageId: -1, system: message.system)
                    addChatBubble(chatBubbleDataMine)
                }
                
            } else {
                if (message.hasImage) {
                    let chatBubbleDataOpponent = ChatBubbleData(text: message.body, image: nil, date: date, type: .You, buyerId: message.senderId, imageId: message.image, system: message.system)
                    addChatBubble(chatBubbleDataOpponent)
                } else {
                    let chatBubbleDataOpponent = ChatBubbleData(text: message.body, image: nil, date: date, type: .You, buyerId: message.senderId, imageId: -1, system: message.system)
                    addChatBubble(chatBubbleDataOpponent)
                }
            }
            
        }
        
        if (result.messages.count >= Constants.CONVERSATION_MESSAGE_COUNT) {
            addMoreMessageLoaderLayout()
        } else {
            removeMoreMessageLoaderLayout()
        }
        
        if (!self.loadMoreMessages) {
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
    
    /*func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }*/
    
    // MARK: - PhotoSliderDelegate
    
    func photoSliderControllerWillDismiss(viewController: PhotoSlider.ViewController) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    func addMoreMessageLoaderLayout() {
        let loaderLayout: UIButton = UIButton(frame: CGRectMake(0, 0, self.view.frame.width, 50))
        loaderLayout.setTitle("LOAD EARLIER MESSAGES", forState: .Normal)
        loaderLayout.addTarget(self, action: "loadMoreMessages:", forControlEvents: UIControlEvents.TouchUpInside)
        loaderLayout.layer.backgroundColor = Color.LIGHT_GRAY.CGColor
        let titleFont : UIFont = UIFont.systemFontOfSize(15.0)
        loaderLayout.titleLabel?.font = titleFont
        self.messageCointainerScroll.insertSubview(loaderLayout, atIndex: 0)
        self.messageCointainerScroll.contentSize = CGSizeMake(CGRectGetWidth(messageCointainerScroll.frame), lastChatBubbleY + linePadding)
    }
    
    func removeMoreMessageLoaderLayout() {
        let firstSubView = self.messageCointainerScroll.subviews[0]
        if (firstSubView.isKindOfClass(UIButton)) {
            firstSubView.removeFromSuperview()
        }
    }
    
    func loadMoreMessages(sender: AnyObject?) {
        ApiController.instance.getMessages((self.conversation?.id)!, offset: self.offset)
        ViewUtil.showActivityLoading(self.activityLoading)
        self.offset++
        self.loadMoreMessages = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func onSuccessGetMessages(resultDto: MessageResponseVM) {
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
        self.handleChatMessageResponse(resultDto)
        if (self.offered) {
            self.newMessage("New offer: \(Int(self.offeredPrice))", image: nil, system: true)
        }
    }
    
    func onFailureGetMessages(error: String) {
        NSLog("error getting messages")
    }
}