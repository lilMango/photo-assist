//
//  OverlayData.swift
//  Camera1
//
//  Created by Miguel Paysan on 1/25/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

import Foundation
import UIKit

/********************************
 * The Overlay Data class stores the information needed to replicate the photo
    ie. overlay image, box of interest bounds and location,
 ********************************
 *
 *
 * TODO deprecate because we're using the singleton class of ImageMatch.cpp
 *
 */

class OverlayData {
    static var image:UIImage! = UIImage(named:"halfdome.jpg")
    
    //region of interest (ROI). 
    // (x,y) values is in unit terms of image ie. x:0,y:0.50, means it's at 50% down of the original image
    // width and height will represent the dimensions of the box via unit terms of original image
    static var roiBox:CGRect = CGRect(x: 0.0,y: 0.50,width: 0.50,height: 0.50)

    static var overlayImage:UIImage! = UIImage(named:"halfdome.jpg")
    static var cameraImage:UIImage! = UIImage(named:"halfdome.jpg")
}