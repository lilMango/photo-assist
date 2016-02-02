//
//  ImageMatch.cpp
//  Camera1
//
//  Created by Miguel Paysan on 2/1/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

#include "ImageMatch.hpp"

using namespace cv;


cv::Mat getKeypointsImageMatrix(cv::Mat &mat); //TODO: refactor to classes, ProcImage -> Object, Scene
cv::Mat localizeObjInScene(cv::Mat &mat); //TODO: refactor to classes, ProcImage -> Object, Scene

cv::Mat getObjInSceneImageMatrix(cv::Mat &imgm_obj, cv::Mat &imgm_scene);