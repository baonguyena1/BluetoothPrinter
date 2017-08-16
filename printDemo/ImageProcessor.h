//
//  ImageProcessor.h
//  SpookCam
//
//  Created by Jack Wu on 2/21/2014.
//
//

#import <UIKit/UIKit.h>
#import "Enums.h"

@protocol ImageProcessorDelegate <NSObject>

@optional
- (void)imageProcessorFinishedProcessingWithImage:(UIImage*)outputImage;
- (void)imageProcessorFinishedProcessingWithPixel:(UInt32 *)pixels;

@end

@interface ImageProcessor : NSObject

@property (weak, nonatomic) id<ImageProcessorDelegate> delegate;

+ (instancetype)shared;

- (void)processImage:(UIImage*)inputImage;
- (void)pixelsOfImage:(UIImage *)inputImage;

@end
