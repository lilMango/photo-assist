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

+ (void) setOverlayAsObjectImage:(UIImage*)objImg x:(int)x y:(int)y w:(int)w h:(int)h{
    std::cout << "@CVWrapper.mm:: setOverlayAsObjectImage( x: " << x << "\ty: " << y << "\tw: " << w << "\th: " << h << std::endl;
    cv::Mat imgm_obj = [objImg CVMat3];
    cv::Rect rect = cv::Rect(x,y,w,h);
    ImageMatch::Instance().setImageObj(new ProcessedROIImage(rect,imgm_obj));

}


//TODO
+ (void) setFrameAsSceneImage:(UIImage*)sceneImage {

    cv::Mat imgm_scene = [sceneImage CVMat3];
    ImageMatch::Instance().setImageScene(new ProcessedImage(imgm_scene));
}

+ (UIImage*) getOverlayProcessedUIImage {
    std::cout << "@CVWrapper.getOverlayProcessedUIImage" << std::endl;
    cv::Mat kp_imgm = ImageMatch::Instance().getImageObj()->getKeypointsImgm();
    UIImage* res = [UIImage imageWithCVMat:kp_imgm];
    return res;
}

+ (UIImage*) trackObjInScene {
    std::cout << "@CVWrapper.trackObjInScene" << std::endl;
    cv::Mat imgm_matches = ImageMatch::Instance().matchImages(
                                                         ImageMatch::Instance().getImageObj()->getDescriptors(),
                                                         ImageMatch::Instance().getImageScene()->getDescriptors());
    UIImage* res = [UIImage imageWithCVMat:imgm_matches];
    return res;
    
}

@end
