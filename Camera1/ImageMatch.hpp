//
//  ImageMatch.hpp
//  Camera1
//
//  Created by Miguel Paysan on 2/1/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

#ifndef ImageMatch_hpp
#define ImageMatch_hpp

#include <opencv2/opencv.hpp>
#include "opencv2/core.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/calib3d.hpp"
#include "opencv2/imgproc.hpp"


cv::Ptr<cv::FeatureDetector> detector=cv::ORB::create();
cv::FlannBasedMatcher matcher;
std::vector< cv::DMatch > matches;
std::vector< cv::DMatch > good_matches;

cv::Mat detectAndDescriptor(cv::Mat &obj, cv::Mat &scene);
void setMatches(cv::Mat &descriptor_obj, cv::Mat &descriptor_scene, cv::DescriptorMatcher/*Flann*/ &matcher); //have a reset vector for matches
void setGoodMatches(cv::Mat &descriptor_obj, cv::Mat &descriptor_scene); //have a reset vector for matches

cv::Mat getKeypointsImageMatrix(cv::Mat &mat); //TODO: refactor to classes, ProcImage -> Object, Scene
cv::Mat localizeObjInScene(cv::Mat &mat); //TODO: refactor to classes, ProcImage -> Object, Scene

cv::Mat getObjInSceneImageMatrix(cv::Mat &imgm_obj, cv::Mat &imgm_scene);

#endif /* ImageMatch_hpp */
