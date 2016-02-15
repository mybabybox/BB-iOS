//
//  UserProfileFeedViewController.swift
//  babybox
//
//  Created by Mac on 30/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class UserProfileFeedViewController: BaseProfileFeedViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    
    var collectionViewCellSize : CGSize?
    var collectionViewTopCellSize : CGSize?
    var reuseIdentifier = "CellType"

    var isWidthSet = false
    var isHeightSet: Bool = false
    var isHtCalculated = false
    
    var activeHeaderViewCell: UserFeedHeaderViewCell? = nil
    let shapeLayer = CAShapeLayer()
    
    override func reloadDataToView() {
        self.uiCollectionView.reloadData()
    }
    
    override func registerMoreEvents() {
        SwiftEventBus.onMainThread(self, name: "userByIdSuccess") { result in
            self.setUserInfo(result.object as? UserInfoVM)
            //let userImg = self.navigationItem.leftBarButtonItems![0] as UIBarButtonItem
            //(userImg.customView as? UIButton)?.setTitle(self.userInfo?.displayName, forState: UIControlState.Normal)
            self.navigationItem.title = self.userInfo?.displayName
            
            if (self.activeHeaderViewCell != nil) {
                self.activeHeaderViewCell?.segmentControl.setTitle("Products " + String(self.userInfo!.numProducts), forSegmentAtIndex: 0)
                self.activeHeaderViewCell?.segmentControl.setTitle("Likes " + String(self.userInfo!.numLikes), forSegmentAtIndex: 1)
            }
            
            ApiControlller.apiController.getUserPostedFeeds(self.userInfo!.id, offSet: 0)
            ApiControlller.apiController.getUserLikedFeeds(self.userInfo!.id, offSet: 0)
        }
        
        SwiftEventBus.onMainThread(self, name: "userByIdFailed") { result in
            self.view.makeToast(message: "Error getting User Profile Information!")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = true
        self.navigationItem.setHidesBackButton(false, animated: true)
        
        registerEvents()
        
        ApiControlller.apiController.getUser(self.userId)
    }
    
    override func viewDidDisappear(animated: Bool) {
        unregisterEvents()
        resetData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionViewSizesInsets()
        setCollectionViewSizesInsetsForTopView()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 5
        uiCollectionView.collectionViewLayout = flowLayout
        
        /*let userNameImg: UIButton = UIButton()
        userNameImg.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        userNameImg.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        userNameImg.frame = CGRectMake(0, 0, 150, 35)
        
        let userNameBarBtn = UIBarButtonItem(customView: userNameImg)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItems = [userNameBarBtn]
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.backBarButtonItem?.title = ""*/
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if (collectionView.tag == 2) {
            count = 1
        } else {
            count = self.getTypeProductInstance().count
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (collectionView.tag == 2) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("headerCell", forIndexPath: indexPath) as! UserFeedHeaderViewCell
            self.activeHeaderViewCell = cell
            
            //Divide the width equally among buttons..
            if (!isWidthSet) {
                setSizesForFilterButtons(cell)
            }
            
            if (self.userInfo != nil) {
                cell.displayName.text = self.userInfo?.displayName
                
                ImageUtil.displayThumbnailProfileImage(self.userInfo!.id, imageView: cell.userImg)
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
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedProductCollectionViewCell
            
            cell.likeImageIns.tag = indexPath.item
            
            let post = self.getTypeProductInstance()[indexPath.row]
            if (post.hasImage) {
                ImageUtil.displayPostImage(post.images[0], imageView: cell.prodImageView)
            }
            
            cell.soldImage.hidden = !post.sold
            cell.likeCountIns.setTitle(String(post.numLikes), forState: UIControlState.Normal)
            
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
        if (collectionView.tag == 2){
            
        } else {
            
            let vController =  self.storyboard!.instantiateViewControllerWithIdentifier("FeedProductViewController") as! FeedProductViewController
            
            vController.productModel = self.getTypeProductInstance()[indexPath.row]
            ApiControlller.apiController.getProductDetails(String(Int(self.getTypeProductInstance()[indexPath.row].id)))
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
            if (self.isTipVisible()) {
                return CGSizeMake(self.view.frame.width, 295)
            } else {
                return CGSizeMake(self.view.frame.width, 190)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    //MARK Segue handling methods.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.tabBarController!.tabBar.hidden = true
        if (segue.identifier == "followingCalls") {
            let vController = segue.destinationViewController as! FollowingViewController
            vController.userId = self.userInfo!.id
        } else if (segue.identifier == "followersCall") {
            let vController = segue.destinationViewController as! FollowersViewController
            vController.userId = self.userInfo!.id
        } else if (segue.identifier == "editProfile"){
            let vController = segue.destinationViewController as! EditProfileViewController
            vController.userId = self.userInfo!.id
        } else if (segue.identifier == "settings") {
            // let vController = segue.destinationViewController as! SettingsViewController
        }
    }
    
    // MARK: UIScrollview Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let velocity: CGFloat = scrollView.panGestureRecognizer.velocityInView(scrollView).y
        
        if (velocity > 0) {
            NSLog("Up")
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
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - constants.prodImgLoadThresold {
            loadMoreFeedItems()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    }
    
    func setCollectionViewSizesInsetsForTopView() {
        collectionViewTopCellSize = CGSizeMake(self.view.bounds.width, 350)
    }
    
    func setCollectionViewSizesInsets() {
        collectionViewCellSize = ImageUtil.imageUtil.getProductItemCellSize(self.view.bounds.width)
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
            cell.likeCountIns.setTitle(String(products[(indexPath?.row)!].numLikes), forState: UIControlState.Normal)
            products[(indexPath?.row)!].isLiked = false
            ApiControlller.apiController.unlikePost(String(products[(indexPath?.row)!].id))
            cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            
        } else {
            products[(indexPath?.row)!].isLiked = true
            products[(indexPath?.row)!].numLikes++
            cell.likeCountIns.setTitle(String(products[(indexPath?.row)!].numLikes), forState: UIControlState.Normal)
            ApiControlller.apiController.likePost(String(products[(indexPath?.row)!].id))
            cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func segAction(sender: AnyObject) {
        let segControl = sender as? UISegmentedControl
        if (segControl!.selectedSegmentIndex == 0) {
            self.feedFilter = FeedFilter.FeedType.USER_POSTED
        } else if (segControl!.selectedSegmentIndex == 1) {
            self.feedFilter = FeedFilter.FeedType.USER_LIKED
        }
        
        reloadFeedItems()
        
        redrawSegControlBorder(segControl!)
    }
    
    func redrawSegControlBorder(segControl: UISegmentedControl) {
        
        var extraHt = CGFloat(0.0)
        if (!isTipVisible() && !isHtCalculated) {
            extraHt = CGFloat(114.0)
            self.isHtCalculated = true
        } else {
            
        }
        
        if(segControl.selectedSegmentIndex == 0){
            let y = CGFloat(segControl.frame.size.height)
            let start: CGPoint = CGPoint(x: 0, y: (segControl.frame.origin.y) + y - extraHt)
            let end: CGPoint = CGPoint(x: self.view.frame.size.width / 2, y: (segControl.frame.origin.y) + y - extraHt)
            
            let color: UIColor = UIColor(red: 255/255, green: 118/255, blue: 164/255, alpha: 1.0)
            self.drawLineFromPoint(start, toPoint: end, ofColor: color, inView: segControl)
            
        } else if(segControl.selectedSegmentIndex == 1){
            
            let y = CGFloat(segControl.frame.size.height)
            let start: CGPoint = CGPoint(x: segControl.frame.size.width / 2 , y: (segControl.frame.origin.y) + y - extraHt)
            let end: CGPoint = CGPoint(x: segControl.frame.size.width, y: (segControl.frame.origin.y) + y - extraHt)
            
            let color: UIColor = UIColor(red: 255/255, green: 118/255, blue: 164/255, alpha: 1.0)
            self.drawLineFromPoint(start, toPoint: end, ofColor: color, inView: segControl)
        }
        
        segControl.setTitleTextAttributes(
            [NSForegroundColorAttributeName: ImageUtil.imageUtil.UIColorFromRGB(0xFF76A4)],
            forState: UIControlState.Selected)
    }
    
    func setSizesForFilterButtons(cell: UserFeedHeaderViewCell) {
        isWidthSet = true
        let availableWidthForButtons:CGFloat = self.view.bounds.width
        let buttonWidth :CGFloat = availableWidthForButtons / 3
        
        cell.segmentControl.backgroundColor = UIColor.whiteColor()
        
        redrawSegControlBorder(cell.segmentControl)
        
        cell.btnWidthConsttraint.constant = buttonWidth
        /*cell.followersBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.followersBtn.layer.borderWidth = 1.0
        
        cell.followingBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.followingBtn.layer.borderWidth = 1.0        */
        
        cell.editProfile.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.editProfile.layer.borderWidth = 1.0
        
        if (!SharedPreferencesUtil.getInstance().isScreenViewed(SharedPreferencesUtil.Screen.MY_PROFILE_TIPS)) {
            cell.tipsView.hidden = false
        } else {
            cell.tipsView.hidden = true
            cell.tipsConstraint.constant = 6
        }
        ImageUtil.displayButtonRoundBorder(cell.editProfile)
        
        if (constants.userInfo.id != self.userId) {
            cell.editProfile.hidden = false
            ImageUtil.displayButtonRoundBorder(cell.editProfile)
        } else {
            cell.editProfile.hidden = true
        }
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
}
