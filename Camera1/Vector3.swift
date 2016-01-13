//
//  Vector3.swift
//  Camera1
//
//  Created by Miguel Paysan on 1/12/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

import Foundation

class Vector3:Equatable {
    enum Axis{
        case X,Y,Z,nX,nY,nZ
    }

    var x:Double = 0.0
    var y:Double = 0.0
    var z:Double = 0.0
    
    init(){
        self.reset()
    }
    
    init (a:Double,b:Double,c:Double){
        set(a,b:b,c:c)
    }
    
    func set(a:Double, b:Double, c:Double){
        x=a
        y=b
        z=c
    }
    func reset() {
        x=0.0
        y=0.0
        z=0.0
    }
    
    func magnitude() -> Double {
        return sqrt(x*x
            + y*y + z*z)
    }
    
    func normalize(){
        let mag=self.magnitude()
        x=x/mag
        y=y/mag
        z=z/mag
    }
    
    
    /* caller is A
    * argument is B
    * returns Vector3 (A-B)
    */
    func subtract(b:Vector3)->Vector3{
        return Vector3(a:(x-b.x),
                        b:(y-b.y),
                         c:(z-b.z))
    }
    
    /* cross product of AxB, where A is the caller
    */
    func cross(b:Vector3) -> Vector3{
        let prod=Vector3(a:y*b.z-b.y*z,
                         b:-(x*b.z)+b.x*z,
                         c:x*b.y-b.x*y)
        return prod
    }
    
    /*
    * Returns enum of highest valued axis in this vector
    */
    func greatestAxis()-> Axis {
        var res = Axis.X
        var high=x
        
        if(x<0 && abs(x)>high) {
            res=Axis.nX
            high=abs(x)
            
        }
        if(y>high) {
           res=Axis.Y
           high=y
        }
        if(y<0 && abs(y)>high){
            res=Axis.nY
            high=abs(y)
        }
        
        if(z>high) {
           res=Axis.Z
           high=z
        }
        
        if(z<0 && abs(z)>high) {
           res=Axis.nZ           
        }
        
        return res
    }
}

func ==(lhs: Vector3, rhs: Vector3) -> Bool {
    return lhs.x==rhs.x &&
        lhs.y==rhs.y &&
        lhs.z==rhs.z
}