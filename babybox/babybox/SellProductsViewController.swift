//
//  SellProductsViewController.swift
//  babybox
//
//  Created by Mac on 09/12/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit
import SwiftEventBus

class SellProductsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var actionButton: UIButton!
    let dropDown = DropDown()
    @IBOutlet var sellingtext: UITextField!
    @IBOutlet weak var textFieldKeyboardType: UITextField!{
        didSet{
            textFieldKeyboardType.keyboardType = UIKeyboardType.NumberPad
        }
    }
    var keyboardType: UIKeyboardType {
        get{
            return textFieldKeyboardType.keyboardType
        }
        set{
            if newValue != UIKeyboardType.NumberPad{
                self.keyboardType = UIKeyboardType.NumberPad
            }
        } 
    }
    var categories : [CategoryModel] = []
    
    var save:String = "";
    
    @IBOutlet var categotytext: UITextField!
   
    @IBOutlet var setpricetxt: UITextField!
    @IBOutlet var conditiontxt: UITextField!
    @IBOutlet var categorydropdown: UIButton!
    @IBOutlet var selectdropdown: UIButton!
    @IBOutlet var actionButton1: UIButton!
    @IBOutlet var categorytxt: NSLayoutConstraint!
    let xyz = DropDown()
    @IBOutlet var pricetxt: UITextField!
    @IBOutlet var producttxt: UITextField!
    var collectionViewCellSize : CGSize?
    var collectionViewInsets : UIEdgeInsets?
    var reuseIdentifier = "CustomCell"
    var imageCollection = [AnyObject]()
    var selectedIndex :Int?
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.loadDataSource()
        //self.collectionView.reloadData()
        setCollectionViewSizesInsets();
            
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "actionbar_bg_pink"), forBarMetrics: UIBarMetrics.Default)
        ApiControlller.apiController.getAllCategories();
        print(ApiControlller.apiController.getAllCategories())
        
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedSuccess") { result in
            // UI thread
            print("inside categories success................")
            let resultDto: [CategoryModel] = result.object as! [CategoryModel]
            self.handleGetCateogriesSuccess(resultDto)
        }
        
        dropDown.dataSource = [
            "-Select-",
            "New(Sealed/with tags)",
            "New(unsealed/without tags)",
            "Used"
        ]
        
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.actionButton.setTitle(item, forState: .Normal)
            
            //xyz.selectionAction = { [unowned self] (index, item) in
            
            
        }
        
        xyz.selectionAction = { [unowned self] (index, item) in
            self.actionButton1.setTitle(item, forState: .Normal)
        }
        
        dropDown.anchorView = actionButton
        dropDown.bottomOffset = CGPoint(x: 0, y:actionButton.bounds.height)
        dropDown.direction = .Top
        xyz.anchorView=actionButton1
        xyz.bottomOffset = CGPoint(x: 0, y:actionButton.bounds.height)
        xyz.direction = .Top
        
        
        NSNotificationCenter.defaultCenter().addObserverForName("CroppedImage", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            print(notification.object)
            self.imageCollection.removeAtIndex(self.selectedIndex!)
            self.imageCollection.insert(notification.object!, atIndex: self.selectedIndex!)
            self.collectionView.reloadData()
        }

        self.collectionView.reloadData()
        
    }
    
    

        func categorydropdown(sender: UIButton) {
            //ApiControlller.apiController.getAllCategories();
            // self.categorydropdown=categories;
        }
    
    func handleGetCateogriesSuccess(categories: [CategoryModel]) {
        self.categories = categories;
        print("here...............")
        print(categories.count)
        var x : [String] = []
        for var i = 0 ; i < categories.count ; i++
        {
            //x[i] = categories[i].description
            print("<><><><>")
            //print(x[i])
            x.append(categories[i].description)
            print("<><><><>")
        }
        
        xyz.dataSource = x
        dispatch_async(dispatch_get_main_queue(), {
            //self.xyz.reloadAllComponents()
            //self.xyz.reloadAllComponents();
            self.xyz.reloadAllComponents()
            
            
            print(self.xyz)
        })

    }

    @IBAction func ShoworDismiss(sender: AnyObject) {
        
        if dropDown.hidden {
            dropDown.show()
        } else {
            dropDown.hide()
        }

    }

    @IBAction func sssss(sender: AnyObject) {
        
        if xyz.hidden {
            xyz.show()
        } else {
            xyz.hide()
        }
    }
    
    @IBOutlet var sssss: UIButton!
    func loadDataSource(){
        self.imageCollection = ["cat_toys","cat_utils","cat_toys","cat_toys"];
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        
        //self.setpricetxt.text=save;
        //self.sellingtext.text=save;
        //self.pricetxt.text=save;
        //self.producttxt.text=save;
        //self.conditiontxt.text=save;
        print(setpricetxt.text);
        print(sellingtext.text);
        print(producttxt.text);
       // print(conditiontxt.text);
        //print(pricetxt.text);
        print(categorydropdown.titleLabel);
        print(selectdropdown.titleLabel);
        
        ApiControlller.apiController.savesell(producttxt.text!,sellingtext: sellingtext.text!, ActionButton1: (categorydropdown.titleLabel?.text!)!,ActionButton: (selectdropdown.titleLabel?.text!)!,setpricetxt: setpricetxt.text!);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
        
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageCollection.count
        
      
    }
  
    
   
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CustomCollectionViewCell
        if(self.imageCollection[indexPath.row].isKindOfClass(UIImage)){
            let image = self.imageCollection[indexPath.row] as! UIImage
            cell.imageHolder.setBackgroundImage(image, forState: UIControlState.Normal)
       }else{
            let image = UIImage(named:"cat_toys")
            cell.imageHolder.setBackgroundImage(image, forState: UIControlState.Normal)
            
        }
        
        cell.imageHolder.tag = indexPath.row
        cell.imageHolder.addTarget(self, action:"choosePhotoOption:" , forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    //MARK: Button Action
    func choosePhotoOption(selectedButton: UIButton){
        self.selectedIndex = selectedButton.tag
        
        let optionMenu = UIAlertController(title: nil, message: "Take Photo:", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .Camera
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let photoGalleryAction = UIAlertAction(title: "Photo Album", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoGalleryAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    @IBAction func btnImageUpload(sender: AnyObject) {
        
        let mutableImageCollection = NSMutableArray(array: self.imageCollection)
        mutableImageCollection.removeObject("")
        self.imageCollection.removeAll(keepCapacity: true)
        self.imageCollection = mutableImageCollection as [AnyObject]
        
        SRWebClient.POST("Your Url to upload image")
            .data(self.imageCollection, fieldName: "Your Key to link Image", data: nil)
            .send({(response:AnyObject!, status:Int) -> Void in
                print(response)
                },failure:{(error:NSError!) -> Void in
                    print(error)
            })
    }
    
    func setCollectionViewSizesInsets() {
        let availableWidthForCells:CGFloat = self.view.bounds.width - 15
        let cellWidth :CGFloat = availableWidthForCells / 4
        let cellHeight = cellWidth * 4/3
        collectionViewCellSize = CGSizeMake(cellWidth, 750)
        print(availableWidthForCells);
    }
        
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
             let controller = ImageCropViewController.init(image: pickedImage)
            self.navigationController?.pushViewController(controller, animated: true)

            self.imageCollection.removeAtIndex(selectedIndex!)
            self.imageCollection.insert(pickedImage, atIndex: selectedIndex!)
        }
        self.collectionView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func handleCroppedImage(notification: NSNotification){
        self.imageCollection.removeAtIndex(selectedIndex!)
        self.imageCollection.insert(notification.object!, atIndex: selectedIndex!)
        self.collectionView.reloadData()
        
    }

}
