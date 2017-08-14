//
//  ViewController.h
//  printDemo
//
//  Created by  夜晚太黑 on 16/4/26.
//  Copyright © 2016年  夜晚太黑. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef  enum {
    Align_Left = 0X00,
    Align_Center,
    Align_Right,
}Align_Type_e;

typedef  enum {
    Char_Normal = 0X00,
    Char_Zoom_2,
    Char_Zoom_3,
    Char_Zoom_4
}Char_Zoom_Num_e;


typedef  enum {
    TICKET_SALE = 1,
    TICKET_CARD,
}TYPE_TICKET;

#define MAX_CHARACTERISTIC_VALUE_SIZE   32
#define MAX_HEIGHT_SUB_IMAGE            5

@interface ViewController : UIViewController


@end

