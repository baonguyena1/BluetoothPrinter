//
//  UIImage+Compress.h
//  printDemo
//
//  Created by Bao Nguyen on 8/14/17.
//  Copyright © 2017  夜晚太黑. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enums.h"

@interface UIImage (Compress)

- (UIImage *)jpeg:(JPEGQuality)quality;

@end
