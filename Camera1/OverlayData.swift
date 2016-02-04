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
    
    //region of interest (ROI), each value is interpreted as a pixel representation of the container width. TODO should we use percentage?
    static var roiBox:CGRect = CGRect(x: 0,y: 50,width: 200,height: 200)

    static var overlayImage:UIImage! = UIImage(named:"halfdome.jpg")
    static var cameraImage:UIImage! = UIImage(named:"halfdome.jpg")
}