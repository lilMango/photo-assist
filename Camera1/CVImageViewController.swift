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
    

    @IBOutlet weak var overlayImgView: UIImageView!
    @IBOutlet weak var cameraImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let picWidth=UIScreen.mainScreen().bounds.width
        print("screenWidth:",picWidth)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        print("view appear2")
        
        //Region of Interest rectangle, smoothest to use ROI that's a quarter tile of the whole square image
        var roi_w = Int32(OverlayData.overlayImage.size.width/((CGFloat(2.0))) )
        var roi_h = Int32(OverlayData.overlayImage.size.width/((CGFloat(2.0))) )
        
        print("ROI w:",roi_w," h:", roi_h)
        
//        let overlayKpImage:UIImage = CVWrapper.toKeypointsImage(
//            OverlayData.overlayImage,
//            x: 0,y: 100,w:roi_w ,h: roi_h) as UIImage
        let overlayKpImage:UIImage = CVWrapper.toKeypointsImage(OverlayData.overlayImage) as UIImage
        
        let camKpImage:UIImage = CVWrapper.toKeypointsImage(OverlayData.cameraImage) as UIImage
        
        CVWrapper.getDiff(OverlayData.overlayImage, img2: OverlayData.cameraImage)
        
        
        overlayImgView!.image = overlayKpImage
        cameraImgView!.image = camKpImage
    }
    
    
}