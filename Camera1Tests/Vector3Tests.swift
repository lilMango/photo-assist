//
//  Vector3Tests.swift
//  Camera1
//
//  Created by Miguel Paysan on 1/12/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

import Foundation
import XCTest
@testable import Camera1

class Vector3Tests:XCTestCase {
    var vec:Vector3=Vector3()
    
    override func setUp(){
        super.setUp()
        vec=Vector3(a:0.0, b:0.0, c:0.0)
        
    }
    
    func testEquality() {
        var vecb=Vector3(a:0.0,b:0.0,c:0.0)
        //let res=(vec==vecb)
        XCTAssertTrue(false)
    }
    
    func testMagnitude(){
        XCTAssertEqual(0.0, vec.magnitude())
        
        vec.set(3,b:0, c:4)
        XCTAssertEqual(5.0, vec.magnitude())
        
    }
    
    func testNormalize(){
        vec.set(1,b:0,c:0)
        XCTAssertEqual(1.0, vec.magnitude())
        
        vec.set(3,b:0,c:4)
        let vec2=Vector3(a:0.6,b:0,c:0.8)
        vec.normalize()
        XCTAssertEqual(vec2.magnitude(), vec.magnitude())
        XCTAssertEqual(0.6, vec.x)
        XCTAssertEqual(0.0, vec.y)
        XCTAssertEqual(0.8, vec.z)
    }
    
    func testSubtract() {
        var vecb=Vector3(a:10,b:10,c:10)
        var diff=Vector3(a:0,b:0,c:0)
        
        diff=vecb.subtract(vec)
        XCTAssertEqual(10.0,diff.x)
        XCTAssertEqual(10.0,diff.y)
        XCTAssertEqual(10.0,diff.z)
    }
}