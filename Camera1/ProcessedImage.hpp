//
//  ProcessedImage.hpp
//  Camera1
//
//  Created by Miguel Paysan on 2/2/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

#ifndef ProcessedImage_hpp
#define ProcessedImage_hpp

#include <iostream>
#include <fstream>

#include <opencv2/opencv.hpp>
#include "opencv2/core.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/calib3d.hpp"
#include "opencv2/imgproc.hpp"

class ProcessedImage {
public:
    cv::Mat getStartImgm();
    cv::Mat getKeypointsImgm();
    void setKeypoints();
    std::vector<cv::KeyPoint> getKeypoints();
    void detectAndCompute(cv::Ptr<cv::FeatureDetector>, cv::Ptr<cv::DescriptorMatcher> );
    cv::Mat getDescriptors();
    ProcessedImage(cv::Mat);
    ~ProcessedImage(){};
protected:
    cv::Mat originalImg;
    std::vector<cv::KeyPoint> keypoints;
    cv::Mat descriptors;
};


class ProcessedROIImage: public ProcessedImage {
public:
    cv::Rect roiBox;
    ProcessedROIImage(cv::Rect,cv::Mat);
    ~ProcessedROIImage(){};
protected:

};
#endif /* ProcessedImage_hpp */
