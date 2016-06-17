//
//  NZCollectionViewController.swift
//  NZImageShow
//
//  Created by NeoZ on 14/6/16.
//  Copyright © 2016年 NeoZ. All rights reserved.
//

import UIKit
import Kingfisher

//private let column : CGFloat = 3.0

private let reuseIdentifier = "ImageCell"

class NZCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, FullScreenViewDelegate{

    let fullScreenView = FullScreenView()
    /*
    var imageArrayThumb : [String] = {
        var array = [String]()
        for i in 1...13 {
            let urlstring = "http://192.168.28.188:999/testimages/thumb_\(i).jpg"
            array.append(urlstring)
        }
        return array
    }()
    
    var imageArrayLarge : [String] = {
        var array = [String]()
        for i in 1...13 {
            let urlstring = "http://192.168.28.188:999/testimages/source_\(i).jpg"
            array.append(urlstring)
        }
        return array
    }()
    */
    var thumbArrayImages : [UIImage] = {
        var array = [UIImage]()
        let defaultImage = UIImage(named: "imagePlaceHolder")
        for i in 0...sourceImagesArray.count {
            array.append(defaultImage!)
        }
        return array
    }()
    
    var column : CGFloat = 3.0
    var topEdge = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.automaticallyAdjustsScrollViewInsets = true
        
        fullScreenView.mydelegate = self
        view.addSubview(fullScreenView)
        setupScrollViewsWithComplitionHandler()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupScrollViewsWithComplitionHandler(){
        fullScreenView.setupArrayViews(sourceImagesArray) { (isComplited) in
            //print("isComplited:\(isComplited)")
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        let imageString = thumbImagesArray[indexPath.row]
        
        if let imageView = cell.viewWithTag(111) as? UIImageView{
            imageView.kf_setImageWithURL(NSURL(string: imageString)!, placeholderImage: UIImage(named: "imagePlaceHolder"), optionsInfo: nil, progressBlock: {(receivedSize, totalSize) in
                //print("loading...")
                
                }, completionHandler: {(image, error, cacheType, imageURL) in
                    //print("completionHandler...")
                    self.thumbArrayImages.removeAtIndex(indexPath.row)
                    self.thumbArrayImages.insert(image!, atIndex: indexPath.row)
                    cell.tag = indexPath.row
                    
                })
        }else{
            print("no imageview")
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if let cell = collectionView.cellForItemAtIndexPath(indexPath) where cell.tag != 999 {
            let attributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
            let convertedRect = collectionView.convertRect((attributes?.frame)!, toView: collectionView.superview)
            //print("convertedRect:\(convertedRect)")
            fullScreenView.updatedThumbArrayImages = thumbArrayImages
            fullScreenView.showSelectedView(indexPath.row, rectPassed : convertedRect)
            self.navigationController?.navigationBar.hidden = true
            
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.size.width - 5 - 5 * column) / column
        let cellHeight = cellWidth
        return CGSizeMake(cellWidth, cellHeight)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.collectionView!.frame = UIScreen.mainScreen().bounds

        self.view!.frame = UIScreen.mainScreen().bounds
        fullScreenView.frame = view.bounds
        
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
        self.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let newInsets = UIEdgeInsetsMake(topEdge, 0, 0, 0)
        collectionView?.contentInset = newInsets

    }
 
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        switch toInterfaceOrientation {
        case .Portrait:
            column = 3.0
            topEdge = (navigationController?.navigationBar.frame.height)! + 33.0
        case .LandscapeLeft, .LandscapeRight:
            column = 4.0
            topEdge = (navigationController?.navigationBar.frame.height)! + 0.0
        default:
            break
        }
    }
    
    func callbackWithRect(imageView : UIImageView, indexPage : Int){
        
        self.navigationController?.navigationBar.hidden = false
        
        let newInsets = UIEdgeInsetsMake(topEdge, 0, 0, 0)
        collectionView?.contentInset = newInsets
        
        let passedRect = imageView.frame
        let viewFrame = view.frame
        let convertedRecg = CGRectMake((viewFrame.size.width - passedRect.size.width)/2, (viewFrame.size.height - passedRect.size.height)/2, passedRect.size.width, passedRect.size.height)
        

        let indexPath = NSIndexPath(forRow: indexPage, inSection: 0)
        let attributes = collectionView!.layoutAttributesForItemAtIndexPath(indexPath)
        let convertedRect = collectionView!.convertRect((attributes?.frame)!, toView: collectionView!.superview)
        
        let trickyImageview = UIImageView(frame: convertedRecg)
        trickyImageview.image = imageView.image
        view.addSubview(trickyImageview)
        
        UIView.animateWithDuration(0.5, animations: {
            trickyImageview.frame = convertedRect
            }, completion: { (true) in
                trickyImageview.removeFromSuperview()
        })
    }
}
