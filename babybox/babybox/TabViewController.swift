//
//  TabViewController.swift
//  Baby Box
//
//  Created by Mac on 04/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import UIKit


class TabViewController: UITabBarController  {
    
    //MARK: Properties
    
    //@IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var num: Int = 1
    let identifier = "CellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        
        
    }
}

// MARK:- UICollectionViewDataSource Delegate
extension TabViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) 
    //cell.backgroundColor = UIColor.redColor()
    
    return cell 
    }
}
