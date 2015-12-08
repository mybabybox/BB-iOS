

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView?
    var photo: UIImage? {
        didSet {
            imageView?.image = photo
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView?.image = photo
    }
    
    @IBAction func dismiss(sender: AnyObject!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
