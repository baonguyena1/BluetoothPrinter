//
//  UIImage+Splitting.h
//  printDemo
//
//  Created by Bao Nguyen on 8/9/17.
//  Copyright © 2017  夜晚太黑. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Splitting)

- (NSMutableArray *)splitImageswithRow:(NSInteger)rows withColumn:(NSInteger)columns;

- (NSArray*) splitImagesIntoSubImagesWithNumberOfRows:(NSUInteger)rows numberOfColumns:(NSUInteger)columns;

@end
