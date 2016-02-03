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

using namespace cv;

class ProcessedImage {
public:
    void setKeypoints();
    Mat getKeypoints();
    void detectAndCompute();
    ProcessedImage();
    ~ProcessedImage();
private:
    Mat originalImg;
    std::vector<KeyPoint> keypoints;
    Mat descriptors;
};


class ProcessedROIImage: ProcessedImage {
public:
    //Rect roiBox;
    //ProcessedROIImage(Rect,Mat);
    ~ProcessedROIImage();
private:

};
#endif /* ProcessedImage_hpp */
