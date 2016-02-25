//
//  ImageMatch.hpp
//  Camera1
//
//  Created by Miguel Paysan on 2/1/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

#ifndef ImageMatch_hpp
#define ImageMatch_hpp

#include <iostream>
#include <fstream>

#include <opencv2/opencv.hpp>
#include "opencv2/core.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/calib3d.hpp"
#include "opencv2/imgproc.hpp"
#include "ProcessedImage.hpp"


cv::Mat getKeypoints (cv::Mat image);
cv::Mat getKeypoints (cv::Mat image, cv::Rect rect);

/** **/
class ImageMatch {
public:
    enum DrawBitmasks{
        KEYPOINTS=0x01,
        ROIBOX=0x02,
        TRACKED=0x04
    };
    //zomg Singleton pattern!
    static ImageMatch &Instance() {
        static ImageMatch imageMatchInstance;
        return imageMatchInstance;
    }
    
    void Hello() {
        std::cout << "Hello from ImageMatch singleton" << std::endl;
    }
    
    cv::Ptr<cv::FeatureDetector> detector;
    cv::Ptr<cv::DescriptorMatcher> matcher;
    
    void setImageObj(ProcessedROIImage *img);
    void setImageScene(ProcessedImage *img);
    
    cv::Mat matchImages(cv::Mat objDescriptor, cv::Mat sceneDescriptor, int drawingBitmasks);
    ProcessedROIImage* getImageObj();
    ProcessedImage* getImageScene();
    //void reset();
    
protected:
    ProcessedROIImage *obj;//has ROI image
    ProcessedImage *scene;

    ImageMatch() {
        detector = cv::ORB::create();
        matcher = cv::DescriptorMatcher::create("FlannBased");
    };
    ~ImageMatch(){
    
    }
};


#endif /* ImageMatch_hpp */
