//
//  ImageMatch.cpp
//  Camera1
//
//  Created by Miguel Paysan on 2/1/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

#include "ImageMatch.hpp"

using namespace cv;


Mat getObjInSceneImageMatrix(Mat imgm_obj, Rect &rect, Mat imgm_scene) {
    
    //http://docs.opencv.org/3.0-beta/doc/tutorials/features2d/feature_homography/feature_homography.html
    ////////////////////  ////////////////////  ////////////////////  ////////////////////
    
    //-- Step 1. Detect key points for each photo, use ORB or SURF. -----------------------------
    Ptr<ORB> orb=ORB::create();
    
    Ptr<FeatureDetector> detector=orb; //Feature Detector is also DescriptorExtract (same typedef of Feature2D) as of OpenCV3
    
    std::vector<KeyPoint> keypoints_obj, keypoints_scene;
    
    //Change to ROI matrix
    //cv::Mat image = cv::Mat(img1, Rect(100,100,200,200));
    
    detector->detect( imgm_obj, keypoints_obj );
    detector->detect( imgm_scene, keypoints_scene );
    
    //-- Step 2: Calculate descriptors (feature vectors) -----------------------------
    Mat descriptors_obj, descriptors_scene;
    
    detector->compute( imgm_obj, keypoints_obj, descriptors_obj );
    detector->compute( imgm_scene, keypoints_scene, descriptors_scene );
    
    std::cout << "descriptors_obj count:" << descriptors_obj.rows << std::endl;

    
    //-- Step 3: Compare Matching descriptor vectors using FLANN matcher -----------------------------
    FlannBasedMatcher matcher;
    std::vector< DMatch > matches;
    
    //http://stackoverflow.com/questions/29694490/flann-error-in-opencv-3
    if(descriptors_obj.type()!=CV_32F) {
        descriptors_obj.convertTo(descriptors_obj, CV_32F);
    }
    
    if(descriptors_scene.type()!=CV_32F) {
        descriptors_scene.convertTo(descriptors_scene, CV_32F);
    }
    
    matcher.match( descriptors_obj, descriptors_scene, matches );
    
    std::cout << "matches: " << matches.size() << std::endl;
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_obj.rows; i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    std::cout << "min_dist:" << min_dist << "\tmax_dist:" << max_dist << std::endl;
    
    //-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
    std::vector< DMatch > good_matches;
    
    for( int i = 0; i < descriptors_obj.rows; i++ )
    { if( matches[i].distance < 3*min_dist )
    { good_matches.push_back( matches[i]); }
    }

    if (good_matches.size()<4) {
        std::cout << "[ERROR] Not enough good_matches:" << good_matches.size() << "\n\tReturning original scene image instead" << std::endl;
        return imgm_scene;
    }
    
    
    Mat imgm_matches;
    
    drawKeypoints( imgm_scene, keypoints_scene, imgm_matches, Scalar::all(-1), DrawMatchesFlags::DRAW_RICH_KEYPOINTS );
    
    bool tmp=false;
    if(tmp) { std::cout << "exit keypoint drawing:" << std::endl; return imgm_matches; }
    //-- Localize the object ------------------------------------
    std::vector<Point2f> obj;
    std::vector<Point2f> scene;
    
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        obj.push_back( keypoints_obj[ good_matches[i].queryIdx ].pt );
        scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );
    }

    std::cout << "good_Matches count:" << good_matches.size() << std::endl;
    //std::cout << "Printing OBJ[Point2f]" << std::endl;
    //std::cout << obj << std::endl;
    //std::cout << "Printing scene[Point2f]" << std::endl;
    //std::cout << scene << std::endl;
    
    Mat H = findHomography( obj, scene, RANSAC );
    std::cout << "H:\n" << H << std::endl;
    
    //-- Get the corners from the image_1 ( the object to be "detected" )
    std::vector<Point2f> obj_corners(4);
    obj_corners[0] = cvPoint(0,0); obj_corners[1] = cvPoint( imgm_obj.cols, 0 );
    obj_corners[2] = cvPoint( imgm_obj.cols, imgm_obj.rows ); obj_corners[3] = cvPoint( 0, imgm_obj.rows );
    std::vector<Point2f> scene_corners(4);
    
    perspectiveTransform( obj_corners, scene_corners, H);
    
    //-- Draw lines between the corners (the mapped object in the scene - image_2 )

    line( imgm_matches, scene_corners[0] , scene_corners[1] , Scalar( 0, 255, 0), 10 );
    line( imgm_matches, scene_corners[1] , scene_corners[2] , Scalar( 0, 255, 0), 10 );
    line( imgm_matches, scene_corners[2] , scene_corners[3] , Scalar( 0, 255, 0), 10 );
    line( imgm_matches, scene_corners[3] , scene_corners[0] , Scalar( 0, 255, 0), 10 );
    
    Point2f a(100.0f, 100.0f), b(1000.0f, 1000.0f);
    line( imgm_matches, a, b, Scalar(255,0,0),10 );
    std::cout << "A:" << scene_corners[0] << "  B: " <<  scene_corners[1] << std::endl;
    std::cout << "A:" << scene_corners[1] << "  B: " <<  scene_corners[2] << std::endl;
    std::cout << "A:" << scene_corners[2] << "  B: " <<  scene_corners[3] << std::endl;
    std::cout << "A:" << scene_corners[3] << "  B: " <<  scene_corners[0] << std::endl;

    
    return imgm_matches;
}