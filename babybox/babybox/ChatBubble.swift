import UIKit

class ChatBubble: UIView {

    var imageViewChat: UIImageView?
    var imageViewBG: UIImageView?
    var text: String?
    var labelChatText: UILabel?
    var timeAgoLbl: UILabel?
    /**
    Initializes a chat bubble view
    
    - parameter data:   ChatBubble Data
    - parameter startY: origin.y of the chat bubble frame in parent view
    
    - returns: Chat Bubble
    */
    init(data: ChatBubbleData, startY: CGFloat){
        
        // 1. Initializing parent view with calculated frame
        super.init(frame: ChatBubble.framePrimary(data.type, startY:startY))
        
        // Making Background transparent
        self.backgroundColor = UIColor.clearColor()
        
        let padding: CGFloat = 10.0
        // 2. Drawing image if any
        if let chatImage = data.image {
            
            let width: CGFloat = min(chatImage.size.width, CGRectGetWidth(self.frame) - 2 * padding)
            let height: CGFloat = chatImage.size.height * (width / chatImage.size.width)
            imageViewChat = UIImageView(frame: CGRectMake(padding, padding, width, height))
            imageViewChat?.image = chatImage
            imageViewChat?.layer.cornerRadius = 5.0
            imageViewChat?.layer.masksToBounds = true
            self.addSubview(imageViewChat!)
        } else if (data.imgId != -1 && data.imgId != nil) {
            imageViewChat = UIImageView(frame: CGRectMake(-10, 5, 30, 30))
            ImageUtil.displayThumbnailProfileImage(data.imgId!, imageView: imageViewChat!)
            self.addSubview(imageViewChat!)
        }
        
        //Create Child SubView for showing opponet details
        let subView = UIView(frame: CGRectMake(0, 0, 25, 25))
        subView.backgroundColor = UIColor.grayColor()
        subView.layer.backgroundColor = ImageUtil.UIColorFromRGB(0xffffff).CGColor
        self.addSubview(subView)
        
        // 3. Going to add Text if any
        if let _ = data.text {
            // frame calculation
            var startX = padding
            let startY:CGFloat = 5.0
            if let _ = imageViewChat {
                startX += CGRectGetMaxX(imageViewChat!.frame)
            }
            
            if data.type == .Mine {
                labelChatText = UILabel(frame: CGRectMake(startX, startY, CGRectGetWidth(self.frame) - 2 * startX , 5))
            } else {
                labelChatText = UILabel(frame: CGRectMake(-5, startY, CGRectGetWidth(self.frame) - 2 * startX + 10 , 5))
            }
            labelChatText?.textAlignment = data.type == .Mine ? .Right : .Left
            labelChatText?.font = UIFont.systemFontOfSize(12)
            labelChatText?.numberOfLines = 0 // Making it multiline
            labelChatText?.text = data.text
            labelChatText?.sizeToFit() // Getting fullsize of it
            if data.type == .Mine {
            } else {
            }
            
            var _startY:CGFloat = 0.0
            if let _ = labelChatText {
                _startY += CGRectGetMaxY(labelChatText!.frame)
            }
            
            if data.type == .Mine {
                self.addSubview(labelChatText!)
                timeAgoLbl = UILabel(frame: CGRectMake(startX, _startY, CGRectGetWidth(self.frame) - 2 * startX , 10))
                self.addSubview(timeAgoLbl!)
                subView.hidden = true
            } else {
                subView.addSubview(labelChatText!)
                timeAgoLbl = UILabel(frame: CGRectMake(-5, _startY, CGRectGetWidth(self.frame) - 2 * startX, 10))
                subView.addSubview(timeAgoLbl!)
            }
            
            timeAgoLbl?.textAlignment = .Left
            timeAgoLbl?.font = UIFont.systemFontOfSize(10)
            timeAgoLbl?.text = data.date?.timeAgo
        }
        
        // 4. Calculation of new width and height of the chat bubble view
        var viewHeight: CGFloat = 0.0
        var viewWidth: CGFloat = 0.0
        if let imageView = imageViewChat {
            // Height calculation of the parent view depending upon the image view and text label
            viewWidth = max(CGRectGetMaxX(labelChatText!.frame), CGRectGetMaxX(timeAgoLbl!.frame)) + padding
            viewHeight = max(CGRectGetMaxY(labelChatText!.frame), CGRectGetMaxY(timeAgoLbl!.frame)) + padding
            
        } else {
            viewHeight = CGRectGetMaxY(timeAgoLbl!.frame) + padding/2
            viewWidth = CGRectGetWidth(timeAgoLbl!.frame) + CGRectGetMinX(labelChatText!.frame) + padding
        }
        
        // 5. Adding new width and height of the chat bubble frame
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), viewWidth, viewHeight)
        
        // 6. Adding the resizable image view to give it bubble like shape
        let bubbleImageFileName = data.type == .Mine ? "bubbleMine" : "bubbleSomeone"
        imageViewBG = UIImageView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)))
        let vChat = UIView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)))
        
        if data.type == .Mine {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(14, 14, 17, 28))
            vChat.layer.backgroundColor = ImageUtil.UIColorFromRGB(0xdcf8c6).CGColor  //UIColor.yellowColor().CGColor
        } else {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImageWithCapInsets(UIEdgeInsetsMake(14, 22, 17, 20))
            vChat.layer.backgroundColor = ImageUtil.UIColorFromRGB(0xEFEFF4).CGColor
        }
        self.addSubview(vChat)
        self.sendSubviewToBack(vChat)
        //self.addSubview(imageViewBG!)
        //self.sendSubviewToBack(imageViewBG!)
        
        // Frame recalculation for filling up the bubble with background bubble image
        let repsotionXFactor:CGFloat = data.type == .Mine ? 0.0 : -15.0
        let bgImageNewX = CGRectGetMinX(imageViewBG!.frame) + repsotionXFactor
        let bgImageNewWidth =  CGRectGetWidth(imageViewBG!.frame) + CGFloat(12.0)
        let bgImageNewHeight =  CGRectGetHeight(imageViewBG!.frame) + CGFloat(6.0)
        imageViewBG?.frame = CGRectMake(bgImageNewX - 5, -3.0, bgImageNewWidth + 5, bgImageNewHeight + 5)
        vChat.frame = CGRectMake(bgImageNewX - 5, -3.0, bgImageNewWidth + 5, bgImageNewHeight )
        vChat.bounds = CGRectInset(vChat.frame, 5.0, 3.0)
        
        vChat.layer.cornerRadius = 5.0
        vChat.layer.masksToBounds = true
        
        subView.frame = CGRectMake(20, -3.0, bgImageNewWidth + 5, bgImageNewHeight )
        subView.bounds = CGRectInset(vChat.frame, 0.0, 0.0)
        
        subView.layer.cornerRadius = 5.0
        subView.layer.masksToBounds = true
        
        //if data.type == .Mine {
        //    subView.hidden = true
        //}
        // Keepping a minimum distance from the edge of the screen
        var newStartX:CGFloat = 0.0
        if data.type == .Mine {
            // Need to maintain the minimum right side padding from the right edge of the screen
            let extraWidthToConsider = CGRectGetWidth(imageViewBG!.frame)
            //newStartX = ScreenSize.SCREEN_WIDTH - extraWidthToConsider
            newStartX = UIScreen.mainScreen().bounds.size.width - extraWidthToConsider
        } else {
            // Need to maintain the minimum left side padding from the left edge of the screen
            newStartX = -CGRectGetMinX(imageViewBG!.frame) + 3.0
        }
        
        self.frame = CGRectMake(newStartX, CGRectGetMinY(self.frame), CGRectGetWidth(frame), CGRectGetHeight(frame))
        
    }

    // 6. View persistance support
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - FRAME CALCULATION
    class func framePrimary(type:BubbleDataType, startY: CGFloat) -> CGRect{
        let paddingFactor: CGFloat = 0.02
        let sidePadding = UIScreen.mainScreen().bounds.size.width * paddingFactor
        let maxWidth = UIScreen.mainScreen().bounds.size.width * 0.65 // We are cosidering 65% of the screen width as the Maximum with of a single bubble
        let startX: CGFloat = type == .Mine ? UIScreen.mainScreen().bounds.size.width * (CGFloat(1.0) - paddingFactor) - maxWidth : sidePadding
        return CGRectMake(startX, startY, maxWidth, 5) // 5 is the primary height before drawing starts
    }

}
