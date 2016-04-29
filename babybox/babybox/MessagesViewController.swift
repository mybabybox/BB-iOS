//
//  MessagesViewController.swift
//  babybox
//
//  Created by Mac on 06/12/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

import UIKit
import PhotoSlider

class MessagesViewController: UIViewController, PhotoSliderDelegate, UIScrollViewDelegate, UITextViewDelegate {
        
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var bottomSpaceForText: NSLayoutConstraint!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var prodImg: UIImageView!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var sellTextLbl: UILabel!
    @IBOutlet weak var buyTextLbl: UILabel!
    @IBOutlet weak var soldTextLbl: UILabel!
    @IBOutlet weak var messageComposingView: UIView!
    @IBOutlet weak var messageCointainerScroll: UIScrollView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var uploadImgSrc: UIImageView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var footerbtnsHeight: NSLayoutConstraint!
    
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
    var conversationViewController: UIViewController = UIViewController()
    var messages: [MessageVM] = []
    var lastItemPosition = 0
    var bubbleData: ChatBubbleData?
    var pendingOrder = false
    
    @IBOutlet weak var buyerButtonsLayout: UIView! //Parent Layout
    @IBOutlet weak var buyerOrderLayout: UIView!
    @IBOutlet weak var buyerCancelLayout: UIView!
    @IBOutlet weak var buyerMessageLayout: UIView!
    
    @IBOutlet weak var sellerButtonsLayout: UIView! //Parent Layout
    @IBOutlet weak var sellerAcceptDeclineLayout: UIView!
    @IBOutlet weak var sellerMessageLayout: UIView!
    
    @IBOutlet weak var sellerMessageButton: UIButton!
    @IBOutlet weak var orderText: UILabel!
    @IBOutlet weak var sellerDeclineButton: UIButton!
    @IBOutlet weak var sellerAcceptButton: UIButton!
    @IBOutlet weak var interested: UILabel!
    @IBOutlet weak var ordered: UILabel!
    @IBOutlet weak var buyerOrderButton: UIButton!
    @IBOutlet weak var buyerCancelButton: UIButton!
    @IBOutlet weak var buyerMessageButton: UIButton!
    @IBOutlet weak var buyerOrderAgainButton: UIButton!
    
    static var instance: MessagesViewController?
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MessagesViewController.instance = self
        messageCointainerScroll.delegate = self
        self.commentTextView.delegate = self
        
        //ViewUtil.displayRoundedCornerView(self.commentTextView, bgColor: Color.WHITE, borderColor: Color.LIGHT_GRAY)
        self.commentTextView.placeholder = NSLocalizedString("enter_text", comment: "")
        self.sendButton.enabled = false
        
        self.navigationItem.title = self.conversation?.userName
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: Color.WHITE]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: "dismissKeyboard")
        self.messageCointainerScroll.addGestureRecognizer(tap)
        
        ViewUtil.showActivityLoading(self.activityLoading)
        ApiFacade.getMessages((self.conversation?.id)!, offset: offset, successCallback: onSuccessGetMessages, failureCallback: onFailureGetMessages)

        self.messageCointainerScroll.contentSize = CGSizeMake(CGRectGetWidth(messageCointainerScroll.frame), lastChatBubbleY + linePadding)
        self.messageCointainerScroll.backgroundColor = Color.FEED_BG
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
        
        //ViewUtil.displayRoundedCornerView(self.sendButton, bgColor: Color.LIGHT_GRAY.CGColor)
        
        self.initButtonsLayout()
        self.initLayout(self.conversation!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func addKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
    }
        
    // MARK:- Notification
    
    func keyboardDidShow(notification: NSNotification) {
        self.moveToFirstMessage()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.messageCointainerScroll.frame.size.height = self.messageCointainerScroll.frame.size.height - keyboardFrame.size.height
            self.bottomSpaceForText.constant = -keyboardFrame.size.height + self.footerbtnsHeight.constant
            }) { (completed: Bool) -> Void in
                self.moveToFirstMessage()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.bottomSpaceForText.constant = 0.0
            }) { (completed: Bool) -> Void in
                self.moveToFirstMessage()
        }
    }
    
    func newMessage(message: String, image: UIImage?, system: Bool = false) {
        let date = NSDate(timeIntervalSinceNow: NSDate().timeIntervalSinceNow / 1000.0)
        
        self.bubbleData = ChatBubbleData(text: message, image: image, date: date, type: .Me, buyerId: -1, imageId: -1, system: system)
        
        //if self.conversationViewController != nil {
            if conversationViewController.isKindOfClass(ConversationsViewController) {
                let cView = conversationViewController as? ConversationsViewController
                cView!.updateOpenedConversation = true
            } else if conversationViewController.isKindOfClass(ProductChatViewController) {
                let cView = conversationViewController as? ProductChatViewController
                cView!.updateOpenedConversation = true
            }
        //}
        
        NSLog("newMessage=\(message)");
        
        ViewUtil.showGrayOutView(self, activityLoading: self.activityLoading)
        ApiFacade.newMessage(self.conversation!.id, message: message, image: image, system: system, successCallback: onSuccessNewMessage, failureCallback: onFailureNewMessage)
    }
    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        if self.uploadImgSrc.image == nil && StringUtil.trim(self.commentTextView.text).isEmpty {
            //ViewUtil.makeToast("Please enter a message", view: self.view)
            return
        }
        newMessage(StringUtil.trim(commentTextView.text), image: self.uploadImgSrc.image)
    }
    
    @IBAction func cameraButtonClicked(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Take Photo:", preferredStyle: .ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let cameraViewController = ALCameraViewController(croppingEnabled: self.croppingEnabled, allowsLibraryAccess: self.libraryEnabled) { (image) -> Void in
                //self.cameraBtn.alpha = 0.0
                //self.uploadImgSrc.image = image?.retainOrientation()
                self.cameraBtn.setBackgroundImage(image?.retainOrientation(), forState: .Normal)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            self.presentViewController(cameraViewController, animated: true, completion: nil)
        })
        
        let photoGalleryAction = UIAlertAction(title: "Photo Album", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let libraryViewController = ALCameraViewController.imagePickerViewController(self.croppingEnabled) { (image) -> Void in
                //self.cameraBtn.alpha = 0.0
                //self.uploadImgSrc.image = image?.retainOrientation()
                self.cameraBtn.setBackgroundImage(image?.retainOrientation(), forState: .Normal)
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
        commentTextView.text = ""
    }
    
    func moveToFirstMessage() {
        if messageCointainerScroll.contentSize.height > CGRectGetHeight(messageCointainerScroll.frame) {
            let contentOffSet = CGPointMake(0.0, messageCointainerScroll.contentSize.height - CGRectGetHeight(messageCointainerScroll.frame))
            self.messageCointainerScroll.setContentOffset(contentOffSet, animated: false)
        }
    }
    
    func moveToLastLoadPosition() {
        let frame = self.messageCointainerScroll.subviews[lastItemPosition - 1].frame
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
        self.commentTextView.text = ""
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
            removeMoreMessageLoaderLayout()
            return
        }
        
        self.offset += 1
        
        let firstLoad = lastItemPosition == 0
        
        lastItemPosition = result.messages.count
        
        for uiView in self.messageCointainerScroll.subviews {
            uiView.removeFromSuperview()
        }
        
        self.messageCointainerScroll.contentSize = CGSizeMake(0, 0)
        self.lastChatBubbleY = 40.0
        self.messages.appendContentsOf(result.messages)
        var totalMessages = self.messages
        
        totalMessages.sortInPlace({ $0.createdDate < $1.createdDate })
        
        for i in 0 ..< totalMessages.count {
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
        
        if result.messages.count >= Constants.CONVERSATION_MESSAGE_COUNT {
            addMoreMessageLoaderLayout()
        } else {
            removeMoreMessageLoaderLayout()
        }
        
        if firstLoad {
            self.moveToFirstMessage()
        } else {
            self.moveToLastLoadPosition()
        }
        
        ViewUtil.hideActivityLoading(self.activityLoading)
    }
    
    func onClickProfileBtn(sender: AnyObject?) {
        let vController = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileFeedViewController") as! UserProfileFeedViewController
        vController.userId = (self.conversation?.userId)!
        ViewUtil.resetBackButton(self.navigationItem)
        self.navigationController?.pushViewController(vController, animated: true)
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
        ApiFacade.getMessages((self.conversation?.id)!, offset:offset, successCallback: onSuccessGetMessages, failureCallback: onFailureGetMessages)
        ViewUtil.showActivityLoading(self.activityLoading)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textViewDidChange(textView: UITextView) {
        self.sendButton.enabled = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(textView: UITextView) {
    
    }
    
    func onSuccessGetMessages(response: MessageResponseVM) {
        self.handleChatMessageResponse(response)

        if self.offered {
            self.newMessage("New offer: \(Int(self.offeredPrice))", image: nil, system: true)
        }
    }
    
    func onFailureGetMessages(error: String) {
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
        ViewUtil.showDialog("Error", message: error, view: self)
    }
    
    func onSuccessNewMessage(response: String) {
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
        if (self.bubbleData != nil) {
            self.addChatBubble(self.bubbleData!)
            self.moveToFirstMessage()
            self.reset()
        }
        ConversationCache.update(self.conversation!.id, successCallback: nil, failureCallback: nil)
        self.commentTextView.resignFirstResponder()
    }
    
    func onFailureNewMessage(error: String) {
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
        ViewUtil.showDialog("Error", message: error, view: self)
        self.reset()
    }
    
    func initButtonsLayout() {
        
        //ViewUtil.displayRoundedCornerView(self.buyerMessageButton)
        ViewUtil.displayRoundedCornerBtnView(self.buyerCancelButton)
        ViewUtil.displayRoundedCornerBtnView(self.buyerOrderAgainButton)
        ViewUtil.displayRoundedCornerBtnView(self.buyerOrderButton)
        
        ViewUtil.displayRoundedCornerBtnView(self.sellerAcceptButton)
        ViewUtil.displayRoundedCornerBtnView(self.sellerDeclineButton)
        
        /*
        let buyerMessageLayoutConstraint = ViewUtil.applyWidthConstraints(self.buyerMessageButton, toView: self.view, multiplierValue: 0.70)
        self.view.addConstraint(buyerMessageLayoutConstraint)
        let buyerCancelLayoutConstraint = ViewUtil.applyWidthConstraints(self.ordered, toView: self.view, multiplierValue: 0.30)
        self.view.addConstraint(buyerCancelLayoutConstraint)
        let buyerOrderLayoutConstraint = ViewUtil.applyWidthConstraints(self.interested, toView: self.view, multiplierValue: 0.30)
        self.view.addConstraint(buyerOrderLayoutConstraint)
        let sellerAcceptDeclineLayoutConstraint = ViewUtil.applyWidthConstraints(self.orderText, toView: self.view, multiplierValue: 0.50)
        self.view.addConstraint(sellerAcceptDeclineLayoutConstraint)
        let sellerAcceptDeclineBtnConstraint = ViewUtil.applyWidthConstraints(self.sellerDeclineButton, toView: self.view, multiplierValue: 0.50)
        self.view.addConstraint(sellerAcceptDeclineBtnConstraint)
        */
    }
    
    func initLayout(_conversation: ConversationVM) {
        
        let isBuyer = !_conversation.postOwner
        
        self.buyerButtonsLayout.hidden = !isBuyer
        self.sellerButtonsLayout.hidden = isBuyer
    
        // show actions based on order state
        if isBuyer {
            initBuyerLayout(_conversation);
        } else {
            initSellerLayout(_conversation);
        }
    }
    
    func initBuyerLayout(_conversation: ConversationVM) {
        
        self.buyerOrderLayout.hidden = true
        self.buyerCancelLayout.hidden = true
        self.buyerMessageLayout.hidden = true
        
        let order = _conversation.order
        
        // no order yet
        if order == nil {
            if _conversation.postSold {
                buyerButtonsLayout.hidden = true
                sellerButtonsLayout.hidden = true
                footerbtnsHeight.constant = 0   //set the size of block to 0
            } else {
                buyerOrderLayout.hidden = false
            }
        }
        // open orders
        else if !order!.closed {
            buyerCancelLayout.hidden = false
        }
        // closed orders
        else {
            buyerMessageLayout.hidden = false
            if _conversation.postSold {
                buyerOrderAgainButton.hidden = true
            }
            
            if order!.cancelled {
                buyerMessageButton.setTitle(Constants.PM_ORDER_CANCELLED, forState: .Normal)
            } else if order!.accepted {
                buyerMessageButton.setTitle(Constants.PM_ORDER_ACCEPTED_FOR_BUYER, forState: .Normal)
            } else if order!.declined {
                buyerMessageButton.setTitle(Constants.PM_ORDER_DECLINED_FOR_BUYER, forState: .Normal)
            }
        }
    }
    
    func initSellerLayout(_conversation: ConversationVM) {
        
        sellerAcceptDeclineLayout.hidden = true
        sellerMessageLayout.hidden = true
        
        let order = _conversation.order
        
        // no order yet
        if order == nil {
            // no actions... hide seller actions
            sellerButtonsLayout.hidden = true
            footerbtnsHeight.constant = 0   //set the size of block 0
        }
        // open orders
        else if !order!.closed {
            sellerAcceptDeclineLayout.hidden = false
        }
        // closed orders
        else {
            sellerMessageLayout.hidden = false
            if order!.accepted {
                sellerMessageButton.setTitle(Constants.PM_ORDER_ACCEPTED_FOR_SELLER, forState: .Normal)
            } else if order!.declined {
                sellerMessageButton.setTitle(Constants.PM_ORDER_DECLINED_FOR_SELLER, forState: .Normal)
            } else if order!.cancelled {
                sellerButtonsLayout.hidden = true
            }
        }
    }
    
    @IBAction func onClickBuyerMessageButton(sender: AnyObject) {
        NSLog("onClickBuyerMessageButton")
    }
    
    @IBAction func onClickBuyerOrderAgainButton(sender: AnyObject) {
        NSLog("onClickBuyerOrderAgainButton")
        let _messageDialog = UIAlertController(title: "Buy Now", message: "Make an offer to Seller", preferredStyle: UIAlertControllerStyle.Alert)
        
        var inputTextField: UITextField?;
        _messageDialog.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = ""
            inputTextField = textField
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            if Int(inputTextField!.text!) == -1 {
                self.doBuyerOrder(self.conversation!, offeredPrice: Double((inputTextField?.text)!)!)
            }
        })
        _messageDialog.addAction(cancelAction)
        _messageDialog.addAction(confirmAction)
        self.presentViewController(_messageDialog, animated: true, completion: nil)
    }
    
    @IBAction func onClickBuyerCancelButton(sender: AnyObject) {
        NSLog("onClickBuyerCancelButton")
        
        let _messageDialog = UIAlertController(title: "Buy Now", message: NSLocalizedString("pm_order_cancel_confirm", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Default, handler: nil)
        let confirmAction = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.doBuyerCancel(self.conversation!)
        })
        _messageDialog.addAction(cancelAction)
        _messageDialog.addAction(confirmAction)
        self.presentViewController(_messageDialog, animated: true, completion: nil)
    }
    
    @IBAction func onClickBuyerOrderButton(sender: AnyObject) {
        NSLog("onClickBuyerOrderButton")
        
        let _messageDialog = UIAlertController(title: "Buy Now", message: "Make an offer to Seller", preferredStyle: UIAlertControllerStyle.Alert)
        
        var inputTextField: UITextField?;
        _messageDialog.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = ""
            inputTextField = textField
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            if Int(inputTextField!.text!) == -1 {
                self.doBuyerOrder(self.conversation!, offeredPrice: Double((inputTextField?.text)!)!)
            }
        })
        _messageDialog.addAction(cancelAction)
        _messageDialog.addAction(confirmAction)
        self.presentViewController(_messageDialog, animated: true, completion: nil)
        
    }
    
    @IBAction func onClickSellerAcceptButton(sender: AnyObject) {
        NSLog("onClickSellerAcceptButton")
        let _messageDialog = UIAlertController(title: "Accept", message: NSLocalizedString("pm_order_accept_confirm", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Default, handler: nil)
        let confirmAction = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.doSellerAccept(self.conversation!)
        })
        _messageDialog.addAction(cancelAction)
        _messageDialog.addAction(confirmAction)
        self.presentViewController(_messageDialog, animated: true, completion: nil)
    }
    
    @IBAction func onClickSellerDeclineButton(sender: AnyObject) {
        NSLog("onClickSellerDeclineButton")
        let _messageDialog = UIAlertController(title: "Accept", message: NSLocalizedString("pm_order_decline_confirm", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Default, handler: nil)
        let confirmAction = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.doSellerDecline(self.conversation!)
        })
        _messageDialog.addAction(cancelAction)
        _messageDialog.addAction(confirmAction)
        self.presentViewController(_messageDialog, animated: true, completion: nil)
    }
    
    @IBAction func onClickSellerMessageButton(sender: AnyObject) {
        NSLog("onClickSellerMessageButton")
    }
    
    func doBuyerOrder(conversation: ConversationVM, offeredPrice: Double) {
        let order = conversation.order
        if order != nil && !order!.closed {
            ViewUtil.makeToast(NSLocalizedString("pm_order_already", comment: ""), view: self.view)
            return;
        }
        
        if pendingOrder {
            return;
        }
        
        pendingOrder = true
        
        //let newConversationOrder = NewConversationOrderVconversationId: M(conversation.idofferedPrice: , offeredPrice)
        ViewUtil.showGrayOutView(self, activityLoading: self.activityLoading)
        ApiFacade.newConversationOrder(conversation.id, offeredPrice: offeredPrice, successCallback: onSuccessNewConversationOrder, failureCallback: onFailureConversationOrder)
    }
    
    func doBuyerCancel(conversation: ConversationVM) {
        let order = conversation.order
        if order != nil && order!.closed {
            ViewUtil.makeToast(NSLocalizedString("pm_order_already_closed", comment: ""), view: self.view)
            return
        }
        
        if pendingOrder {
            return
        }
        
        pendingOrder = true
        ApiFacade.cancelConversationOrder(conversation.order!.id, successCallback: onSucessCancelConversationOrder, failureCallback: onFailureCancelConversationOrder)
        
    }
    
    func onSuccessNewConversationOrder(order: ConversationOrderVM) {
        let updatedConversation:ConversationVM = ConversationCache.updateConversationOrder(conversation!.id, order: order)
        initLayout(updatedConversation)
        pendingOrder = false
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
    }
    
    func onFailureConversationOrder(response: String) {
        ViewUtil.makeToast(NSLocalizedString("pm_order_failed", comment: ""), view: self.view)
        pendingOrder = false
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
    }
    
    func onSucessCancelConversationOrder(order: ConversationOrderVM) {
        let updatedConversation = ConversationCache.updateConversationOrder(conversation!.id,order:  order)
        initLayout(updatedConversation)
        
        pendingOrder = false
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
    }
    
    func onFailureCancelConversationOrder(response: String) {
        pendingOrder = false
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
        ViewUtil.makeToast(NSLocalizedString("pm_order_failed", comment: ""), view: self.view)
    }
    
    func doSellerAccept(conversation: ConversationVM) {
        let order = conversation.order
        if order != nil && order!.closed {
            ViewUtil.makeToast(NSLocalizedString("pm_order_already_closed", comment: ""), view: self.view)
            return
        }
    
        if (pendingOrder) {
            return
        }
    
        pendingOrder = true
        
        ApiFacade.acceptConversationOrder(conversation.order!.id, successCallback: onSuccessAcceptConversationOrder, failureCallback: onFailureAcceptConversationOrder)
    }
    
    func doSellerDecline(conversation: ConversationVM) {
        let order = conversation.order
        if order != nil && order!.closed {
            ViewUtil.makeToast(NSLocalizedString("pm_order_already_closed", comment: ""), view: self.view)
            return
        }
        
        if (pendingOrder) {
            return
        }
        
        pendingOrder = true
        
        ApiFacade.declineConversationOrder(conversation.order!.id, successCallback: onSuccessDeclineConversationOrder, failureCallback: onFailureDeclineConversationOrder)
    }
    
    func onSuccessAcceptConversationOrder(order: ConversationOrderVM) {
        let updatedConversation = ConversationCache.updateConversationOrder(conversation!.id, order: order)
        initLayout(updatedConversation);
        pendingOrder = false
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
    }
    
    func onFailureAcceptConversationOrder(response: String) {
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
    }
    
    func onSuccessDeclineConversationOrder(order: ConversationOrderVM) {
        let updatedConversation = ConversationCache.updateConversationOrder(conversation!.id, order: order)
        initLayout(updatedConversation);
        pendingOrder = false
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
    }
    
    func onFailureDeclineConversationOrder(response: String) {
        ViewUtil.showNormalView(self, activityLoading: self.activityLoading)
    }
}