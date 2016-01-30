//
//  UserFeedViewController.swift
//  babybox
//
//  Created by Mac on 30/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

private let reuseIdentifier = "Cell"

class UserFeedViewController: CustomNavigationController {

    //@IBOutlet weak var userFeedTips: UIView!
    //@IBOutlet weak var tipSection: NSLayoutConstraint!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var pageOffSet: Int64 = 0
    var currentIndex = 0
    var userPostedProducts: [PostModel] = []
    var userLikedProducts: [PostModel] = []
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var reuseIdentifier = "CellType"
    var loadingProducts: Bool = false
    var isWidthSet = false
    let shapeLayer = CAShapeLayer()
    var feedFilter: FeedFilter.FeedType? = FeedFilter.FeedType.USER_POSTED
    var userId: Int = 0
    var userInfo: UserInfoVM? = nil
    var isHeightSet: Bool = false
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if (self.userId == 0) {
            self.userId = constants.userInfo.id
        }
        
        
        /*if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.MY_PROFILE_TIPS)) {
            self.userFeedTips.hidden = false
            SharedPreferencesUtil.getInstance().setScreenViewed(SharedPreferencesUtil.Screen.MY_PROFILE_TIPS)
        } else {
            self.userFeedTips.hidden = true
            self.tipSection.constant = -5
        }*/
        
        SwiftEventBus.onMainThread(self, name: "userInfoByIdSuccess") { result in
            self.userInfo = result.object as? UserInfoVM
            ApiControlller.apiController.getUserPostedFeeds(self.userId, offSet: 0)
            ApiControlller.apiController.getUserLikedFeeds(self.userId, offSet: 0)
        }
        
        SwiftEventBus.onMainThread(self, name: "userInfoByIdFailed") { result in
            // UI thread
            //TODO
        }
        
        SwiftEventBus.onMainThread(self, name: "userLikedFeedSuccess") { result in
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleUserLikedProductsuccess(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "userLikedFeedFailed") { result in
            // UI thread
            //TODO
        }
        
        SwiftEventBus.onMainThread(self, name: "userPostFeedSuccess") { result in
            // UI thread
            let resultDto: [PostModel] = result.object as! [PostModel]
            self.handleUserPostedProductsuccess(resultDto)
        }
        
        SwiftEventBus.onMainThread(self, name: "userPostFeedFailed") { result in
            // UI thread
            //TODO
        }
        
        ApiControlller.apiController.getUserInfoById(self.userId)
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 5
        uiCollectionView.collectionViewLayout = flowLayout
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0;
        if (collectionView.tag == 2) {
            count = 1
        }else{
            count = self.getTypeProductInstance().count
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (collectionView.tag == 2){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("headerCell", forIndexPath: indexPath) as! UserFeedHeaderViewCell
            
            //Divide the width equally among buttons..
            if (!isWidthSet) {
                setSizesForFilterButtons(cell)
            }
            if (self.userInfo != nil) {
                
                cell.displayName.text = self.userInfo?.displayName
                let imagePath =  constants.imagesBaseURL + "/image/get-profile-image-by-id/" + String(self.userInfo!.id)
                let imageUrl  = NSURL(string: imagePath)
                cell.userImg.kf_setImageWithURL(imageUrl!)
                
                if (self.userInfo!.numFollowers > 0) {
                    cell.followersBtn.setTitle("Followers " + String(self.userInfo!.numFollowers), forState: UIControlState.Normal)
                } else {
                    cell.followersBtn.setTitle("Followers", forState: UIControlState.Normal)
                }
                
                if (self.userInfo!.numFollowings > 0) {
                    cell.followingBtn.setTitle("Following " + String(self.userInfo!.numFollowings), forState: UIControlState.Normal)
                } else {
                    cell.followingBtn.setTitle("Following", forState: UIControlState.Normal)
                }
                
                cell.segmentControl.setTitle("Products " + String(self.userPostedProducts.count), forSegmentAtIndex: 0)
                cell.segmentControl.setTitle("Likes " + String(self.userLikedProducts.count), forSegmentAtIndex: 1)
                
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedProductCollectionViewCell
            
            cell.likeImageIns.tag = indexPath.item
            
            let post = self.getTypeProductInstance()[indexPath.row]
            if (post.hasImage) {
                let imagePath =  constants.imagesBaseURL + "/image/get-post-image-by-id/" + String(post.images[0])
                let imageUrl  = NSURL(string: imagePath)
                //cell.prodImageView.kf_setImageWithURL(imageUrl!,
                 //   placeholderImage: nil,
                 //   optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
                cell.prodImageView.kf_setImageWithURL(imageUrl!)
            }
           // cell.likeCount.text = String(post.numLikes)
            if (!post.isLiked) {
                cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            } else {
                cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            }
            
            cell.title.text = post.title
            
            cell.productPrice.text = "\(constants.currencySymbol) \(String(stringInterpolationSegment: Int(post.price)))"
            
            if (post.originalPrice != 0 && post.originalPrice != -1 && post.originalPrice != Int(post.price)) {
                let attrString = NSAttributedString(string: "\(constants.currencySymbol) \(String(stringInterpolationSegment:Int(post.originalPrice)))", attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
                cell.originalPrice.attributedText = attrString
            } else {
                cell.originalPrice.attributedText = NSAttributedString(string: "")
            }
            
            cell.likeImageIns.addTarget(self, action: "onLikeBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [194/255, 195/255, 200/255, 1.0])
            cell.layer.borderWidth = 1
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.currentIndex = indexPath.row
        
        if (collectionView.tag == 2){
        } else {
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("ProductViewController") as! ProductDetailsViewController
            
            vController.productModel = self.getTypeProductInstance()[self.currentIndex]
            ApiControlller.apiController.getProductDetails(String(Int(self.getTypeProductInstance()[self.currentIndex].id)))
            self.tabBarController!.tabBar.hidden = true
            self.navigationController?.pushViewController(vController, animated: true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        
        
        if (kind == UICollectionElementKindSectionHeader) {
            
            let headerView : ProfileFeedReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! ProfileFeedReusableView
            headerView.headerViewCollection.reloadData()
            reusableView = headerView
        }
        
        return reusableView!
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (collectionView.tag == 2) {
            if let _ = collectionViewTopCellSize {
                setCollectionViewSizesInsetsForTopView()
                return collectionViewTopCellSize!
            }
        } else {
            if let _ = collectionViewCellSize {
                return collectionViewCellSize!
            }
        }
        return CGSizeZero
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (collectionView.tag == 2){
            return CGSizeZero
        } else {
            /*var ht: CGFloat = 0.0
            for view in collectionView.subviews as [UIView] {
                ht += view.frame.height
            }*/
            return CGSizeMake(self.view.frame.width, 305)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "followingCalls") {
            let vController = segue.destinationViewController as! FollowingViewController
            vController.userId = userId
        } else if (segue.identifier == "followersCall") {
            let vController = segue.destinationViewController as! FollowersViewController
            vController.userId = userId
        }
    }
    
    // MARK: Custom Implementation methods
    
    func handleUserPostedProductsuccess(resultDto: [PostModel]) {
        if (!resultDto.isEmpty) {
            
            if (self.userPostedProducts.count == 0) {
                self.userPostedProducts = resultDto
            } else {
                self.userPostedProducts.appendContentsOf(resultDto)
            }
            if (feedFilter == FeedFilter.FeedType.USER_POSTED) {
                self.uiCollectionView.reloadData()
            }
            self.pageOffSet = Int64(self.userPostedProducts[self.userPostedProducts.count-1].offset)
        }
        
        self.loadingProducts = true
    }
    
    func handleUserLikedProductsuccess(resultDto: [PostModel]) {
        if (!resultDto.isEmpty) {
            
            if (self.userLikedProducts.count == 0) {
                self.userLikedProducts = resultDto
            } else {
                self.userLikedProducts.appendContentsOf(resultDto)
            }
            if (feedFilter == FeedFilter.FeedType.USER_LIKED) {
                self.uiCollectionView.reloadData()
            }
            self.pageOffSet = Int64(self.userLikedProducts[self.userLikedProducts.count-1].offset)
        }
        
        self.loadingProducts = true
    }
    
        
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let velocity: CGFloat = scrollView.panGestureRecognizer.velocityInView(scrollView).y
        
        if (velocity > 0) {
            NSLog("Up");
            UIView.animateWithDuration(0.5, animations: {
                
                //self.tabBarController?.tabBar.frame.size.height = 0
                self.tabBarController?.tabBar.hidden = false
                self.hidesBottomBarWhenPushed = true
                
                if (self.isHeightSet) {
                    let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
                    self.view.frame.size.height = self.view.frame.size.height - tabBarHeight
                    self.isHeightSet = false
                }
            })
        } else if (velocity < 0) {
            NSLog("Down")
            UIView.animateWithDuration(0.5, animations: {
                self.tabBarController?.tabBar.hidden = true
                self.hidesBottomBarWhenPushed = true
                if (!self.isHeightSet) {
                    let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
                    self.view.frame.size.height = self.view.frame.size.height + tabBarHeight
                    self.isHeightSet = true
                }
                
            })
        } else {
            NSLog("Can't determine direction as velocity is 0")
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - constants.prodImgLoadThresold){
            if (self.loadingProducts) {
                
                switch feedFilter! {
                case FeedFilter.FeedType.USER_LIKED:
                    ApiControlller.apiController.getUserLikedFeeds(self.userInfo!.id, offSet: self.pageOffSet)
                case FeedFilter.FeedType.USER_POSTED:
                    ApiControlller.apiController.getUserPostedFeeds(self.userInfo!.id, offSet: self.pageOffSet)
                default: break
                }
                
                self.loadingProducts = false
            }
        }
        
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, 350)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = BabyboxUtils.babyBoxUtils.getProductItemCellSize(self.view.bounds.width)
    }
    
    func setFeedtype(feedType: FeedFilter.FeedType) {
        self.feedFilter = feedType
    }
    
    @IBAction func onLikeBtnClick(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview! as! FeedProductCollectionViewCell
        
        let indexPath = self.uiCollectionView.indexPathForCell(cell)
        
        //TODO - logic here require if user has already liked the product...
        var products = self.getTypeProductInstance()
        if (products[(indexPath?.row)!].isLiked) {
            products[(indexPath?.row)!].numLikes--
            cell.likeCount.text = String(products[(indexPath?.row)!].numLikes)
            products[(indexPath?.row)!].isLiked = false
            ApiControlller.apiController.unlikePost(String(products[(indexPath?.row)!].id))
            button.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            
        } else {
            products[(indexPath?.row)!].isLiked = true
            products[(indexPath?.row)!].numLikes++
            cell.likeCount.text = String(products[(indexPath?.row)!].numLikes)
            ApiControlller.apiController.likePost(String(products[(indexPath?.row)!].id))
            button.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            
        }
    }
    
    @IBAction func onClickCloseTip(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview!.superview as! UserFeedHeaderViewCell
        cell.tipsView.hidden = true
        cell.tipsConstraint.constant = 6
        redrawSegControlBorder(cell.segmentControl)
    }

    @IBAction func onClickBrowse(sender: AnyObject) {
    }
    
    @IBAction func segAction(sender: AnyObject) {
        let segControl = sender as? UISegmentedControl
        if(segControl!.selectedSegmentIndex == 0){
            self.feedFilter = FeedFilter.FeedType.USER_POSTED
            self.userPostedProducts = []
            ApiControlller.apiController.getUserPostedFeeds(self.userId, offSet: 0)
        } else if(segControl!.selectedSegmentIndex == 1){
            self.feedFilter = FeedFilter.FeedType.USER_LIKED
            self.userLikedProducts = []
            ApiControlller.apiController.getUserLikedFeeds(self.userId, offSet: 0)
        }
        redrawSegControlBorder(segControl!)
    }
    
    func redrawSegControlBorder(segControl: UISegmentedControl) {
        if(segControl.selectedSegmentIndex == 0){
            let y = CGFloat(segControl.frame.size.height)
            let start: CGPoint = CGPoint(x: 0, y: (segControl.frame.origin.y) + y)
            let end: CGPoint = CGPoint(x: self.view.frame.size.width / 2, y: (segControl.frame.origin.y) + y)
            
            let color: UIColor = UIColor(red: 255/255, green: 118/255, blue: 164/255, alpha: 1.0)
            self.drawLineFromPoint(start, toPoint: end, ofColor: color, inView: segControl)
            
        } else if(segControl.selectedSegmentIndex == 1){
            
            let y = CGFloat(segControl.frame.size.height)
            let start: CGPoint = CGPoint(x: segControl.frame.size.width / 2 , y: (segControl.frame.origin.y) + y)
            let end: CGPoint = CGPoint(x: segControl.frame.size.width, y: (segControl.frame.origin.y) + y)
            
            let color: UIColor = UIColor(red: 255/255, green: 118/255, blue: 164/255, alpha: 1.0)
            self.drawLineFromPoint(start, toPoint: end, ofColor: color, inView: segControl)
        }
    }
    
    func setSizesForFilterButtons(cell: UserFeedHeaderViewCell) {
        isWidthSet = true
        let availableWidthForButtons:CGFloat = self.view.bounds.width
        let buttonWidth :CGFloat = availableWidthForButtons / 3
        
        cell.segmentControl.backgroundColor = UIColor.whiteColor()
        
        redrawSegControlBorder(cell.segmentControl)
        
        cell.btnWidthConsttraint.constant = buttonWidth
        cell.followersBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.followersBtn.layer.borderWidth = 1.0
        
        cell.followingBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.followingBtn.layer.borderWidth = 1.0
        
        cell.editProfile.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.editProfile.layer.borderWidth = 1.0
        
    }
    
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view: UIView) {
        //design the path
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addLineToPoint(end)
        path.lineJoinStyle = CGLineJoin.Round
        path.lineCapStyle = CGLineCap.Square
        path.miterLimit = CGFloat(0.0)
        //design path in layer
        
        shapeLayer.fillColor = UIColor.whiteColor().CGColor
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = lineColor.CGColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.allowsEdgeAntialiasing = false
        shapeLayer.allowsGroupOpacity = false
        shapeLayer.autoreverses = false
        self.uiCollectionView.layer.addSublayer(shapeLayer)
    }
    
    func getTypeProductInstance() -> [PostModel] {
        if (feedFilter == FeedFilter.FeedType.USER_POSTED) {
            return self.userPostedProducts
        } else {
            return self.userLikedProducts
        }
        
    }
}
