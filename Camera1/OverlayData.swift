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
 *
 *
 */

class OverlayData {
    static var image:UIImage! = UIImage(named:"halfdome.jpg")
    
    //var interestBox // region of interest (ROI)
    
    //TODO remove
    static var overlayImage:UIImage! = UIImage(named:"halfdome.jpg")
    static var cameraImage:UIImage! = UIImage(named:"halfdome.jpg")
}