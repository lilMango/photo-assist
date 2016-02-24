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
#import "UIImage+Rotate.h"
#import "ProcessedImage.hpp"
#import "ImageMatch.hpp"


@implementation CVWrapper

+ (UIImage *) toKeypointsImage:(UIImage*)inputImage {
    cv::Mat inputMat = [inputImage CVMat3];
    
    cv::Mat keypointsImg = getKeypoints(inputMat);

    UIImage* result = [UIImage imageWithCVMat:keypointsImg];
    return result;
}

+ (UIImage*) toKeypointsImage:(UIImage*)inputImage x:(int)x y:(int)y w:(int)w h:(int)h {
    cv::Mat inputMat = [inputImage CVMat3];
    
    cv::Mat keypointsImg = getKeypoints(inputMat,cv::Rect(x,y,w,h));
    
    UIImage* result = [UIImage imageWithCVMat:keypointsImg];
    return result;
}


+ (void) setOverlayAsObjectImage:(UIImage*)objImg x:(int)x y:(int)y w:(int)w h:(int)h{
    cv::Mat imgm_obj = [objImg CVMat3];
    cv::Rect rect = cv::Rect(x,y,w,h);
    ImageMatch::Instance().setImageObj(new ProcessedROIImage(rect,imgm_obj));

}


+ (void) setFrameAsSceneImage:(UIImage*)sceneImage {
    cv::Mat imgm_scene = [sceneImage CVMat3];
    ImageMatch::Instance().setImageScene(new ProcessedImage(imgm_scene));
}

+ (UIImage*) getOverlayProcessedUIImage {
    cv::Mat kp_imgm = ImageMatch::Instance().getImageObj()->getKeypointsImgm();
    UIImage* res = [UIImage imageWithCVMat:kp_imgm];
    return res;
}

+ (UIImage*) trackObjInSceneFrame {
    cv::Mat imgm_matches = ImageMatch::Instance().matchImages(
                                                         ImageMatch::Instance().getImageObj()->getDescriptors(),
                                                         ImageMatch::Instance().getImageScene()->getDescriptors());
    UIImage* res = [UIImage imageWithCVMat:imgm_matches];
    return res;
}

+ (bool) isTrackableScene {
    if(ImageMatch::Instance().getImageObj()!=nil && ImageMatch::Instance().getImageScene()!=nil) {        
        return true;
    }
    return false;
}

@end
