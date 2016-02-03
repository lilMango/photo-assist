//
//  stitching.h
//  CVOpenTemplate
//
//  Created by Foundry on 05/01/2013.
//  Copyright (c) 2013 Foundry. All rights reserved.
//

#ifndef CVOpenTemplate_Header_h
#define CVOpenTemplate_Header_h
#include <opencv2/opencv.hpp>


cv::Mat getKeypoints (cv::Mat image);
cv::Mat getKeypoints (cv::Mat image, cv::Rect rect);
cv::Mat getROI (cv::Mat image, cv::Rect);


#endif
