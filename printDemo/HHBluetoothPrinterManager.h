//
//  HHBluetoothPrinterManager.h
//  BlueToothPrinterT
//
//  Created by hxy on 16/1/17.
//  Copyright © 2016年 huangxinyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "HHPrinterFormat.h"
@class HHBluetoothPrinterManager;

/**
 *  HHBluetoothPrinterManagerDelegate
 */
@protocol HHBluetoothPrinterManagerDelegate <NSObject>
@required
/**
 *  蓝牙中心管理状态变化
 *
 *  @param central 蓝牙中心管理
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
/**
 *  扫描到蓝牙设备
 *
 *  @param central    蓝牙中心管理
 *  @param peripheral 蓝牙设备
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral;
/**
 *  设备连接成功
 *
 *  @param central    蓝牙中心管理
 *  @param peripheral 蓝牙设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
/**
 *  连接设备失败
 *
 *  @param central   蓝牙中心管理
 *  @param peripheral 蓝牙设备
 *  @param error      错误
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;


@end

@interface HHBluetoothPrinterManager : NSObject

@property (nonatomic, weak) id<HHBluetoothPrinterManagerDelegate> delegate;
/**
 *  蓝牙中心管理状态
 */
@property (nonatomic, assign, readonly) CBCentralManagerState centralState;

//单例
+ (instancetype)sharedManager;
//扫描蓝牙设备
- (void)scanPeripherals;
//取消扫描
- (void)cancelScan;
//连接蓝牙设备
- (void)connectPeripheral:(CBPeripheral *)peripheral;
//打印数据
- (void)printData:(NSData *)writeData;
- (void)duankai:(CBPeripheral *)peripheral;
- (void)setupPrinterState:(HHBluePrinterState)state;
- (void)startPrint:(NSData *)writeData;

@end
