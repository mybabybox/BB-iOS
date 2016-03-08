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
    
    var offset: Int64 = 0
    var loading: Bool = false
    var conversation: ConversationVM? = nil
    var selectedImage : UIImage?
    var lastChatBubbleY: CGFloat = 10.0
    var internalPadding: CGFloat = 8.0
    var lastMessageType: BubbleDataType?
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.conversation?.userName
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false //2
        imagePicker.sourceType = .PhotoLibrary //3
        sendButton.enabled = false
        
        ApiController.instance.getMessages((self.conversation?.id)!, offset: offset)
        SwiftEventBus.onMainThread(self, name: "getMessagesSuccess") { result in
            // UI thread
            let resultDto: MessageVM = result.object as! MessageVM
            self.handleChatMessageResponse(resultDto)
        }
        
        self.messageCointainerScroll.contentSize = CGSizeMake(CGRectGetWidth(messageCointainerScroll.frame), lastChatBubbleY + internalPadding)
        self.addKeyboardNotifications()
        
        ImageUtil.displayPostImage(self.conversation!.postImage, imageView: prodImg)
        self.prodName.text = self.conversation?.postTitle
        self.prodPrice.text = constants.currencySymbol + String(self.conversation!.postPrice.toIntMax())
        
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
            let bubbleData = ChatBubbleData(text: textField.text, image: selectedImage, date: NSDate(), type: .Mine, imgId: -1)
            addChatBubble(bubbleData)
            textField.resignFirstResponder()
            
            ApiController.instance.postMessage((self.conversation?.id)!, message: bubbleData.text!)
    }
        
    @IBAction func cameraButtonClicked(sender: AnyObject) {
            self.presentViewController(imagePicker, animated: true, completion: nil)//4
    }
        
    
    func addRandomTypeChatBubble() {
            let bubbleData = ChatBubbleData(text: textField.text, image: selectedImage, date: NSDate(), type: getRandomChatDataType(), imgId: -1)
            addChatBubble(bubbleData)
    }
    
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
            text = String(format:"%@%@",txtField.text!, string);
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
        let bubbleData = ChatBubbleData(text: textField.text, image: chosenImage, date: NSDate(), type: .Mine, imgId: -1)
        
        //post new chat message
        //ApiController.instance.postMessage(String(self.conversationId), message: bubbleData.text!, imageData: bubbleData.image!)
        
        addChatBubble(bubbleData)
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        
    }
    
    func handleChatMessageResponse(result: MessageVM){
        result.messages.sortInPlace({ $0.createdDate < $1.createdDate })
        //result.messages.sortInPlace({ $0.createdDate.compare($1.createdDate) == NSComparisonResult.OrderedAscending })
        
        for var i=0; i<result.messages.count; i++ {
            let message: MessageDetailVM = result.messages[i]
            let messageDt = NSDate(timeIntervalSince1970:Double(message.createdDate) / 1000.0)
            if (UserInfoCache.getUser().id == message.senderId) {
                let chatBubbleData = ChatBubbleData(text: message.body, image:nil, date: messageDt, type: .Mine, imgId: -1)
                addChatBubble(chatBubbleData)
            } else {
                let chatBubbleData = ChatBubbleData(text: result.messages[i].body, image:nil, date: messageDt, type: .Opponent, imgId: message.senderId)
                addChatBubble(chatBubbleData)
            }
            
        }
        loading = false
        //ViewUtil.hideActivityLoading(self.activityLoading)
    
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - constants.FEED_LOAD_SCROLL_THRESHOLD {
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
    
}