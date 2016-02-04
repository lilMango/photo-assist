//
//  CVWrapper.h
//  Camera1
//
//  Created by Miguel Paysan on 1/25/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//OBJ-C only code. Their implementations *.mm will handle c++, obj-c and swift? code
@interface CVWrapper : NSObject


+ (UIImage*) toKeypointsImage:(UIImage*)inputImage;

+ (UIImage*) toKeypointsImage:(UIImage*)inputImage x:(int)x y:(int)y w:(int)w h:(int)h;

//TODO: will pass in the object_photo (overlay) and find it within the scene (video frame)
//TODO refactor and use a rectangle class?
+ (UIImage*) getMatchedImage:(UIImage*)inputImage x:(int)x y:(int)y w:(int)w h:(int)h sceneImage:(UIImage*)sceneImage;

+ (void) setOverlayAsObjectImage:(UIImage*)objImg x:(int)x y:(int)y w:(int)w h:(int)h;
+ (void) setFrameAsSceneImage:(UIImage*)sceneImg;

//The focused part of the image, where we placed the Region of Interest box on the overlay image
+ (UIImage*) getOverlayProcessedUIImage;

//The scene with the matched ROI obj marked as green
+ (UIImage*) trackObjInSceneFrame;
@end
