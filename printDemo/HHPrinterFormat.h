//
//  HHPrinterFormat.h
//  BlueToothPrinterT
//
//  Created by hxy on 16/1/17.
//  Copyright © 2016年 huangxinyu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,HHBluePrinterState)
{
    HHBluePrinterStateSetLanagehan,
    HHBluePrinterStateInitialize, //初始化
    HHBluePrinterStateSetLanage, //设置语言指令集 ,此处为中文
    HHBluePrinterStateSetDefultLineSpace, //默认行间距
    HHBluePrinterStateSetLineSpace, //设置行间距
    HHBluePrinterStateSetFontSizeBig, //设置字体大小
    HHBluePrinterStateSetFontDefult, //设置默认字体
    HHBluePrinterStateSetFontHeightBig, //设置字体高度变大
    HHBluePrinterStateAlignmentCenter, //居中
    HHBluePrinterStateAlignmentLeft,//左对齐
    HHBluePrinterStateSeterweima,
    HHBluePrinterStateSeterwe,
    HHBluePrinterStateSeterw

};

@interface HHPrinterFormat : NSObject

@property (nonatomic, strong, readonly) NSMutableString* contentString;

/**
 *  排版标题
 *
 *  @param title 标题文字
 *
 *  @return 返回排版后的标题
 */
- (NSString *)printTitle:(NSString*)title;

/**
 *  打印菜单
 *
 *  @param menuMsgDic Key为水果名字，value为一个字典，其key为数量，value为价格
 *
 *  @return 返回排版后的文字
 */
- (NSString *)printMenuMsg:(NSDictionary<NSString*,NSDictionary*> *)menuMsgDic isHead:(BOOL)isHead;

/**
 *  打印order信息
 *
 *  @param msgDic
 *
 *  @return
 */
- (NSString *)printOrderMsg:(NSDictionary<NSString*,NSString*>*)msgDic;

/**
 *  打印价格信息
 *
 *  @param msgDic
 *
 *  @return
 */
- (NSString *)printPriceMsg:(NSDictionary<NSString*,NSString*>*)msgDic isHead:(BOOL)isHead;

/**
 *  打印地址信息
 *
 *  @param msgDic
 *
 *  @return
 */
- (NSString *)printAddressMsg:(NSDictionary<NSString*,NSString*>*)msgDic isHead:(BOOL)isHead;

/**
 *  打印二维码
 *
 *  @param barString 二维码
 *
 *  @return
 */
- (NSString *)printBarCode:(NSString *)barString;

- (NSString *)printLinePace;

@end
