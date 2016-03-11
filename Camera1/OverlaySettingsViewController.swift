//
//  OverlaySettingsViewController.swift
//  Camera1
//
//  Created by Miguel Paysan on 1/24/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AVFoundation

class OverlaySettingsViewController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate
{


    let PHOTOS_MAX_COUNT:Int = 5 //max number photos to use in scroll view
    
    var libraryPhotos:NSMutableArray!=NSMutableArray()
    let identifier = "CellIdentifier"
    let roiWidth:CGFloat = 200
    let picWidth=UIScreen.mainScreen().bounds.width

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("screenWidth:",picWidth)
        print("imageView.bounds:",selectedOverlayImgView!.bounds)
        print("imageView.frame:",selectedOverlayImgView!.frame)

        collectionView.delegate=self
        collectionView.dataSource = self
        fetchPhotoAtIndexFromEnd(0)

        let roiBtn = UIButton(frame: CGRectMake(0,75,picWidth/2,picWidth/2)) //y:50 is the margin from header
        roiBtn.contentMode = .ScaleToFill
        roiBtn.userInteractionEnabled = true
        roiBtn.backgroundColor = UIColor.clearColor()

        roiBtn.layer.borderWidth = 1
        roiBtn.layer.borderColor = UIColor.yellowColor().CGColor
        roiBtn.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handlePan:"))
        
        self.view.addSubview(roiBtn)
        
        CVWrapper.setOverlayAsObjectImage(OverlayData.overlayImage, x: 0, y: 0, w: 50, h: 50)
    }
    
    override func viewWillAppear(animated: Bool) {
        libraryPhotos!.removeAllObjects()
        fetchPhotoAtIndexFromEnd(0)
        self.view.sendSubviewToBack(selectedOverlayImgView)
        collectionView!.reloadData()
        
    }
    
    
    
    /*****************************
     * UI elements
     ******************************/
    @IBOutlet weak var selectedOverlayImgView: UIImageView!

    @IBOutlet weak var collectionView: UICollectionView!
    
    //for dragging the roi box, also does translation from Storyboard Points to Pixels. TODO make that a util func
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            
            //box stays within bounds of IOS points system
            var dX:CGFloat = translation.x
            var dY:CGFloat = translation.y
            
            let leftVX = view.frame.minX //left
            let rightVX = view.frame.maxX //right
            let topVX = view.frame.minY //top
            let bottomVX = view.frame.maxY //bottom
            
            let topMargin:CGFloat = 50

            if ((rightVX + dX > UIScreen.mainScreen().bounds.maxX)
                || (leftVX + dX < 0 )) {
                dX = 0
            }
            
            if ((topVX + dY < selectedOverlayImgView.frame.minY)
                || (bottomVX + dY > selectedOverlayImgView.frame.maxY)) {
                dY = 0
            }
            
            view.center = CGPoint (x:view.center.x + dX,
                y:view.center.y + dY)


            //localized storyboard point coordinates (top left @0,0) w.r.t the camera view (i.e. iphone storyboard global points -> localized story points of cameraview)
            let roiPointBox = CGRect(x:view.frame.minX, y:view.frame.minY-topMargin, width:50, height:50)
            
            //storyboard points -> percentage of original image (i.e. unit system * 100, so we're passing ints b/c cv::Rect stores int)
            OverlayData.roiBox = CGRect(x:roiPointBox.minX/picWidth * 100 , y:roiPointBox.minY/picWidth * 100, width:50, height:50)
            
            CVWrapper.setOverlayAsObjectImage(OverlayData.overlayImage, x: Int32(OverlayData.roiBox.minX), y: Int32(OverlayData.roiBox.minY), w: 50, h: 50)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }

    // UICollectionViewDataSource delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return libraryPhotos.count
    }
    
    //UICollectionViewDataSource delegate
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! OverlayCell
        
        cell.backgroundColor=UIColor.redColor()
        
        let imgView = UIImageView.init(frame: CGRectMake(0,0,100, 100))
        imgView.image=libraryPhotos[indexPath.row] as? UIImage
        
        cell.addSubview(imgView)

        return cell
    }
    
    
    //UICollectionView delegate on click of cell and selecting photo from library
    func collectionView( collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            print("selected:",indexPath.row)
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! OverlayCell
            
            let temp=libraryPhotos[indexPath.row] as? UIImage
            
            selectedOverlayImgView.image = temp
            
            //TODO: Perhaps set this once and other overlay data
            // when user saves overlay?
            OverlayData.image = selectedOverlayImgView.image
    
            //TODO: Remove for DEBUGGing tab for OpenCV visual comparisons
            OverlayData.overlayImage=selectedOverlayImgView.image
            
            CVWrapper.setOverlayAsObjectImage(OverlayData.overlayImage, x: Int32(OverlayData.roiBox.minX), y: Int32(OverlayData.roiBox.minY), w: 50, h: 50)
            
    }
    
    
    /*****************************
    * Fetch latest photos from camera roll TODO:refactor to utility
    ******************************/
     // Repeatedly call the following method while incrementing
     // the index until all the photos are fetched
    func fetchPhotoAtIndexFromEnd(index:Int) {

        let imgManager = PHImageManager.defaultManager()
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        // Sort the images by creation date
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
            
            // If the fetch result isn't empty,
            // proceed with the image request
            if fetchResult.count > 0 {
                // Perform the image request
                imgManager.requestImageForAsset(fetchResult.objectAtIndex(fetchResult.count - 1 - index) as! PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
                    
                    // Add the returned image to your array
                    self.libraryPhotos.addObject(image!)
                    
                    // If you haven't already reached the first
                    // index of the fetch result and if you haven't
                    // already stored all of the images you need,
                    // perform the fetch request again with an
                    // incremented index
                    if index + 1 < fetchResult.count && self.libraryPhotos.count < self.PHOTOS_MAX_COUNT {
                        self.fetchPhotoAtIndexFromEnd(index + 1)
                    } else {
                        // Else you have completed creating your array
                        print("Completed array: ",self.libraryPhotos.count," photos")
                    }
                })
            }
        }
    }
    
    
    
}