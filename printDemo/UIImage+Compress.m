//
//  UIImage+Compress.m
//  printDemo
//
//  Created by Bao Nguyen on 8/14/17.
//  Copyright © 2017  夜晚太黑. All rights reserved.
//

#import "UIImage+Compress.h"
#import "Enums.h"

@implementation UIImage (Compress)

- (UIImage *)jpeg:(JPEGQuality)quality {
    CGFloat compressQuality = 0.0;
    switch (quality) {
        case Lowest:
            compressQuality = 0.0;
            break;
        case Low:
            compressQuality = 0.25;
            break;
        case Medium:
            compressQuality = 0.5;
            break;
        case High:
            compressQuality = 0.75;
            break;
        case Highest:
            compressQuality = 1.0;
            break;
    }
    NSData *originalData = UIImagePNGRepresentation(self);
    NSData *data = UIImageJPEGRepresentation(self, compressQuality);
    NSLog(@"%ld %ld", originalData.length, data.length);
    return [[UIImage alloc] initWithData:data];
}

@end
