


import UIKit
class FlickrPhotosViewController: UICollectionViewController {

    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var details = ["http://logok.org/wp-content/uploads/2014/04/Apple-Logo-rainbow.png", "http://coreldrawtips.com/images/applebig.jpg"]
    
    
   
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.blackColor()
        // Configure the cell
        return cell
    }
}
