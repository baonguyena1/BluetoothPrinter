//
//  HHBluetoothPrinterManager.m
//  BlueToothPrinterT
//
//  Created by hxy on 16/1/17.
//  Copyright © 2016年 huangxinyu. All rights reserved.
//

#import "HHBluetoothPrinterManager.h"
#import "HHPrinterFormat.h"

@interface HHBluetoothPrinterManager ()<CBCentralManagerDelegate, CBPeripheralDelegate>

/**
 *  蓝牙中央管理
 */
@property (nonatomic, strong) CBCentralManager *centralManager;
/**
 *  已连接的周边对象
 */
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
/**
 *  已连接的服务
 */
@property (nonatomic, strong) CBService *connectedService;
/**
 *  已连接的特征值
 */
@property (nonatomic, strong) CBCharacteristic *connectedCharacteristic;

@property (nonatomic, assign, readwrite) CBCentralManagerState centralState;

@end

@implementation HHBluetoothPrinterManager

#define Printer169ServiceUUID @"49535343-FE7D-4AE5-8FA9-9FAFD205E455"
#define Printer200ServiceUUID @"E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"

/**
 *  单例方法
 *
 *  @return 实例对象
 */
+ (instancetype)sharedManager {
    static HHBluetoothPrinterManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HHBluetoothPrinterManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return self;
}

#pragma makr - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    self.centralState = central.state;
    if ([self.delegate respondsToSelector:@selector(centralManagerDidUpdateState:)]) {
        [self.delegate centralManagerDidUpdateState:central];
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    self.centralState = central.state;
    if ([self.delegate respondsToSelector:@selector(centralManagerDidUpdateState:)]) {
        [self.delegate centralManagerDidUpdateState:central];
    }
}

/**
 *  扫描到新的蓝牙设备
 *
 *  @param central           中心设备
 *  @param peripheral        外设
 *  @param advertisementData 广播数据
 *  @param RSSI              信号质量
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([self.delegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:)]) {
        [self.delegate centralManager:central didDiscoverPeripheral:peripheral];
    }
}
/**
 *  连接到新的蓝牙设备
 *
 *  @param central    中心管理
 *  @param peripheral 蓝牙设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"ok");//链接成功
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

/**
 *  连接蓝牙设备失败
 *
 *  @param central    中心管理
 *  @param peripheral 蓝牙设备
 *  @param error      错误
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)]) {
        [self.delegate centralManager:central didFailToConnectPeripheral:peripheral error:error];
    };
    
    [self clearConnectData];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"didDicoverService");
    if (error) {
        NSLog(@"连接服务:%@ 发生错误:%@",peripheral.name,[error localizedDescription]);
        return;
    }
    
    for (CBService* service in  peripheral.services) {
        NSLog(@"扫描到的serviceUUID:%@",service.UUID);
        //这里其实三个服务都可以做打印，但是我只选择了其中一个
        if ([service.UUID isEqual:[CBUUID UUIDWithString:Printer200ServiceUUID]]) {
            //扫描特征
            //self.connectedService = service;
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

//扫描出特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"扫描特征:%@错误描述:%@",service.UUID,[error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        if (characteristic.properties & CBCharacteristicPropertyWrite ) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            self.connectedPeripheral = peripheral;
            self.connectedService = service;
            self.connectedCharacteristic = characteristic;
            [self.centralManager stopScan];
        }
    }
}

/*
 Invoked upon completion of a -[setNotifyValue:forCharacteristic:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating notification state for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    
    NSLog(@"Updated notification state for characteristic %@ (newState:%@)", characteristic.UUID, [characteristic isNotifying] ? @"Notifying" : @"Not Notifying");
    
    
}

#pragma mark - 接口方法
- (void)scanPeripherals
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerOptionShowPowerAlertKey, nil];
    [self.centralManager scanForPeripheralsWithServices:nil options:options];
}

- (void)cancelScan
{
    [self.centralManager stopScan];
}
- (void)duankai:(CBPeripheral *)peripheral{
    
    [self.centralManager cancelPeripheralConnection:peripheral];
}
- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    [self.centralManager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
 
}

- (void)printData:(NSData *)writeData
{
    if (self.connectedPeripheral && self.connectedCharacteristic) {
        [self startPrint:self.connectedPeripheral writeValue:writeData forCharacteristic:self.connectedCharacteristic type:CBCharacteristicWriteWithResponse];
        return;
    }
}

/**
 *  写数据
 *
 *  @param peripheral
 *  @param valData
 *  @param characteristic
 *  @param type
 */
- (void)startPrint:(CBPeripheral *)peripheral writeValue:(NSData *)valData forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type
{
    [peripheral writeValue:valData forCharacteristic:characteristic type:type];
}

- (void)setupPrinterState:(HHBluePrinterState)state
{
    
    //    final byte[][] byteCommands = {{0x1b, 0x40},// 复位打印机
    //
    //        {0x1b, 0x4d, 0x00},// 标准ASCII字体
    //
    //        {0x1b, 0x4d, 0x01},// 压缩ASCII字体
    //        {0x1d, 0x21, 0x00},// 字体不放大
    //        {0x1d, 0x21, 0x11},// 宽高加倍
    //        {0x1b, 0x45, 0x00},// 取消加粗模式
    //        {0x1b, 0x45, 0x01},// 选择加粗模式
    //        {0x1b, 0x7b, 0x00},// 取消倒置打印
    //        {0x1b, 0x7b, 0x01},// 选择倒置打印
    //        {0x1d, 0x42, 0x00},// 取消黑白反显
    //        {0x1d, 0x42, 0x01},// 选择黑白反显
    //        {0x1b, 0x56, 0x00},// 取消顺时针旋转90°
    //        {0x1b, 0x56, 0x01},// 选择顺时针旋转90°
    //    };
    
    unsigned char* cData = (unsigned char *)calloc(100, sizeof(unsigned char));
    NSData* sendData = nil;
    switch (state) {
        case HHBluePrinterStateInitialize:
            cData[0] = 0x1b;
            cData[1] = 0x40;
            sendData = [NSData dataWithBytes:cData length:2];
            break;
        case HHBluePrinterStateSetLanage:
        {
            //选中中文指令集
            cData[0] = 0x1b;
            cData[1] = 0x74;
            cData[2] = 15;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case HHBluePrinterStateSetLanagehan:
        {
            //选中中文指令集
            cData[0] = 0x1c;
            cData[1] = 0x26;
            sendData = [NSData dataWithBytes:cData length:2];
        }
            break;

        case HHBluePrinterStateSetDefultLineSpace:
        {
            cData[0] = 0x1B;
            cData[1] = 0x32;
            sendData = [NSData dataWithBytes:cData length:2];
        }
            break;
        case HHBluePrinterStateSetFontSizeBig:
        {
            cData[0] = 0x1D;
            cData[1] = 0x21;
            cData[2] = 0x11;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case HHBluePrinterStateSetFontDefult:
        {
            cData[0] = 0x1D;
            cData[1] = 0x21;
            cData[2] = 0x00;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case HHBluePrinterStateAlignmentCenter:
        {
            cData[0] = 0x1B;
            cData[1] = 0x61;
            cData[2] = 0x49;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case HHBluePrinterStateAlignmentLeft:
        {
            cData[0] = 0x1B;
            cData[1] = 0x61;
            cData[2] = 0;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case HHBluePrinterStateSetLineSpace:
        {
            cData[0] = 0x1B;
            cData[1] = 0x33;
            cData[2] = 15 * 8;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case HHBluePrinterStateSetFontHeightBig:
        {
            cData[0] = 0x1B;
            cData[1] = 0x21;
            cData[2] = 16;
            sendData = [NSData dataWithBytes:cData length:3];
        }
        case HHBluePrinterStateSeterweima:
        {
            cData[0] = 0x1D;
            cData[1] = 0x28;
            cData[2] = 0x6B;
            cData[3] = 0x3;
            cData[4] = 0x0;
            cData[5] = 0x31;
            cData[6] = 0x51;
            cData[7] = 0x30;
            sendData = [NSData dataWithBytes:cData length:8];
        }
        case HHBluePrinterStateSeterwe:
        {
            
            cData[0] = 0x1D;
            cData[1] = 0x28;
            cData[2] = 0x6B;
            cData[3] = 0x3;
            cData[4] = 0x0;
            cData[5] = 0x31;
            cData[6] = 0x50;
            cData[7] = 0x30;
            cData[8] =0x79656461;
            sendData = [NSData dataWithBytes:cData length:9];
        }
        case HHBluePrinterStateSeterw:
        {
            
            cData[0] = 0x1D;
            cData[1] = 0x6B;
            cData[2] = 0x30;
            cData[3] = 0x0;
            cData[4] =0xd1d29;
            sendData = [NSData dataWithBytes:cData length:5];
        }

        default:
            break;
    }
    free(cData);
    [self startPrint:sendData];
}

- (void)startPrint:(NSData *)writeData
{
    if (self.connectedPeripheral && self.connectedCharacteristic) {
        [self startPrint:self.connectedPeripheral writeValue:writeData forCharacteristic:self.connectedCharacteristic type:CBCharacteristicWriteWithResponse];
        return;
    }
}


- (void)clearConnectData {
    [self.centralManager stopScan];
    self.connectedPeripheral = nil;
    self.connectedService = nil;
}


@end
