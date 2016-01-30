//
//  CVWrapper.h
//  Camera1
//
//  Created by Miguel Paysan on 1/25/16.
//  Copyright © 2016 Miguel Paysan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CVWrapper : NSObject

+ (UIImage*) processImageWithOpenCV: (UIImage*) inputImage;

+ (UIImage*) processWithOpenCVImage1:(UIImage*)inputImage1 image2:(UIImage*)inputImage2;

+ (UIImage*) processWithArray:(NSArray*)imageArray;

+ (UIImage*) toGreyImage:(UIImage*)inputImage;

+ (UIImage*) toKeypointsImage:(UIImage*)inputImage;

+ (UIImage*) toKeypointsImage:(UIImage*)inputImage x:(int)x y:(int)y w:(int)w h:(int)h;

+ (NSString*) getDiff:(UIImage*)img1 img2:(UIImage*)img2;

//useless --ROI has to be in the matrix calculation step. It can't be it's own Image
+ (UIImage*) toROI:(UIImage*)inputImage x:(short)x y:(short)y w:(short)w h:(short)h;

@end
