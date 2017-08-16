//
//  UIImage+Splitting.m
//  printDemo
//
//  Created by Bao Nguyen on 8/9/17.
//  Copyright © 2017  夜晚太黑. All rights reserved.
//

#import "UIImage+Splitting.h"

@implementation UIImage (Splitting)

- (NSMutableArray *)splitImageswithRow:(NSInteger)rows withColumn:(NSInteger)columns {
    NSMutableArray *subImages = [NSMutableArray array];
    CGFloat xPos = 0.0, yPos = 0.0;
//    CGFloat width = imageSize.width/rows;
//    CGFloat height = imageSize.height/columns;
    
    float scale = [[UIScreen mainScreen] scale];
    float height = self.size.height * scale / (float)rows;
    float width  = self.size.width * scale / (float) columns;
    
    for (int y = 0; y < rows; y++) {
        xPos = 0.0;
        for (int x = 0; x < columns; x++) {
            
            CGRect rect = CGRectMake(xPos, yPos, width, height);
            CGImageRef cImage = CGImageCreateWithImageInRect([self CGImage],  rect);
            
            UIImage *subImage = [[UIImage alloc] initWithCGImage:cImage];
            CFRelease(cImage);
            [subImages addObject:subImage];
            xPos += width;
        }
        yPos += height;
    }
    return subImages;
}

- (NSArray*) splitImagesIntoSubImagesWithNumberOfRows:(NSUInteger)rows numberOfColumns:(NSUInteger)columns {
    float scale = [[UIScreen mainScreen] scale];
    
    float height = self.size.height * scale;
    float width  = self.size.width * scale;
    
    NSMutableArray *subImages = [NSMutableArray array];
    
    for(int y = 0; y < rows; y++) {
        for(int x = 0; x < columns; x++) {
            
            CGRect frame = CGRectMake((width / columns) * x,
                                      (height / rows) * y,
                                      (width / columns),
                                      (height / rows));
            
            CGImageRef subimageRef = CGImageCreateWithImageInRect(self.CGImage, frame);
            
            UIImage* subImage = [UIImage imageWithCGImage:subimageRef scale:scale orientation:UIImageOrientationUp];
            
            CFRelease(subimageRef);
            [subImages addObject:subImage];
        }
    }
    return subImages;
}

@end
