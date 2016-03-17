import UIKit
import SwiftEventBus

class MessagesViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    @IBOutlet weak var prodImg: UIImageView!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var sellTextLbl: UILabel!
    @IBOutlet weak var buyTextLbl: UILabel!
    @IBOutlet var messageComposingView: UIView!
    @IBOutlet weak var messageCointainerScroll: UIScrollView!
    @IBOutlet weak var buttomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var uploadImgSrc: UIImageView!
    var offset: Int64 = 0
    var loading: Bool = false
    var conversation: ConversationVM? = nil
    var selectedImage : UIImage?
    var lastChatBubbleY: CGFloat = 10.0
    var internalPadding: CGFloat = 8.0
    var lastMessageType: BubbleDataType?
    
    var imagePicker = UIImagePickerController()
    
    var conversationViewController: ConversationsViewController?
    
    override func viewDidDisappear(animated: Bool) {
        //SwiftEventBus.unregister(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.unregister(self)
        self.navigationItem.title = self.conversation?.userName
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true //2
        imagePicker.sourceType = .PhotoLibrary //3
        sendButton.enabled = false
        
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
        
        ApiController.instance.getMessages((self.conversation?.id)!, offset: offset)
        
        self.messageCointainerScroll.contentSize = CGSizeMake(CGRectGetWidth(messageCointainerScroll.frame), lastChatBubbleY + internalPadding)
        self.addKeyboardNotifications()
        
        ImageUtil.displayPostImage(self.conversation!.postImage, imageView: prodImg)
        self.prodName.text = self.conversation?.postTitle
        self.prodPrice.text = Constants.CURRENCY_SYMBOL + String(self.conversation!.postPrice.toIntMax())
        
        if self.conversation!.postOwner == false {
            self.buyTextLbl.hidden = true
            self.sellTextLbl.hidden=false
            
        } else if(self.conversation!.postOwner == true) {
            self.sellTextLbl.hidden = true
            self.buyTextLbl.hidden = false
        }
        
        let userProfileBtn: UIButton = UIButton()
        userProfileBtn.setImage(UIImage(named: "w_profile"), forState: UIControlState.Normal)
        userProfileBtn.addTarget(self, action: "onClickProfileBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        userProfileBtn.frame = CGRectMake(0, 0, 35, 35)
        let userProfileBarBtn = UIBarButtonItem(customView: userProfileBtn)
        self.navigationItem.rightBarButtonItems = [userProfileBarBtn]
        
        ImageUtil.displayButtonRoundBorder(self.sendButton)
        
        NSNotificationCenter.defaultCenter().addObserverForName("CroppedImage", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.uploadImgSrc.image = notification.object! as? UIImage
        }
        
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
                self.moveToLastMessage()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.buttomLayoutConstraint.constant = 0.0
            }) { (completed: Bool) -> Void in
                self.moveToLastMessage()
        }
    }
    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        let bubbleData = ChatBubbleData(text: textField.text, image: self.uploadImgSrc.image, date: NSDate(), type: .Mine, imgId: -1)
        addChatBubble(bubbleData)
        textField.resignFirstResponder()
        
        if self.conversationViewController != nil {
            self.conversationViewController!.updateOpenedConversation = true
        }
        if (self.uploadImgSrc.image == nil) {
            ApiController.instance.newMessage(self.conversation!.id, message: bubbleData.text!, imagePath: "")
        } else {
            ApiController.instance.newMessage(self.conversation!.id, message: bubbleData.text!, imagePath: self.uploadImgSrc.image!)
        }
        
        self.moveToLastMessage()
    }
        
    @IBAction func cameraButtonClicked(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: "Take Photo:", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .Camera
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let photoGalleryAction = UIAlertAction(title: "Photo Album", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.navigationController!.presentViewController(self.imagePicker, animated: true, completion: nil)
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
    
    /*func addRandomTypeChatBubble() {
        let bubbleData = ChatBubbleData(text: textField.text, image: selectedImage, date: NSDate(), type: getRandomChatDataType(), imgId: -1)
        addChatBubble(bubbleData)
    }*/
    
    func addChatBubble(data: ChatBubbleData) {
        let padding:CGFloat = lastMessageType == data.type ? internalPadding/3.0 :  internalPadding
        
        let chatBubble = ChatBubble(data: data, startY:lastChatBubbleY + padding)
        self.messageCointainerScroll.addSubview(chatBubble)
        
        lastChatBubbleY = CGRectGetMaxY(chatBubble.frame)
        
        self.messageCointainerScroll.contentSize = CGSizeMake(CGRectGetWidth(messageCointainerScroll.frame), lastChatBubbleY + internalPadding)
        self.moveToLastMessage()
        lastMessageType = data.type
        textField.text = ""
        sendButton.enabled = false
    }
    
    func moveToLastMessage() {
        if messageCointainerScroll.contentSize.height > CGRectGetHeight(messageCointainerScroll.frame) {
            let contentOffSet = CGPointMake(0.0, messageCointainerScroll.contentSize.height - CGRectGetHeight(messageCointainerScroll.frame))
            self.messageCointainerScroll.setContentOffset(contentOffSet, animated: true)
        }
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
        if text.characters.count > 0 {
            sendButton.enabled = true
        } else {
            sendButton.enabled = false
        }
        return true
    }
    
    
    @IBAction func onClickProdItem(sender: AnyObject) {
        
        let feedItem: PostVMLite = PostVMLite()
        feedItem.id = (self.conversation?.postId)!
        
        let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("FeedProductViewController") as? FeedProductViewController
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        //self.uploadImgSrc.image = chosenImage
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let controller = ImageCropViewController.init(image: pickedImage)
            self.navigationController?.pushViewController(controller, animated: true)
        }
        /*self.collectionView.reloadData()*/
        dismissViewControllerAnimated(true, completion: nil)
        
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        
    }
    
    func handleChatMessageResponse(result: MessageResponseVM){
        result.messages.sortInPlace({ $0.createdDate < $1.createdDate })
        //result.messages.sortInPlace({ $0.createdDate.compare($1.createdDate) == NSComparisonResult.OrderedAscending })
        
        for var i = 0; i < result.messages.count; i++ {
            let message: MessageVM = result.messages[i]
            let messageDt = NSDate(timeIntervalSince1970:Double(message.createdDate) / 1000.0)
            if (UserInfoCache.getUser().id == message.senderId) {
                let chatBubbleData = ChatBubbleData(text: message.body, image:nil, date: messageDt, type: .Mine, imgId: -1)
                addChatBubble(chatBubbleData)
            } else {
                let chatBubbleData = ChatBubbleData(text: message.body, image:nil, date: messageDt, type: .Opponent, imgId: message.senderId)
                addChatBubble(chatBubbleData)
            }
            
        }
        loading = false
        //ViewUtil.hideActivityLoading(self.activityLoading)
    
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - Constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (!loading) {
                //ApiController.instance.getMessages((self.conversation?.id)!, offset: feedOffset)
                self.loading = false
            }
        }
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
    
    func handleCroppedImage(notification: NSNotification){
        print("")
        
    }
    
}