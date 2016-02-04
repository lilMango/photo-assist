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
        
        
        let overlayKpImage:UIImage = CVWrapper.getOverlayProcessedUIImage()
        let camKpImage:UIImage = CVWrapper.trackObjInSceneFrame()
        
        overlayWholeImgView!.image = OverlayData.overlayImage
        overlayImgView!.image = overlayKpImage
        cameraImgView!.image = camKpImage
    }
    
    
}