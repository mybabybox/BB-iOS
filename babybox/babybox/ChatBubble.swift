import UIKit

class ChatBubble: UIView {
    // Properties
    var buyerImageView: UIImageView?
    var imageViewChat: UIImageView?
    var imageViewBG: UIImageView?
    var text: String?
    var labelChatText: UILabel?
    var timeAgoText: UILabel?
    var imageId: Int?
    var image: UIImage = UIImage()
    
    /**
     Initializes a chat bubble view
     
     :param: data   ChatBubble Data
     :param: startY origin.y of the chat bubble frame in parent view
     
     :returns: Chat Bubble
     */
    init(data: ChatBubbleData, startY: CGFloat){
        
        // 1. Initializing parent view with calculated frame
        super.init(frame: ChatBubble.framePrimary(data.type, startY:startY))
        
        // Making Background color as gray color
        if (data.type == .Me) {
            self.backgroundColor = Color.CHAT_ME
        } else {
            //self.backgroundColor = Color.CHAT_YOU
        }
        self.layer.cornerRadius = 10
        
        let padding: CGFloat = 10.0
        
        // 1. Drawing buyer image
        let startX: CGFloat = 20.0
        if (data.type == .You) {
            //if let chatImage = data.image {
            if (data.buyerId != -1) {
                let userImgView = UIView()
                buyerImageView = UIImageView(frame: CGRectMake(0, 0, 40, 40))
                ImageUtil.displayThumbnailProfileImage(data.buyerId, imageView: buyerImageView!)
                userImgView.addSubview(buyerImageView!)
                self.addSubview(userImgView)
            }
        }
        
        let messageView: UIView = UIView(frame: CGRectMake(startX, 0, self.frame.width, self.frame.height))
        if (data.type == .You) {
            messageView.backgroundColor = Color.CHAT_YOU
            messageView.layer.cornerRadius = 10
            ViewUtil.displayMessageView(messageView)
            self.addSubview(messageView)
        } else {
            ViewUtil.displayMessageView(self)
        }
        
        // 2. Going to add Text if any
        if let _ = data.text {
            // frame calculation
            let startY: CGFloat = 10.0
            labelChatText = UILabel(frame: CGRectMake(startX, startY, CGRectGetWidth(self.frame) - 2 * startX , 5))
            labelChatText?.textAlignment = data.type == .Me ? .Right : .Left
            labelChatText?.numberOfLines = 0 // Making it multiline
            labelChatText?.text = data.text
            if data.system {
                labelChatText?.textColor = Color.DARK_GRAY_2
                labelChatText?.font = UIFont.boldSystemFontOfSize(15)
            } else {
                labelChatText?.textColor = Color.DARK_GRAY_2
                labelChatText?.font = UIFont.systemFontOfSize(15)
            }
            labelChatText?.sizeToFit() // Getting fullsize of it
            
            if (data.type == .You) {
                messageView.addSubview(labelChatText!)
            } else {
                self.addSubview(labelChatText!)
            }
        }
        
        // 2. Drawing image if any
        //if let chatImage = data.image {
        if (data.imageId != -1) {
            let frameWidth = UIScreen.mainScreen().bounds.size.width  * Constants.MESSAGE_IMAGE_WIDTH
            imageViewChat = UIImageView(frame: CGRectMake(startX, CGRectGetHeight(labelChatText!.frame) + 10, frameWidth, frameWidth))
            ImageUtil.displayOriginalMessageImage(data.imageId, imageView: imageViewChat!)
            if (data.type == .You) {
                messageView.addSubview(imageViewChat!)
            } else {
                self.addSubview(imageViewChat!)
            }
            self.imageId = data.imageId
            let singleTap = UITapGestureRecognizer(target: self, action: "viewFullScreenImageByUrl:")
            singleTap.numberOfTapsRequired = 1 // Initialized to 1 by default
            singleTap.numberOfTouchesRequired = 1 // Initialized to 1 by default
            imageViewChat!.addGestureRecognizer(singleTap)
            imageViewChat!.userInteractionEnabled = true
        }
        
        if let chatImage = data.image {
            let frameWidth = UIScreen.mainScreen().bounds.size.width  * Constants.MESSAGE_IMAGE_WIDTH
            imageViewChat = UIImageView(frame: CGRectMake(startX, CGRectGetHeight(labelChatText!.frame) + 10, frameWidth, frameWidth))
            imageViewChat?.image = chatImage
            imageViewChat?.layer.cornerRadius = 10.0
            imageViewChat?.layer.masksToBounds = true
            self.addSubview(imageViewChat!)
            self.image = data.image!
            let singleTap = UITapGestureRecognizer(target: self, action: "viewFullScreenImage:")
            singleTap.numberOfTapsRequired = 1 // Initialized to 1 by default
            singleTap.numberOfTouchesRequired = 1 // Initialized to 1 by default
            imageViewChat!.addGestureRecognizer(singleTap)
            imageViewChat!.userInteractionEnabled = true
        }
        
        // 3. Going to add Text if any
        if let _ = data.text {
            // frame calculation
            //var startX = padding
            var startY:CGFloat = 5.0
            if let _ = imageViewChat {
                startY += CGRectGetMaxY(imageViewChat!.frame)
            } else {
                startY += CGRectGetMaxY(labelChatText!.frame)
            }
            timeAgoText = UILabel(frame: CGRectMake(startX, startY, CGRectGetWidth(self.frame) - 2 * startX , 5))
            timeAgoText?.textAlignment = data.type == .Me ? .Right : .Left
            timeAgoText?.font = UIFont.systemFontOfSize(11)
            timeAgoText?.numberOfLines = 0 // Making it multiline
            timeAgoText?.text = data.date?.timeAgo
            timeAgoText?.sizeToFit() // Getting fullsize of it
            timeAgoText?.textColor = Color.GRAY
            if (data.type == .You) {
                messageView.addSubview(timeAgoText!)
            } else {
                self.addSubview(timeAgoText!)
            }
        }
        
        // 4. Calculation of new width and height of the chat bubble view
        var viewHeight: CGFloat = 0.0
        var viewWidth: CGFloat = 0.0
        if let _ = imageViewChat {
            // Height calculation of the parent view depending upon the image view and text label
            viewWidth = max(CGRectGetMaxX(imageViewChat!.frame), CGRectGetMaxX(timeAgoText!.frame)) + padding
            viewHeight = max(CGRectGetMaxY(imageViewChat!.frame), CGRectGetMaxY(timeAgoText!.frame)) + padding
            
        } else {
            viewHeight = CGRectGetMaxY(timeAgoText!.frame) + padding/2
            
            viewWidth = max(CGRectGetMaxX(labelChatText!.frame), CGRectGetMaxX(timeAgoText!.frame)) + CGRectGetMinX(timeAgoText!.frame) + padding
            //viewWidth = CGRectGetWidth(labelChatText!.frame) + CGRectGetMinX(timeAgoText!.frame) + padding
        }
        
        // 5. Adding new width and height of the chat bubble frame
        messageView.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), viewWidth, viewHeight)
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), viewWidth, viewHeight)
        
        // 6. Adding the resizable image view to give it bubble like shape
        let bubbleImageFileName = data.type == .Me ? "" : ""
        imageViewBG = UIImageView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)))
        if data.type == .Me {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(14, 14, 17, 28))
        } else {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(14, 22, 17, 20))
        }
        
        if (data.type == .You) {
            messageView.addSubview(imageViewBG!)
            messageView.sendSubviewToBack(imageViewBG!)
        } else {
            self.addSubview(imageViewBG!)
            self.sendSubviewToBack(imageViewBG!)
        }
        
        // Frame recalculation for filling up the bubble with background bubble image
        let repsotionXFactor:CGFloat = data.type == .Me ? 0.0 : -8.0
        let bgImageNewX = CGRectGetMinX(imageViewBG!.frame) + repsotionXFactor
        let bgImageNewWidth =  CGRectGetWidth(imageViewBG!.frame) + CGFloat(12.0)
        let bgImageNewHeight =  CGRectGetHeight(imageViewBG!.frame) + CGFloat(6.0)
        imageViewBG?.frame = CGRectMake(bgImageNewX, 0.0, bgImageNewWidth, bgImageNewHeight)
        
        var newStartX:CGFloat = 0.0
        if data.type == .Me {
            // Need to maintain the minimum right side padding from the right edge of the screen
            let extraWidthToConsider = CGRectGetWidth(imageViewBG!.frame)
            newStartX = UIScreen.mainScreen().bounds.size.width - extraWidthToConsider
        } else {
            // Need to maintain the minimum left side padding from the left edge of the screen
            newStartX = -CGRectGetMinX(imageViewBG!.frame) + 3.0
        }
        messageView.frame = CGRectMake(45, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))
        self.frame = CGRectMake(newStartX, CGRectGetMinY(self.frame), CGRectGetWidth(frame), CGRectGetHeight(frame))
        
    }
    
    // 6. View persistance support
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - FRAME CALCULATION
    class func framePrimary(type:BubbleDataType, startY: CGFloat) -> CGRect{
        let paddingFactor: CGFloat = 0.02
        let sidePadding = UIScreen.mainScreen().bounds.size.width * paddingFactor
        let maxWidth = UIScreen.mainScreen().bounds.size.width  * Constants.MESSAGE_IMAGE_WIDTH // We are cosidering 65% of the screen width as the Maximum with of a single bubble
        let startX: CGFloat = type == .Me ? UIScreen.mainScreen().bounds.size.width  * (CGFloat(1.0) - paddingFactor) - maxWidth : sidePadding
        return CGRectMake(startX, startY, maxWidth, 5) // 5 is the primary height before drawing starts
    }

    func viewFullScreenImage(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            ViewUtil.viewFullScreenImage(self.image, viewController: MessagesViewController.instance!)
        }
    }

    func viewFullScreenImageByUrl(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            let imageUrl = ImageUtil.getOriginalMessageImageUrl(self.imageId!)
            ViewUtil.viewFullScreenImageByUrl(imageUrl, viewController: MessagesViewController.instance!)
        }
    }
}
