//
//  Enums.h
//  printDemo
//
//  Created by Bao Nguyen on 8/14/17.
//  Copyright © 2017  夜晚太黑. All rights reserved.
//

#ifndef Enums_h
#define Enums_h

typedef NS_ENUM(NSUInteger, JPEGQuality) {
    Lowest = 0,
    Low,
    Medium,
    High,
    Highest
};

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

#endif /* Enums_h */
