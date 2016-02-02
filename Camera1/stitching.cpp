/////////////////////////
/*
 
 // stitching.cpp
 // adapted from stitching.cpp sample distributed with openCV source.
 // adapted by Foundry for iOS
 
 */



/*M///////////////////////////////////////////////////////////////////////////////////////
//
//  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.
//
//  By downloading, copying, installing or using the software you agree to this license.
//  If you do not agree to this license, do not download, install,
//  copy or use the software.
//
//
//                          License Agreement
//                For Open Source Computer Vision Library
//
// Copyright (C) 2000-2008, Intel Corporation, all rights reserved.
// Copyright (C) 2009, Willow Garage Inc., all rights reserved.
// Third party copyrights are property of their respective owners.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//   * Redistribution's of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//   * Redistribution's in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//   * The name of the copyright holders may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
// This software is provided by the copyright holders and contributors "as is" and
// any express or implied warranties, including, but not limited to, the implied
// warranties of merchantability and fitness for a particular purpose are disclaimed.
// In no event shall the Intel Corporation or contributors be liable for any direct,
// indirect, incidental, special, exemplary, or consequential damages
// (including, but not limited to, procurement of substitute goods or services;
// loss of use, data, or profits; or business interruption) however caused
// and on any theory of liability, whether in contract, strict liability,
// or tort (including negligence or otherwise) arising in any way out of
// the use of this software, even if advised of the possibility of such damage.
//
//

 M*/

#include "stitching.h"
#include <iostream>
#include <fstream>

//openCV 2.4.x
//#include "opencv2/stitcher.hpp"

//openCV 3.x
#include "opencv2/stitching.hpp"


using namespace std;
using namespace cv;

bool try_use_gpu = false;
vector<Mat> imgs;
string result_name = "result.jpg";

void printUsage();
int parseCmdArgs(int argc, char** argv);

cv::Mat stitch (vector<Mat>& images)
{
    imgs = images;
    Mat pano;
    Stitcher stitcher = Stitcher::createDefault(try_use_gpu);
    Stitcher::Status status = stitcher.stitch(imgs, pano);
    
    if (status != Stitcher::OK)
        {
        cout << "Can't stitch images, error code = " << int(status) << endl;
            //return 0;
        }
    return pano;
}

cv::Mat getKeypoints(Mat image)
{
    
 
    Ptr<GFTTDetector> gftt = GFTTDetector::create( 100, 0.1,
                                                      1.0, 3,
                                                      false, 0.04
                                                      );
    Ptr<FastFeatureDetector> fast = FastFeatureDetector::create(1000, true, FastFeatureDetector::TYPE_9_16); //higher threshold means stricter corner detection
    Ptr<ORB> orb=ORB::create();
    
    Ptr<FeatureDetector> detector=orb;
    
    std::vector<KeyPoint> keypoints_1;
    
    detector->detect( image, keypoints_1 );
    
    //-- Draw keypoints
    Mat img_keypoints_1; //image with points on them
    
    drawKeypoints( image, keypoints_1, img_keypoints_1, Scalar::all(-1), DrawMatchesFlags::DEFAULT );
    
    //is this working?
    //cv::KeyPointsFilter::retainBest(keypoints_1, 100);
    return img_keypoints_1;
}

cv::Mat getKeypoints(Mat img, Rect rect)
{
    
    
    Ptr<GFTTDetector> gftt = GFTTDetector::create( 100, 0.1,
                                                  1.0, 3,
                                                  false, 0.04
                                                  );
    Ptr<FastFeatureDetector> fast = FastFeatureDetector::create(1000, true, FastFeatureDetector::TYPE_9_16); //higher threshold means stricter corner detection
    Ptr<ORB> orb=ORB::create();
    
    Ptr<FeatureDetector> detector=orb;
    
    std::vector<KeyPoint> keypoints_1;
    
    //Change to ROI matrix
    cv::Mat image = cv::Mat(img, rect);
    
    detector->detect( image, keypoints_1 );
    
    //-- Draw keypoints
    Mat img_keypoints_1; //image with points on them
    
    drawKeypoints( image, keypoints_1, img_keypoints_1, Scalar::all(-1), DrawMatchesFlags::DRAW_RICH_KEYPOINTS );
    
    //is this working?
    //cv::KeyPointsFilter::retainBest(keypoints_1, 100);
    return img_keypoints_1;
}


cv::Mat getROI (cv::Mat image, cv::Rect rect)
{
    Rect roiRect = rect;
    
    cv::Mat roiMat = cv::Mat(image, roiRect); //source image mat, and roi rectangle
    
    return roiMat;
}

void flannDiff(cv::Mat img1, cv::Mat img2)
{
    //-- Step 0. --prepping input as matrix
    //get overlay image as ROI matrix
    
    //pass overlay mat and camera mat to
    
    
    //-- Step 1. Detect key points for each photo, use ORB!
    Ptr<ORB> orb=ORB::create();
    
    Ptr<FeatureDetector> detector=orb; //Feature Detector is also DescriptorExtract (same typedef of Feature2D) as of OpenCV3
    
    std::vector<KeyPoint> keypoints_1, keypoints_2;
    
    //Change to ROI matrix
    cv::Mat image = cv::Mat(img1, Rect(100,100,200,200));
    
    detector->detect( img1, keypoints_1 );
    detector->detect( img2, keypoints_2 );
    
    //-- Step 2: Calculate descriptors (feature vectors)
    Mat descriptors_1, descriptors_2;
    
    detector->compute( img1, keypoints_1, descriptors_1 );
    detector->compute( img2, keypoints_2, descriptors_2 );
    
    
    cout << "extractor desc algo name: " << 3 << " " << detector->getDefaultName().c_str() << endl;

   
    //-- Step 3: Compare Matching descriptor vectors using FLANN matcher
    FlannBasedMatcher matcher;
    std::vector< DMatch > matches;
    
    //http://stackoverflow.com/questions/29694490/flann-error-in-opencv-3
    if(descriptors_1.type()!=CV_32F) {
        descriptors_1.convertTo(descriptors_1, CV_32F);
    }
    
    if(descriptors_2.type()!=CV_32F) {
        descriptors_2.convertTo(descriptors_2, CV_32F);
    }
    
    matcher.match( descriptors_1, descriptors_2, matches );
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_1.rows; i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    printf("-- Max dist : %f \n", max_dist );
    printf("-- Min dist : %f \n", min_dist );
    

}

