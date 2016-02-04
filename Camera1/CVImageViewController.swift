//
//  CVImageViewController.swift
//  Camera1
//
//  Created by Miguel Paysan on 1/28/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AVFoundation

class CVImageViewController:UIViewController {
    

    //shows bounding box
    @IBOutlet weak var overlayImgView: UIImageView!
    @IBOutlet weak var cameraImgView: UIImageView!
    
    @IBOutlet weak var overlayWholeImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let picWidth=UIScreen.mainScreen().bounds.width
        print("screenWidth:",picWidth)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //Region of Interest rectangle, smoothest to use ROI that's a quarter tile of the whole square image
        //TODO understand difference b/w Storyboard coordinates and image coordinates, image size vs frame size?

        let overlayImgWidth = OverlayData.overlayImage.size.width
        let overlayImgHeight = OverlayData.overlayImage.size.height
        print("width: ", overlayImgWidth, "\theight: ", overlayImgHeight)
        
        let roi_w = Int32( OverlayData.roiBox.size.width)
        let roi_x = Int32( OverlayData.roiBox.minX)
        let roi_y = Int32( OverlayData.roiBox.minY)
        
        let overlayKpImage:UIImage =
        CVWrapper.getOverlayProcessedUIImage()
        //CVWrapper.toKeypointsImage(OverlayData.overlayImage, x:roi_x, y:roi_y, w:roi_w, h:roi_w) as UIImage
        //let camKpImage:UIImage = CVWrapper.getMatchedImage(OverlayData.overlayImage, x:roi_x, y:roi_y, w:roi_w, h:roi_w, sceneImage:OverlayData.cameraImage) as UIImage
        let camKpImage:UIImage = CVWrapper.trackObjInScene()
        
        overlayWholeImgView!.image = OverlayData.overlayImage
        overlayImgView!.image = overlayKpImage
        cameraImgView!.image = camKpImage
    }
    
    
}