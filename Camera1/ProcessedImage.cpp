//
//  ProcessedImage.cpp
//  Camera1
//
//  Created by Miguel Paysan on 2/2/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

#include "ProcessedImage.hpp"

//////////////////////////////////////////////////////////////////////
/////////   ProcessedImage class methods ///////////////////////////
//////////////////////////////////////////////////////////////////////
cv::Mat ProcessedImage::getStartImgm() {
    return originalImg;
}

cv::Mat ProcessedImage::getKeypointsImgm() {
    cv::Mat kp_imgm;
    cv::drawKeypoints(originalImg,keypoints,kp_imgm, cv::Scalar::all(-1), cv::DrawMatchesFlags::DRAW_RICH_KEYPOINTS );
    return kp_imgm;
}

ProcessedImage::ProcessedImage(cv::Mat origImgm) {
    originalImg = origImgm;
}

std::vector<cv::KeyPoint> ProcessedImage::getKeypoints() {
    return keypoints;
}

cv::Mat ProcessedImage::getDescriptors() {
    return descriptors;
}

void ProcessedImage::detectAndCompute(cv::Ptr< cv::FeatureDetector >detector, cv::Ptr< cv::DescriptorMatcher > matcher) {
    detector->detect(originalImg, keypoints);
    detector->compute(originalImg, keypoints,descriptors);
    
    //http://stackoverflow.com/questions/29694490/flann-error-in-opencv-3
    if(descriptors.type()!=CV_32F) {
        std::cout << "\tconvert to CV_32F" << std::endl;
        descriptors.convertTo(descriptors, CV_32F);
    }
    
}
//////////////////////////////////////////////////////////////////////
/////////   ProcessedROIImage class methods ///////////////////////////
//////////////////////////////////////////////////////////////////////
ProcessedROIImage::ProcessedROIImage(cv::Rect rect, cv::Mat origImgm):ProcessedImage(origImgm) {
    roiBox=rect;
    
    //convert Unit Percentage ROI to pixels
    float percToPixels = origImgm.cols / 100.0;
    cv::Rect pixROI = cv::Rect(rect.x * percToPixels,
                               rect.y * percToPixels,
                               rect.width * percToPixels,
                               rect.height * percToPixels);
    originalImg = cv::Mat(origImgm, pixROI);
}

