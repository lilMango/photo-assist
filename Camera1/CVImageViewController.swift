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
    }
    
    override func viewWillAppear(animated: Bool) {
        //Region of Interest rectangle, smoothest to use ROI that's a quarter tile of the whole square image
        //TODO understand difference b/w Storyboard coordinates and image coordinates, image size vs frame size?

        let overlayImgWidth = OverlayData.overlayImage.size.width
        let overlayImgHeight = OverlayData.overlayImage.size.height
        print("width: ", overlayImgWidth, "\theight: ", overlayImgHeight)
        
        
        let overlayKpImage:UIImage = CVWrapper.getOverlayProcessedUIImage()
        let camKpImage:UIImage = CVWrapper.trackObjInSceneFrame(DrawBitmasks.KEYPOINTS.rawValue | DrawBitmasks.ROIBOX.rawValue | DrawBitmasks.TRACKED.rawValue)
        
        overlayWholeImgView!.image = UIImage(CGImage: OverlayData.overlayImage.CGImage!, scale: 1.0, orientation: UIImageOrientation.Up)
        overlayImgView!.image = overlayKpImage
        cameraImgView!.image = camKpImage
    }
    
    
}