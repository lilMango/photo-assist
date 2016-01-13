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
     * Pitch-clockwise - X-axis
     */
    func testPitchCW() {
        let v_f = Vector3(a:0,b:0, c:1)
        let v_cur = Vector3(a:0,b:-0.6,c:-0.8)
        
        var rot:PlacementNavigator.Rotation = PlacementNavigator.getOrientationInstruction(v_f,cur:v_cur)

        XCTAssertEqual(PlacementNavigator.Rotation.PitchCW,rot)
        
    }
    
    /**
    * Pitch -CCW - X-axis
    */
    func testPitchCCW() {
        
    }

}
