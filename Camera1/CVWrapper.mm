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


@implementation CVWrapper

+ (UIImage*) processImageWithOpenCV: (UIImage*) inputImage
{
    NSArray* imageArray = [NSArray arrayWithObject:inputImage];
    UIImage* result = [[self class] processWithArray:imageArray];
    return result;
}

+ (UIImage*) processWithOpenCVImage1:(UIImage*)inputImage1 image2:(UIImage*)inputImage2;
{
    NSArray* imageArray = [NSArray arrayWithObjects:inputImage1,inputImage2,nil];
    UIImage* result = [[self class] processWithArray:imageArray];
    return result;
}

+ (UIImage*) processWithArray:(NSArray*)imageArray
{
    if ([imageArray count]==0){
        NSLog (@"imageArray is empty");
        return 0;
        }
    std::vector<cv::Mat> matImages;

    for (id image in imageArray) {
        if ([image isKindOfClass: [UIImage class]]) {
            /*
             All images taken with the iPhone/iPa cameras are LANDSCAPE LEFT orientation. The  UIImage imageOrientation flag is an instruction to the OS to transform the image during display only. When we feed images into openCV, they need to be the actual orientation that we expect them to be for stitching. So we rotate the actual pixel matrix here if required.
             */
            UIImage* rotatedImage = [image rotateToImageOrientation];
            cv::Mat matImage = [rotatedImage CVMat3];
            NSLog (@"matImage: %@",image);
            matImages.push_back(matImage);
        }
    }
    NSLog (@"stitching...");
    
    //Method to call CPP specific code
    cv::Mat stitchedMat = stitch (matImages);
    UIImage* result =  [UIImage imageWithCVMat:stitchedMat];
    return result;
}

+ (UIImage*) toGreyImage:(UIImage*)inputImage
{
    cv::Mat inputMat = [inputImage CVMat3];
    
    cv::Mat greyMat;
    cv::cvtColor(inputMat, greyMat, CV_BGR2GRAY);
    
    UIImage* result = [UIImage imageWithCVMat:greyMat];
    return result;
}


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

+ (UIImage *) toROI:(UIImage*)inputImage x:(short)x y:(short)y w:(short)w h:(short)h

{
    cv::Mat inputMat = [inputImage CVMat3];
    
    cv::Rect rect = cv::Rect(x,y,w,h);
    
    cv::Mat roiImg = getROI(inputMat, rect);
    
    UIImage* result = [UIImage imageWithCVMat:roiImg];
    return result;
}
@end
