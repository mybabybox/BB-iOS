import UIKit
import SwiftEventBus

class MessagesViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    @IBOutlet var messageComposingView: UIView!
    @IBOutlet weak var messageCointainerScroll: UIScrollView!
    @IBOutlet weak var buttomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var offset: Int = 0
    var loadingMessage: Bool = false
    var conversationId: Int = 0
    var selectedImage : UIImage?
    var lastChatBubbleY: CGFloat = 10.0
    var internalPadding: CGFloat = 8.0
    var lastMessageType: BubbleDataType?
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false //2
        imagePicker.sourceType = .PhotoLibrary //3
        sendButton.enabled = false
        
        ApiController.instance.getMessages(self.conversationId, offset: offset)
        SwiftEventBus.onMainThread(self, name: "getMessagesSuccess") { result in
            // UI thread
            let resultDto: MessageVM = result.object as! MessageVM
            self.handleChatMessageResponse(resultDto)
        }
        
        self.messageCointainerScroll.contentSize = CGSizeMake(CGRectGetWidth(messageCointainerScroll.frame), lastChatBubbleY + internalPadding)
        self.addKeyboardNotifications()
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
            let bubbleData = ChatBubbleData(text: textField.text, image: selectedImage, date: NSDate(), type: .Mine)
            addChatBubble(bubbleData)
            textField.resignFirstResponder()
            
            ApiController.instance.postMessage(self.conversationId, message: bubbleData.text!)
    }
        
    @IBAction func cameraButtonClicked(sender: AnyObject) {
            self.presentViewController(imagePicker, animated: true, completion: nil)//4
    }
        
        
    func addRandomTypeChatBubble() {
            let bubbleData = ChatBubbleData(text: textField.text, image: selectedImage, date: NSDate(), type: getRandomChatDataType())
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
    
    //MARK: Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        let bubbleData = ChatBubbleData(text: textField.text, image: chosenImage, date: NSDate(), type: .Mine)
        
        //post new chat message
        //ApiController.instance.postMessage(String(self.conversationId), message: bubbleData.text!, imageData: bubbleData.image!)
        
        addChatBubble(bubbleData)
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        
    }
    
    func handleChatMessageResponse(result: MessageVM){
        for var i=0; i<result.messages.count; i++ {
            if(result.messages[i].senderName == UserInfoCache.getUser().firstName){
                if(result.messages[i].hasImage == true){
                    
                }else{
                    let chatBubbleData1 = ChatBubbleData(text: result.messages[i].body, image:nil, date: NSDate(), type: .Mine)
                    addChatBubble(chatBubbleData1)
                }
                
            }else{
                if(result.messages[i].hasImage == true){
                    
                }else{
                    let chatBubbleData2 = ChatBubbleData(text: result.messages[i].body, image:nil, date: NSDate(), type: .Opponent)
                    addChatBubble(chatBubbleData2)
                }
            }
        }
        self.offset++
        self.loadingMessage = true
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - constants.FEED_LOAD_SCROLL_THRESHOLD {
            if (loadingMessage) {
                ApiController.instance.getMessages(self.conversationId, offset: offset)
                self.loadingMessage = false
            }
        }
    }
}