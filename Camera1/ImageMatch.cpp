//
//  ImageMatch.cpp
//  Camera1
//
//  Created by Miguel Paysan on 2/1/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

#include "ImageMatch.hpp"

using namespace cv;


//////////////////////////////////////////////////////////////////////
/////////   ImageMatch class methods ///////////////////////////
//////////////////////////////////////////////////////////////////////
void ImageMatch::setImageObj(ProcessedROIImage *img) {
    std::cout<< "@ImageMatch.setImageObj" << std::endl;
    delete(obj);
    obj = NULL;
    obj = img;
    
    //TODO detect And Compute to set keypoints and descriptors ***** we have keypoints in case we want to apply a draw keypoints image
    img->detectAndCompute(ImageMatch::detector, ImageMatch::matcher);
    
}

void ImageMatch::setImageScene(ProcessedImage *img) {
        std::cout<< "@ImageMatch.setImageScene" << std::endl;
    delete(scene);
    scene = NULL;
    scene= img;
    
    scene->detectAndCompute(ImageMatch::detector, ImageMatch::matcher);
}


ProcessedROIImage* ImageMatch::getImageObj() {
    return obj;
}

ProcessedImage* ImageMatch::getImageScene() {
    return scene;
}

/*************
 * ImageMatch::matchImages
 * returns Matrix of the image.
 * if there are similarities, it will show the object within the scene
 * else will show JUST the scene
 *
 *****************/
cv::Mat ImageMatch::matchImages(cv::Mat objDescriptor, cv::Mat sceneDescriptor) {
    std::cout << "@ImageMatch. matchImages()---" << std::endl;
    
    std::vector< DMatch > matches;
    matcher->match(objDescriptor, sceneDescriptor, matches);
    
    std::cout << "matches: " << matches.size() << std::endl;
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i <  sceneDescriptor.rows; i++ )
    {
        double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    std::cout << "min_dist:" << min_dist << "\tmax_dist:" << max_dist << std::endl;
    
    //-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
    float GOOD_MATCH_DISTANCE_THRESHOLD = 3*min_dist;
    std::vector< DMatch > good_matches;
    
    for( int i = 0; i <  ImageMatch::Instance().getImageObj()->getDescriptors().rows; i++ ) {
        if( matches[i].distance < GOOD_MATCH_DISTANCE_THRESHOLD ) {
            good_matches.push_back( matches[i]);
        }
    }
    
    if (good_matches.size()<4) {
        std::cout << "[ERROR] Not enough good_matches:" << good_matches.size() << "\n\tReturning original scene image instead" << std::endl;
        return scene->getStartImgm();
    }
    
    Mat imgm_matches;
    
    drawKeypoints( getImageScene()->getStartImgm(), ImageMatch::Instance().getImageScene()->getKeypoints(), imgm_matches, Scalar::all(-1), DrawMatchesFlags::DRAW_RICH_KEYPOINTS );
    
    bool tmp=false;
    if(tmp) { std::cout << "exit keypoint drawing:" << std::endl; return imgm_matches; }
    
    //-- Localize the object ------------------------------------
    std::vector<Point2f> obj;
    std::vector<Point2f> scene;
    
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        obj.push_back(  ImageMatch::Instance().getImageObj()->getKeypoints()[ good_matches[i].queryIdx ].pt );
        scene.push_back(ImageMatch::Instance().getImageScene()->getKeypoints()[ good_matches[i].trainIdx ].pt );
    }
    
    std::cout << "good_matches count:" << good_matches.size() << std::endl;
    
    Mat H = findHomography( obj, scene, RANSAC );

    int objCols = getImageObj()->getStartImgm().cols;
    int objRows = getImageObj()->getStartImgm().rows;
    
    //-- Get the corners from the image_1 ( the object to be "detected" )
    std::vector<Point2f> obj_corners(4);
    obj_corners[0] = cvPoint(0,0); obj_corners[1] = cvPoint( objCols, 0 );
    obj_corners[2] = cvPoint( objCols, objRows ); obj_corners[3] = cvPoint( 0, objRows );
    std::vector<Point2f> scene_corners(4);
    
    perspectiveTransform( obj_corners, scene_corners, H);
    
    //-- Draw lines between the corners (the mapped object in the scene - image_2 )
    
    line( imgm_matches, scene_corners[0] , scene_corners[1] , Scalar( 0, 255, 0), 10 );
    line( imgm_matches, scene_corners[1] , scene_corners[2] , Scalar( 0, 255, 0), 10 );
    line( imgm_matches, scene_corners[2] , scene_corners[3] , Scalar( 0, 255, 0), 10 );
    line( imgm_matches, scene_corners[3] , scene_corners[0] , Scalar( 0, 255, 0), 10 );

//    Point2f a(100.0f, 100.0f), b(1000.0f, 1000.0f);
//    line( imgm_matches, a, b, Scalar(255,255,0),10 );//yellow line
    std::cout << "A:" << scene_corners[0] << "  B: " <<  scene_corners[1] << std::endl;
    std::cout << "A:" << scene_corners[1] << "  B: " <<  scene_corners[2] << std::endl;
    std::cout << "A:" << scene_corners[2] << "  B: " <<  scene_corners[3] << std::endl;
    std::cout << "A:" << scene_corners[3] << "  B: " <<  scene_corners[0] << std::endl;
    
    return imgm_matches;

}//end ImageMatch::matchImages()


//////////////////////////////////////////////////////////////////////
/////////   TODO: Make utility function that does keypoints on any image  ///////////////////////////
//////////////////////////////////////////////////////////////////////

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