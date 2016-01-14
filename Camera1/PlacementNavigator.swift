//
//  PlacementNavigator.swift
//  Camera1
//
//  Created by Miguel Paysan on 1/8/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

import UIKit
import Foundation
import CoreMotion
import CoreLocation

class PlacementNavigator {
    enum Compass {
        case North, South, East, West
    }
    
    enum Direction {
        case Up, Down, Left, Right
    }
    
    enum Rotation {
        case PitchCW, PitchCCW, YawCW, YawCCW, RollCW, RollCCW, Noop
    }

    static var rotationToWordsMap:[Rotation:String]=[
        Rotation.PitchCW: "Tilt Backward",
        Rotation.PitchCCW: "Tilt Forward",
        Rotation.YawCW: "Swing Right side toward you",
        Rotation.YawCCW: "Swing Left side toward you",
        Rotation.RollCW: "turn Clockwise->",
        Rotation.RollCCW: "turn Counter Clockwise",
    ]
    
    // Assumes you get to the path in a straight line and No walking up/down directions
    
    
    /*
    * Input: Starting Orientation, Starting Location
    *        Current Orientation, Current Location
    * Returns:Instruction on how to proceed to next location (direction, tilt, etc)
    */
    static func getNavigationInstruction(dest:Vector3,cur:Vector3) -> String{
        /*priorities of instructions are:
            1)Distance (latitude/longitude) to the picture spot
            2)phone orientation
        */
        getDistanceInstruction()
        
        //if distance reasonable range then call get device orientation
        let rot=getOrientationInstruction(dest,cur:cur)
        if(rotationToWordsMap[rot] != nil){
            return rotationToWordsMap[rot]!
        }else{
            return ""
        }
    }
    
    /*
    * Deals with getting instructions for getting to photo spot using latitude/longitude
        Args: starting location, current location
        Returns: Vector?
    */
    static func getDistanceInstruction() {
        
    }
    
    /*
    * Deals with getting instructions for orienting the phone
        Args: starting orientation, current orientation
        Returns: Rotation enum
    */
    static func getOrientationInstruction(dest:Vector3, cur:Vector3) -> Rotation {

        //Use Right hand rule like in E&M induction.
        //Sweep fingers point to start, curl hand into palm. Stick thumb out, which is your axis to rotate around
        
        //This cross product vector AxB, gives us the direction to get to A from B, and which axis to rotate with
        let prod:Vector3=cur.cross(dest)
        
        //If there's minimal change then Noop. Sensor is sensitive, and may cause noise
        if(prod.magnitude() < ConstantsConfig.kDeltaOrientationThreshold) {
            return Rotation.Noop
        }
        var dict:Dictionary<Vector3.Axis,Rotation>=Dictionary<Vector3.Axis,Rotation>()

        dict[Vector3.Axis.X]=Rotation.PitchCCW
        dict[Vector3.Axis.Y]=Rotation.YawCCW
        dict[Vector3.Axis.Z]=Rotation.RollCCW
        dict[Vector3.Axis.nX]=Rotation.PitchCW
        dict[Vector3.Axis.nY]=Rotation.YawCW
        dict[Vector3.Axis.nZ]=Rotation.RollCW
        
        
        //TODO need translation from Rotation to layman terms on phone
        
        if( dict[prod.greatestAxis()] != nil){
            return dict[prod.greatestAxis()]!
        }else {
            return Rotation.Noop
        }
    }
    

}