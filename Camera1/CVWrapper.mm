//
//  CVWrapper.mm
//  Camera1
//
//  Created by Miguel Paysan on 1/25/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//
// .mm files can use both Objective C and C++
// best to minimize mix and just make calls to c++ interface

#import "CVWrapper.h"
#import "UIImage+OpenCV.h"
#import "stitching.h"
#import "UIImage+Rotate.h"
#import "ProcessedImage.hpp"
#import "ImageMatch.hpp"


@implementation CVWrapper

+ (UIImage *) toKeypointsImage:(UIImage*)inputImage
{
    cv::Mat inputMat = [inputImage CVMat3];
    
    cv::Mat keypointsImg = getKeypoints(inputMat);

    UIImage* result = [UIImage imageWithCVMat:keypointsImg];
    return result;
}

+ (UIImage*) toKeypointsImage:(UIImage*)inputImage x:(int)x y:(int)y w:(int)w h:(int)h
{
    cv::Mat inputMat = [inputImage CVMat3];
    
    cv::Mat keypointsImg = getKeypoints(inputMat,cv::Rect(x,y,w,h));
    
    UIImage* result = [UIImage imageWithCVMat:keypointsImg];
    return result;
}


//Get Flann based matching
+ (UIImage*) getMatchedImage:(UIImage*)inputImage x:(int)x y:(int)y w:(int)w h:(int)h sceneImage:(UIImage*)sceneImage {
    
    cv::Mat imgm_obj = [inputImage CVMat3];
    cv::Rect rect = cv::Rect(x,y,w,h);
    cv::Mat imgm_scene = [sceneImage CVMat3];
    
    cv::Mat imgmg_obj_scene = getObjInSceneImageMatrix(imgm_obj,rect,imgm_scene);
    UIImage* result = [UIImage imageWithCVMat:imgmg_obj_scene];//TODO NOT inputImage
    return result;
}
@end
