//
//  ProductChatViewController.swift
//  BabyBox
//
//  Created by admin on 18/03/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class ProductChatViewController: UIViewController {
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var soldText: UILabel!
    @IBOutlet weak var sellText: UILabel!
    @IBOutlet weak var buyText: UILabel!
    @IBOutlet weak var productImg: UIImageView!
    var userConversations: [ConversationVM] = []
    var collectionViewCellSize : CGSize?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return userConversations.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("productChatViewCell", forIndexPath: indexPath) as! ProductChatViewCell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return
    }*/
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
}
