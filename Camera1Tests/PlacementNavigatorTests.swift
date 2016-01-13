//
//  PlacementNavigatorTests.swift
//  Camera1
//
//  Created by Miguel Paysan on 1/8/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

import Foundation
import XCTest
@testable import Camera1

class PlacementNavigatorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    /**
     * Pitch-counter clockwise: +X-axis
     */
    func testPitchCCW() {
        let v_cur = Vector3(a:0,b:1.0,c:0.0)
        let v_f = Vector3(a:0,b:0, c:1)
        
        let rot:PlacementNavigator.Rotation = PlacementNavigator.getOrientationInstruction(v_f,cur:v_cur)

        XCTAssertEqual(PlacementNavigator.Rotation.PitchCCW,rot)
    }
    
    /**
     * Pitch-clockwise: -X-axis
     */
    func testPitchCW() {
        let v_cur = Vector3(a:0,b:0.0,c:1.0)
        let v_f = Vector3(a:0,b:1.0, c:0.0)

        
        let rot:PlacementNavigator.Rotation = PlacementNavigator.getOrientationInstruction(v_f,cur:v_cur)
        
        XCTAssertEqual(PlacementNavigator.Rotation.PitchCW,rot)
    }
    
    /**
     * Yaw- counter clockwise : +Y-axis
     */
    func testYawCCW() {
        let v_cur = Vector3(a:-1,b:0,c:0)
        let v_f = Vector3(a:0,b:0, c:1)

        
        let rot:PlacementNavigator.Rotation = PlacementNavigator.getOrientationInstruction(v_f,cur:v_cur)
        
        XCTAssertEqual(PlacementNavigator.Rotation.YawCCW,rot)
    }
    
    /**
     * Yaw- clockwise : -Y-axis
     */
    func testYawCW() {
        let v_cur = Vector3(a:0,b:0,c:1)
        let v_f = Vector3(a:-1,b:0, c:0)
        
        
        let rot:PlacementNavigator.Rotation = PlacementNavigator.getOrientationInstruction(v_f,cur:v_cur)
        
        XCTAssertEqual(PlacementNavigator.Rotation.YawCW,rot)
    }
    
    /**
    * Roll- counter clockwise: +Z-axis
    */
    func testRollCCW() {
        let v_cur = Vector3(a:1,b:0,c:0)
        let v_f = Vector3(a:0,b:1, c:0)
        
        
        let rot:PlacementNavigator.Rotation = PlacementNavigator.getOrientationInstruction(v_f,cur:v_cur)
        
        XCTAssertEqual(PlacementNavigator.Rotation.RollCCW,rot)
    }

    /**
     * Roll- clockwise: -Z-axis
     */
    func testRollCW() {
        let v_cur = Vector3(a:0,b:1,c:0)
        let v_f = Vector3(a:1,b:0, c:0)
        
        
        let rot:PlacementNavigator.Rotation = PlacementNavigator.getOrientationInstruction(v_f,cur:v_cur)
        
        XCTAssertEqual(PlacementNavigator.Rotation.RollCW,rot)
    }
}
