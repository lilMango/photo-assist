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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let picWidth=UIScreen.mainScreen().bounds.width
        print("screenWidth:",picWidth)
        print("imageView.bounds:",selectedOverlayImgView!.bounds)
        print("imageView.frame:",selectedOverlayImgView!.frame)
//        selectedOverlayImgView!.bounds=CGRect(x:0, y:0,
//            width:picWidth,height:picWidth)
//        selectedOverlayImgView!.frame=CGRect(x:0, y:0,
//            width:picWidth,height:picWidth)

        collectionView.delegate=self
        collectionView.dataSource = self
        fetchPhotoAtIndexFromEnd(0)

    }
    
    override func viewWillAppear(animated: Bool) {
        
        fetchPhotoAtIndexFromEnd(0)
        
        
        
        
    }
    
    
    /*****************************
     * UI elements
     ******************************/
    @IBOutlet weak var selectedOverlayImgView: UIImageView!

    @IBOutlet weak var collectionView: UICollectionView!
    
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
        
        cell.imageView=imgView
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