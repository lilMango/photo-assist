//
//  ConstantsConfig.swift
//  Camera1
//
//  Created by Miguel Paysan on 1/13/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

import Foundation

class ConstantsConfig {

    static var kDeltaOrientationThreshold:Double = 0.05
}

enum DrawBitmasks: Int32 {
    case KEYPOINTS=0x01
    case ROIBOX=0x02
    case TRACKED=0x04
};