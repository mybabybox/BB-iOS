
import UIKit

class DetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var imageHt: NSLayoutConstraint!
    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var prodCondition: UILabel!
    @IBOutlet weak var prodOriginalPrice: UILabel!
    @IBOutlet weak var prodLocation: UIImageView!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var prodCategory: UILabel!
    @IBOutlet weak var prodTimer: UIImageView!
    @IBOutlet weak var prodTimerCount: UILabel!
    
    //MASK User Info Section
    
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var noOfProducts: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postedUserImg: UIImageView!
    
    @IBOutlet weak var viewBtnIns: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
}
