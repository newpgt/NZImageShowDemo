//
//  FullScreenView.swift
//  NZImageShow
//
//  Created by NeoZ on 16/6/16.
//  Copyright © 2016年 NeoZ. All rights reserved.
//


import UIKit

@objc public protocol FullScreenViewDelegate {
    optional func callbackWithRect(imageView : UIImageView, indexPage : Int)
}

class FullScreenView: UIView, UIScrollViewDelegate {
    
    var mydelegate : FullScreenViewDelegate?
    
    private var pageRollingWidth = CGFloat()
    
    private var localImagesUrlArray = [String]()
    
    var updatedThumbArrayImages = [UIImage]()
    
    private var arrayOfImageScrollViews : [ZoomableScrollview] = []
    
    private var pagecontrol : UIPageControl = {
        let page = UIPageControl()
        page.frame = CGRectMake(0, 0, 200, 30)
        page.currentPage = 0
        page.currentPageIndicatorTintColor = UIColor.whiteColor()
        page.pageIndicatorTintColor = UIColor.lightGrayColor()
        
        return page
    }()
    
    private var shareButton : UIButton = {
        let button = UIButton(frame: CGRectMake(20, 20, 60, 40))
        //button.setTitle("Save", forState: .Normal)
        button.setImage(UIImage(named: "ic_share"), forState: .Normal)
        //button.addTarget(self, action: #selector(shareImage(_:)), forControlEvents: .TouchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        button.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        
        return button
    }()
    
    private var currentDisplyedPage : Int {
        get{
            return pagecontrol.currentPage
        }set{
            pagecontrol.currentPage = newValue
            
            if arrayOfImageScrollViews.count > 0 {
                let scrollviewSelected = arrayOfImageScrollViews[newValue]
                
                scrollviewSelected.imageHolder = updatedThumbArrayImages[newValue]
                scrollviewSelected.imageUrl = localImagesUrlArray[newValue]
                self.outerScrollView.setContentOffset(CGPointMake(pageRollingWidth * CGFloat(newValue), 0), animated: false)
            }
        }
    }
    
    var myImageArray = [String]() {
        didSet{
            pagecontrol.numberOfPages = myImageArray.count
            setupImageScrollView(myImageArray) { (viewsArray) in
                self.arrayOfImageScrollViews = viewsArray
            }
        }
    }
    
    var outerScrollView: UIScrollView = {
        let view = UIScrollView()
        view.pagingEnabled = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.scrollEnabled = true
        view.clipsToBounds = true
        view.bounces = false
        
        return view
    }()

    required override init(frame: CGRect) {
        pageRollingWidth = frame.size.width
        super.init(frame: frame)
        
        self.autoresizesSubviews = true
        self.clipsToBounds = true
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setupArrayViews(imagesArray : [String], complitionHandler:(isComplited:Bool) -> ()) {
        //let window : UIWindow = ((UIApplication.sharedApplication().delegate?.window)!)!
        
        shareButton.addTarget(self, action: #selector(shareImage(_:)), forControlEvents: .TouchUpInside)
        
        outerScrollView.delegate = self
        outerScrollView.frame = self.frame
        self.addSubview(outerScrollView)
        self.addSubview(pagecontrol)
        self.addSubview(shareButton)
        //window.addSubview(self)
        
        self.hidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedScrollView(_:)))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(tappedToZoom(_:)))
        tap2.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap2)
        
        tap.requireGestureRecognizerToFail(tap2)
        
        myImageArray = imagesArray
        
        complitionHandler(isComplited: true)
    }
    
    internal func showSelectedView(indexClicked:Int, rectPassed : CGRect) {
        
        self.hidden = false
        /*
        let window : UIWindow = ((UIApplication.sharedApplication().delegate?.window)!)!
        let vc = window.rootViewController
        vc?.navigationController?.navigationBar.hidden = true
        */
        if arrayOfImageScrollViews.count > 0 {
            let scrollviewSelected = arrayOfImageScrollViews[indexClicked]
            if scrollviewSelected.isImageDownloaded {
                let trickyImageview = UIImageView(frame: rectPassed)
                trickyImageview.image = scrollviewSelected.imageloaded
                self.addSubview(trickyImageview)
                scrollviewSelected.imageView.alpha = 0
                
                UIView.animateWithDuration(0.3, animations: {
                    let size = scrollviewSelected.calculatePictureSize()
                    trickyImageview.frame = CGRectMake((self.bounds.size.width - size.width) / 2, (self.bounds.size.height - size.height) / 2, size.width, size.height)
                    }, completion: { (true) in
                        trickyImageview.removeFromSuperview()
                        scrollviewSelected.imageView.alpha = 1
                })
            }
        }
        
        currentDisplyedPage = indexClicked
    }
    
    func setupImageScrollView(imagesArrayUrl : [String], completion:(viewsArray : [ZoomableScrollview]) -> ()) {
        
        localImagesUrlArray = imagesArrayUrl
        if localImagesUrlArray.count > 0 {
            var localArray = [ZoomableScrollview]()
            var i = 0
            for _ in localImagesUrlArray {
                let scrollviewFrame = CGRectMake(bounds.size.width * CGFloat(i), 0, bounds.size.width, bounds.size.height)
                let imageScrollView = ZoomableScrollview.init(frame: scrollviewFrame)
                imageScrollView.tag = i
                
                localArray.append(imageScrollView)
                outerScrollView.addSubview(imageScrollView)
                i += 1
            }
            completion(viewsArray : localArray)
        }

    }
    
    deinit {
        print("deinit count:\(arrayOfImageScrollViews.count)")
    }
    
    override func layoutSubviews() {
        
        outerScrollView.frame = self.bounds
        outerScrollView.contentSize = CGSizeMake(self.bounds.size.width * CGFloat(myImageArray.count), self.bounds.size.height)
        
        pageRollingWidth = outerScrollView.frame.size.width
        
        pagecontrol.center = CGPointMake(outerScrollView.frame.size.width / 2, outerScrollView.frame.size.height - 10)
        shareButton.frame = CGRectMake(20, 20, 50, 50)
        
        var i = 0
        for view in outerScrollView.subviews {
            if let imgView = view as? UIScrollView {
                imgView.frame = CGRectMake(frame.size.width * CGFloat(i), 0, frame.size.width, frame.size.height)
                i += 1
            }
            
        }
        
        self.outerScrollView.setContentOffset(CGPointMake(pageRollingWidth * CGFloat(currentDisplyedPage), 0), animated: false)
    }
    
    override func drawRect(rect: CGRect) {
        //print("drawRect")
        //self.frame = UIScreen.mainScreen().bounds
    }
    
    func shareImage(sender:UIButton) {
        if arrayOfImageScrollViews.count > 0 {
            let scrollviewSelected = arrayOfImageScrollViews[currentDisplyedPage]
            if scrollviewSelected.isImageDownloaded {
                let image = scrollviewSelected.imageloaded
                let message = String(format: "Share message")
                let urlString = localImagesUrlArray[currentDisplyedPage]
                let webSite = NSURL(string: urlString)
                let shareObj : Array = [message, image!, webSite!]
                
                let acv = UIActivityViewController(activityItems: shareObj as [AnyObject], applicationActivities: nil)
                
                let window : UIWindow = ((UIApplication.sharedApplication().delegate?.window)!)!
                //let vc = UIApplication.sharedApplication().keyWindow?.rootViewController
                let vc = window.rootViewController
                vc!.presentViewController(acv, animated: true, completion: nil)
                vc?.view.superview?.bringSubviewToFront(acv.view)
                if let pop = acv.popoverPresentationController {
                    let v = sender as UIView // sender would be the button view tapped, but could be any view
                    pop.sourceView = v
                    pop.sourceRect = v.bounds
                    
                }
            }
        }
    }
    
    func tappedScrollView(sender: UIGestureRecognizer) {
        
        let currentScrollview = arrayOfImageScrollViews[currentDisplyedPage]

        if let adelegate = mydelegate {
            if let responsedMethod = adelegate.callbackWithRect {
                responsedMethod(currentScrollview.imageView, indexPage: currentDisplyedPage)
            }else{
                print("delegate method NOT implemented yet!")
            }
        }else{
            print("delegate error")
        }
        
        currentScrollview.zoomOut()
        
        self.hidden = true
        /*
        let window : UIWindow = ((UIApplication.sharedApplication().delegate?.window)!)!
        let vc = window.rootViewController
        vc?.navigationController?.navigationBar.hidden = false
*/
    }
    
    func tappedToZoom(sender: UIGestureRecognizer) {
        let currenImageScrollView = arrayOfImageScrollViews[currentDisplyedPage]
        currenImageScrollView.tapZoom()
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        currentDisplyedPage = PageNumberInScrollview(scrollView)
        resetZoomScaleExcept(currentDisplyedPage)
    }
    
    private func PageNumberInScrollview(scrollView: UIScrollView) -> Int {
        let contentOffset = scrollView.contentOffset
        let viewsize = scrollView.bounds.size
        let horizontalPage = max(0.0, contentOffset.x / viewsize.width)
        return Int(horizontalPage)
    }
    
    func resetZoomScaleExcept(currentPage : Int) {
        for view in outerScrollView.subviews {
            if let scrollerview = view as? ZoomableScrollview {
                if scrollerview.tag != currentPage {
                    scrollerview.zoomOut()
                }
            }
        }
    }
}
