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
        overlayImgView!.image=OverlayData.overlayImage
        cameraImgView!.image=OverlayData.cameraImage
    }
    
    
}