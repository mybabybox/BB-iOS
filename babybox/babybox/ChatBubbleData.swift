import UIKit // For using UIImage

// 1. Type Enum
/**
Enum specifing the type

- Mine:     Chat message is outgoing
- Opponent: Chat message is incoming
*/
enum BubbleDataType: Int {
    case Me = 0
    case You
}

/// DataModel for maintaining the message data for a single chat bubble
class ChatBubbleData {
    
    // 2.Properties
    var text: String?
    var image: UIImage?
    var date: NSDate?
    var type: BubbleDataType
    var buyerId: Int
    var imageId: Int
    var system: Bool
    
    // 3. Initialization
    init(text: String?,image: UIImage?,date: NSDate? , type:BubbleDataType = .Me, buyerId: Int, imageId: Int, system: Bool) {
        // Default type is Mine
        self.text = text
        self.image = image
        self.date = date
        self.type = type
        self.buyerId = buyerId
        self.imageId = imageId
        self.system = system
    }
}