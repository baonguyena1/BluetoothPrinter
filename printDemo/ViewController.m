//
//  ViewController.m
//  printDemo
//
//  Created by  夜晚太黑 on 16/4/26.
//  Copyright © 2016年  夜晚太黑. All rights reserved.
//

#import "ViewController.h"
#import "HHBluetoothPrinterManager.h"
#import "UIImage+Splitting.h"
#import "UIImage+Compress.h"
#import "HHPrinterFormat.h"

static int p0[2] = {0, 128};
static int p1[2] = {0, 64};
static int p2[2] = {0, 32};
static int p3[2] = {0, 16};
static int p4[2] = {0, 8};
static int p5[2] = {0, 4};
static int p6[2] = {0, 2};

@interface ViewController ()<HHBluetoothPrinterManagerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    HHBluetoothPrinterManager *manager;
    //选中的设备
    CBPeripheral *selectedPeripheral;
    NSMutableArray *dataArray1;
    NSMutableArray *sendDataArray;
    UITableView *table;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    sendDataArray= [[NSMutableArray alloc]init];
    manager = [HHBluetoothPrinterManager sharedManager];
    manager.delegate = self;
    dataArray1 = [[NSMutableArray alloc] init];//初始化
    [NSTimer scheduledTimerWithTimeInterval:(float)0.02 target:self selector:@selector(sendDataTimer:) userInfo:nil repeats:YES];
    UIButton *scan= [[UIButton alloc]initWithFrame:CGRectMake(20, 20, 200, 40)];
    scan.backgroundColor = [UIColor redColor];
    [scan setTitle:@"Start scanning" forState:UIControlStateNormal];
    [scan addTarget:self action:@selector(scanStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scan];
    UIButton *stop= [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+20, 20, 200, 40)];
    stop.backgroundColor = [UIColor redColor];
    [stop setTitle:@"Stop scanning" forState:UIControlStateNormal];
    [stop addTarget:self action:@selector(scanStop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stop];
    UIButton *dayin= [[UIButton alloc]initWithFrame:CGRectMake(20, 80, 200, 40)];
    dayin.backgroundColor = [UIColor redColor];
    [dayin setTitle:@"Start printing" forState:UIControlStateNormal];
    [dayin addTarget:self action:@selector(dayinStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dayin];
    UIButton *duankai= [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+20, 80, 200, 40)];
    duankai.backgroundColor = [UIColor redColor];
    [duankai setTitle:@"Disconnect the printer" forState:UIControlStateNormal];
    [duankai addTarget:self action:@selector(duankaiStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:duankai];
    UIButton *erweima= [[UIButton alloc]initWithFrame:CGRectMake(20, 140, 200, 40)];
    erweima.backgroundColor = [UIColor redColor];
    [erweima setTitle:@"QR code" forState:UIControlStateNormal];
    [erweima addTarget:self action:@selector(erweimaStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:erweima];

    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 190, self.view.frame.size.width, self.view.frame.size.height-100)];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray1.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    CBPeripheral *peripheral = [dataArray1 objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    
    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedPeripheral = [dataArray1 objectAtIndex:indexPath.row];
    [manager connectPeripheral:[dataArray1 objectAtIndex:indexPath.row]];

}

- (void)duankaiStart{//断开
    [manager cancelScan];
    [manager duankai:selectedPeripheral];
}

- (void)scanStop{//停止扫描
    [manager cancelScan];
}
- (void)scanStart{//开始扫描
    [manager scanPeripherals];
}
- (void) didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"did Connect Peripheral");
    
    NSLog(@"ok");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral {//扫描到的设备
    [dataArray1 addObject:peripheral];
    [table reloadData];
    
}
- (void) sendDataTimer:(NSTimer *)timer {//发送打印数据
//    NSLog(@"send data timer");
    
    if ([sendDataArray count] > 0) {
        NSLog(@"send data timer %d", sendDataArray.count);
        NSData* cmdData;
        cmdData = [sendDataArray objectAtIndex:0];
        [manager startPrint:cmdData];
        [sendDataArray removeObjectAtIndex:0];
    }
}
- (void)jinga{
    unsigned char* cData = (unsigned char *)calloc(100, sizeof(unsigned char));
    NSData* sendData = nil;
    //选中中文指令集
    cData[0] = 0x1b;
    cData[1] = 0x74;
    cData[2] = 15;
    sendData = [NSData dataWithBytes:cData length:3];
    
    free(cData);
    [sendDataArray addObject:sendData];
    
}
- (void)jingb{
    unsigned char* cData = (unsigned char *)calloc(100, sizeof(unsigned char));
    NSData* sendData = nil;
    //选中中文指令集
    cData[0] = 0x1c;
    cData[1] = 0x26;
    sendData = [NSData dataWithBytes:cData length:2];
    free(cData);
    [sendDataArray addObject:sendData];
    
}

- (void)dayinStart{//打印
    [self printImageWithName:@"qa-code"];
//    [self printBill];
    
//    [self printerInit];
//    [self jingb];
//    [self jinga];
//
//    [self printerWithFormat:Align_Center CharZoom:Char_Zoom_2 Content:@"班友点餐宝\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"--------------------------------\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"订单编号：OD2016217115200045\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"门店：湖东店\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"电话：0512-62552546\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"地址：湖东邻里中心Z125室\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"操作员：admin\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"订单信息：\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"订单属性：外卖\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:[NSString stringWithFormat: @"订单来源：%@\n",@"门店"]];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"--------------------------------\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"商品详情：\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"名字      数量       金额\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"--------------------------------\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Zoom_2 Content:[NSString stringWithFormat: @"实付金额：%@\n",@"100.00"]];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"--------------------------------\n\n"];
//    NSDateFormatter *dataFormat = [[NSDateFormatter alloc] init];
//    [dataFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString* displayTime = nil;
//    NSDate *date = [NSDate date];
//    displayTime = [dataFormat stringFromDate:date];
//    [self printerWithFormat:Align_Center CharZoom:Char_Normal Content:@"感谢您的惠顾，欢迎下次光临\n"];
//    [self printerWithFormat:Align_Center CharZoom:Char_Normal Content:[NSString stringWithFormat: @"打印时间：   %@\n",displayTime]];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"\n"];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"\n"];
//    [self printerInit];
    
}

- (void)printBill {
//    [self printImageWithName:@"logo"];
//    [self printerInit];
//    HHPrinterFormat *format = [[HHPrinterFormat alloc] init];
//    NSString *title = [format printTitle:@"Receipt printer GetZ branch"];
//    [self printerWithFormat:Align_Center CharZoom:Char_Zoom_4 Content:title];
//    NSDictionary *menuDic = @{
//                               @"Total Discount": @"-SGD 1.87",
//                               @"Subtotal": @"SGD 26.67",
//                               @"Misc Fee": @"SGD 18.44",
//                               @"GST": @"SGD 3.03",
//                               @"Round Amt": @"-SGD 0.02"
//                               };
//    [self printerWithFormat:Align_Left
//                   CharZoom:Char_Normal
//                    Content:[format printPriceMsg:menuDic isHead:NO]];
//    NSString *menu = [format printMenu:@"3" title:@"hamburger (and chéeburgers and bacon chéebủgers)" price:@"SGD 14.67" isHead:YES];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:menu];
//    NSDictionary *mainMenu = @{
//                               @"1": menuDic
//                               };
//    NSString *menu = [format printMenuMsg:mainMenu isHead:YES];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:menu];
//
//    NSDictionary *addressDic = @{
//                                 @"Payment Mode": @"",
//                                 @"GetPay - Visa/Master (Online)": @"SGD 46.25",
//                                 @"GetzPay transaction ID": @"CCDD09033333",
//                                 @"Merchant Reference ID": @"TR8493898989899",
//                                 @"Order Time": @"09/09/2017 00:00AM"
//                                 };
//    NSString *address = [format printAddressMsg:addressDic isHead:YES];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:address];
//
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:menu];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:menu];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:menu];
//    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:menu];
//
//    [self printerInit];
    [self printImageWithName:@"re"];
//
//    NSUInteger len = 3;
//    Byte enter[len];
//    memset(enter, '\n', len);
//    NSData *data = [[NSData alloc] initWithBytes:enter length:len];
//    [self printData:data];
//    UIImage *printerImage = [UIImage imageNamed:@"logo"];
//    [self POS_PrintBMP:printerImage width:WIDTH_58 mode:0];
}

- (void)printImageWithName:(NSString *)imageName {
    UIImage *printimage = [UIImage imageNamed:imageName];
    if (printimage == nil) {
        return;
    }
    UIImage *resizeImage = [self resizeImage:printimage
                                 withQuality:kCGInterpolationHigh
                                        rate:10.0];
    UIImage *gray = [self toGrayScale:resizeImage];
    UIImage *scaleImage = [self scaleWithFixedWidth:WIDTH_58 image:gray];
    NSUInteger rows = (int)scaleImage.size.height % MAX_HEIGHT_SUB_IMAGE ? scaleImage.size.height / MAX_HEIGHT_SUB_IMAGE + 1 : scaleImage.size.height / MAX_HEIGHT_SUB_IMAGE;
    NSArray *subImages = [scaleImage splitImagesIntoSubImagesWithNumberOfRows:rows numberOfColumns:1];
    for (UIImage *image in subImages) {
        NSLog(@"--> %@", image);
        [self toGrayAndPrint:image];
    }
    Byte controlData[3];
    memset(controlData, '\n', 3);
    NSData *printData = [[NSData alloc] initWithBytes:controlData length:3];
    [self printData:printData];
}

- (void)erweimaStart{//二维码
    UIImage *printimage = [UIImage imageNamed:@"re"];
    UIImage *scaleImage = [self scaleWithFixedWidth:WIDTH_58 image:printimage];
    
    NSUInteger rows = (int)scaleImage.size.height % MAX_HEIGHT_SUB_IMAGE ? scaleImage.size.height / MAX_HEIGHT_SUB_IMAGE + 1 : scaleImage.size.height / MAX_HEIGHT_SUB_IMAGE;
    NSArray *subImages = [scaleImage splitImagesIntoSubImagesWithNumberOfRows:rows numberOfColumns:1];
    for (UIImage *image in subImages) {
        NSLog(@"--> %@", image);
        [self toGrayAndPrint:image];
    }
    
    Byte controlData[8];
    memset(controlData, '\n', 8);
    NSData *printData = [[NSData alloc] initWithBytes:controlData length:3];
    [self printData:printData];
    
}

- (UIImage *) png2GrayscaleImage:(UIImage *) oriImage {
    //const int ALPHA = 0;
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    int width = oriImage.size.width ;//imageRect.size.width;
    int height =oriImage.size.height;
    int imgSize = width * height;
    int x_origin = 0;
    int y_to = height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(imgSize * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, imgSize * sizeof(uint32_t));
    
    NSInteger nWidthByteSize = (width+7)/8;
    
    NSInteger nBinaryImgDataSize = nWidthByteSize * y_to;
    Byte *binaryImgData = (Byte *)malloc(nBinaryImgDataSize);
    
    memset(binaryImgData, 0, nBinaryImgDataSize);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 width,
                                                 height,
                                                 8,
                                                 width * sizeof(uint32_t),
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width , height), [oriImage CGImage]);
    
    Byte controlData[8];
    controlData[0] = 0x1d;// Gs
    controlData[1] = 0x76;//'v';
    controlData[2] = 0x30;//0
    controlData[3] = 0;
    controlData[4] = nWidthByteSize & 0xff;
    controlData[5] = (nWidthByteSize>>8) & 0xff;
    controlData[6] = y_to & 0xff;
    controlData[7] = (y_to>>8) & 0xff;
    NSData *printData = [[NSData alloc] initWithBytes:controlData length:8];
    [self printData:printData];
    
    for(int y = 0; y < y_to; y++) {
        for(int x = x_origin; x < width ; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
//             rgbaPixel[RED] = gray;
//             rgbaPixel[GREEN] = gray;
//             rgbaPixel[BLUE] = gray;
            
            if (gray > 228) {
                rgbaPixel[RED] = 255;
                rgbaPixel[GREEN] = 255;
                rgbaPixel[BLUE] = 255;
                
            } else {
                rgbaPixel[RED] = 0;
                rgbaPixel[GREEN] = 0;
                rgbaPixel[BLUE] = 0;
                binaryImgData[(y*width+x)/8] |= (0x80>>(x%8));
            }
        }
    }
    
    printData = [[NSData alloc] initWithBytes:binaryImgData length:nBinaryImgDataSize];
    [self printData:printData];

//    memset(controlData, '\n', 8);
//    printData = [[NSData alloc] initWithBytes:controlData length:3];
//    [self printData:printData];
    
    return 0;
}

- (UIImage *)toGrayAndPrint:(UIImage *)oriImage {
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    int width = oriImage.size.width;
    int height = oriImage.size.height;
    int imgSize = width * height;
    int x_origin = 0;
    int y_to = height;
    
    /**
     GET PIXEL FROM IMAGE
     */
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(imgSize * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, imgSize * sizeof(uint32_t));
    
    NSInteger nWidthByteSize = (width+7)/8;
    
    NSInteger nBinaryImgDataSize = nWidthByteSize * y_to;
    Byte *binaryImgData = (Byte *)malloc(sizeof(Byte) * nBinaryImgDataSize);
    
    memset(binaryImgData, 0, nBinaryImgDataSize);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width , height), [oriImage CGImage]);
    
    /**
     SEND SIGNAL PRINT IMAGE TO PRINTER
     */
    Byte *SET_BIT_IMAGE_MODE = (Byte *)malloc(8 + nBinaryImgDataSize);
    SET_BIT_IMAGE_MODE[0] = 0x1d;
    SET_BIT_IMAGE_MODE[1] = 0x76;//'v';
    SET_BIT_IMAGE_MODE[2] = 0x30;
    SET_BIT_IMAGE_MODE[3] = (Byte)0;
    SET_BIT_IMAGE_MODE[4] = (Byte)(nWidthByteSize & 0xff);
    SET_BIT_IMAGE_MODE[5] = (Byte)((nWidthByteSize>>8) & 0xff);
    SET_BIT_IMAGE_MODE[6] = (Byte)(y_to & 0xff);
    SET_BIT_IMAGE_MODE[7] = (Byte)((y_to>>8) & 0xff);
    
    NSData *printData = [[NSData alloc] initWithBytes:SET_BIT_IMAGE_MODE length:8];
    [self printData:printData];
    
    for(int y = 0; y < y_to; y++) {
        for(int x = x_origin; x < width ; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];

            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];

            if (gray > 127) {
                rgbaPixel[RED] = 255;
                rgbaPixel[GREEN] = 255;
                rgbaPixel[BLUE] = 255;

            } else {
                rgbaPixel[RED] = 0;
                rgbaPixel[GREEN] = 0;
                rgbaPixel[BLUE] = 0;
                binaryImgData[(y*width+x)/8] |= (0x80>>(x%8));
            }
        }
    }
    for (int  i = 0; i<nBinaryImgDataSize; i++) {
        SET_BIT_IMAGE_MODE[8+i] = *(binaryImgData+i);
    }
    /**
     PRINT IMAGE
     */
    NSData *data = [[NSData alloc] initWithBytes:SET_BIT_IMAGE_MODE length:8 + nBinaryImgDataSize];
    [self printData:data];
    
    free(pixels);
    free(binaryImgData);
    free(SET_BIT_IMAGE_MODE);
    pixels = NULL;
    binaryImgData = NULL;
    SET_BIT_IMAGE_MODE = NULL;
    return 0;
}

- (void)printData:(NSData *)dataPrinted {
    [sendDataArray addObject:dataPrinted];
//    NSUInteger strLength;
//    NSUInteger cellCount;
//    NSUInteger cellMin;
//    NSUInteger cellLen;
//
//    strLength = [dataPrinted length];
//    if (strLength < 1) {
//        return;
//    }
//    cellCount = (strLength % MAX_CHARACTERISTIC_VALUE_SIZE) ? (strLength / MAX_CHARACTERISTIC_VALUE_SIZE + 1) : (strLength / MAX_CHARACTERISTIC_VALUE_SIZE);
//    for (NSUInteger i = 0; i < cellCount; i++) {
//        cellMin = i*MAX_CHARACTERISTIC_VALUE_SIZE;
//        if (cellMin + MAX_CHARACTERISTIC_VALUE_SIZE > strLength) {
//            cellLen = strLength-cellMin;
//        } else {
//            cellLen = MAX_CHARACTERISTIC_VALUE_SIZE;
//        }
////        NSLog(@"print:%lu,%lu,%lu,%lu", (unsigned long)strLength, (unsigned long)cellCount, (unsigned long)cellMin, (unsigned long)cellLen);
//        NSRange rang = NSMakeRange(cellMin, cellLen);
//
//        NSData *subData = [dataPrinted subdataWithRange:rang];
//        [sendDataArray addObject:subData];
//    }
}

- (UIImage *)createQRForString:(NSString *)qrString {
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setDefaults];
    
    NSData *data = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    [filter setValue:data
              forKey:@"inputMessage"];
    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:0.1
                                   orientation:UIImageOrientationUp];
    
    // 不失真的放大
    UIImage *resized = [self resizeImage:image
                             withQuality:kCGInterpolationNone
                                    rate:10.0];
    
    // 缩放到固定的宽度(高度与宽度一致)
    UIImage * endImage = [self scaleWithFixedWidth:200 image:resized];
    
    CGImageRelease(cgImage);
    
    return endImage;
    
}
- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
    UIImage *resized = nil;
    CGFloat width = image.size.width * rate;
    CGFloat height = image.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}
- (UIImage *)scaleWithFixedWidth:(CGFloat)width image:(UIImage *)image {
    float newHeight = image.size.height * (width / image.size.width);
    CGSize size = CGSizeMake(width, newHeight);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}

- (void) printerWithFormat:(Align_Type_e)eAlignType CharZoom:(Char_Zoom_Num_e)eCharZoomNum Content:(NSString *)printContent{
    NSData  *data	= nil;
    NSUInteger strLength;
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    Byte caPrintFmt[500];
    
    /*初始化命令：ESC @ 即0x1b,0x40*/
    //caPrintFmt[0] = 0x1b;
    //caPrintFmt[1] = 0x40;
    
    /*字符设置命令：ESC ! n即0x1b,0x21,n*/
    caPrintFmt[0] = 0x1d;
    caPrintFmt[1] = 0x21;
    caPrintFmt[2] = (eCharZoomNum<<4) | eCharZoomNum;
    caPrintFmt[3] = 0x1b;
    caPrintFmt[4] = 0x61;
    caPrintFmt[5] = eAlignType;
    NSData *printData = [printContent dataUsingEncoding: enc];
    Byte *printByte = (Byte *)[printData bytes];
    
    strLength = [printData length];
    if (strLength < 1) {
        return;
    }
    
    for (int  i = 0; i<strLength; i++) {
        caPrintFmt[6+i] = *(printByte+i);
    }
    
    data = [NSData dataWithBytes:caPrintFmt length:6+strLength];
    
    [self printLongData:data];
//    [self printData:data];
}


- (void) printLongData:(NSData *)printContent{
    NSUInteger i;
    NSUInteger strLength;
    NSUInteger cellCount;
    NSUInteger cellMin;
    NSUInteger cellLen;
    
    strLength = [printContent length];
    if (strLength < 1) {
        return;
    }
    
    cellCount = (strLength%MAX_CHARACTERISTIC_VALUE_SIZE)?(strLength/MAX_CHARACTERISTIC_VALUE_SIZE + 1):(strLength/MAX_CHARACTERISTIC_VALUE_SIZE);
    for (i=0; i<cellCount; i++) {
        cellMin = i*MAX_CHARACTERISTIC_VALUE_SIZE;
        if (cellMin + MAX_CHARACTERISTIC_VALUE_SIZE > strLength) {
            cellLen = strLength-cellMin;
        }
        else {
            cellLen = MAX_CHARACTERISTIC_VALUE_SIZE;
        }
        
        NSRange rang = NSMakeRange(cellMin, cellLen);
        NSData *subData = [printContent subdataWithRange:rang];
        
        NSLog(@"print:%@", subData);
        [sendDataArray addObject:subData];
    }
}
- (void) printerInit{
    NSData *printFormat;
    Byte caPrintFmt[20];
    
    caPrintFmt[0] = 0x1b;
    caPrintFmt[1] = 0x40;
    printFormat = [NSData dataWithBytes:caPrintFmt length:2];
    NSLog(@"format:%@", printFormat);
    
    [sendDataArray addObject:printFormat];
    
}

- (void)POS_PrintBMP:(UIImage *)src width:(NSUInteger)nWidth mode:(NSUInteger)nMode {
    NSUInteger width = ((nWidth + 7) / 8) * 8;
    NSUInteger height = ((((src.size.height * width) / src.size.width) + 7) / 8) * 8;
    UIImage *resizeImage = src;
    if (src.size.width != width) {
        resizeImage = [self resizeImage:width height:height image:src];
    }
    UIImage *grayImage = [self toGrayScale:resizeImage];
    Byte *data = [self thresholdToBWPic:grayImage];
    NSUInteger len = grayImage.size.width * grayImage.size.height;
    Byte *bytes = [self eachLinePixToCmd:data srcLen:len width:width mode:nMode];
//    NSData *printData = [[NSData alloc] initWithBytes:bytes length:len];
    
//    Byte ESC_Init[2] = {(Byte)27, (Byte)64 };
//    [manager startPrint:[[NSData alloc] initWithBytes:ESC_Init length:2]];
//    Byte LF[1] = { (Byte)10 };
//    [manager startPrint:[[NSData alloc] initWithBytes:LF length:1]];
    
//    [self printData:printData];
    NSLog(@"DONE--->");
//    free(bytes);
}

/**
 * OTHER
 */
- (Byte *)thresholdToBWPic:(UIImage *)image {
    int width = image.size.width;
    int height = image.size.height;
    int imgSize = width * height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(imgSize * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, imgSize * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
    Byte *data = (Byte *)malloc(sizeof(Byte) * imgSize);
    
    [self format_K_threshold:pixels xsize:width ysize:height despixels:data];
    return data;
}

- (void)format_K_threshold:(uint32_t *)orgpixels xsize:(int)xsize ysize:(int)ysize despixels:(Byte *)despixels {
    int graytotal = 0;
    int k = 0;
    for (int i = 0; i < ysize; i++) {
        for (int j = 0; j < xsize; j++) {
            graytotal += orgpixels[k] & 255;
            k++;
        }
    }
    int grayave = (graytotal / ysize) / xsize;
    k = 0;
    for (int i = 0; i < ysize; i++) {
        for (int j = 0; j < xsize; j++) {
            if ((orgpixels[k] & 255) > grayave) {
                despixels[k] = (Byte) 0;
            } else {
                despixels[k] = (Byte) 1;
            }
            k++;
        }
    }
}

-(Byte *)eachLinePixToCmd:(Byte *)src srcLen:(NSUInteger)nlen width:(NSUInteger)nWidth mode:(NSUInteger)nMode {
    Byte ESC_Init[2] = {(Byte)27, (Byte)64 };
    [self printData:[[NSData alloc] initWithBytes:ESC_Init length:2]];
    Byte LF[1] = { (Byte)10 };
    [self printData:[[NSData alloc] initWithBytes:LF length:1]];
    
    NSUInteger nHeight = nlen / nWidth;
    NSUInteger nBytesPerLine = nWidth / 8;
    
    Byte SELECT_BIT[8];
    SELECT_BIT[0] = (Byte) 29;
    SELECT_BIT[1] = (Byte) 118;
    SELECT_BIT[2] = (Byte) 48;
    SELECT_BIT[3] = (Byte) (nMode & 1);
    SELECT_BIT[4] = (Byte) (nBytesPerLine % 256);
    SELECT_BIT[5] = (Byte) (nBytesPerLine / 256);
    SELECT_BIT[6] = (Byte) 1;
    SELECT_BIT[7] = (Byte) 0;
    [self printData:[[NSData alloc] initWithBytes:SELECT_BIT length:8]];
    Byte *data = (Byte *)malloc(sizeof(Byte) * ((nBytesPerLine + 8) * nHeight) );
    int k = 0;
    for (int i = 0; i < nHeight; i++) {
        Byte data[nBytesPerLine];
        NSUInteger offset = i * (nBytesPerLine + 8);
        data[offset + 0] = (Byte) 29;
        data[offset + 1] = (Byte) 118;
        data[offset + 2] = (Byte) 48;
        data[offset + 3] = (Byte) (nMode & 1);
        data[offset + 4] = (Byte) (nBytesPerLine % 256);
        data[offset + 5] = (Byte) (nBytesPerLine / 256);
        data[offset + 6] = (Byte) 1;
        data[offset + 7] = (Byte) 0;
        for (int j = 0; j < nBytesPerLine; j++) {
            data[(offset + 8) + j] = (Byte) (((((((p0[src[k]] + p1[src[k + 1]]) + p2[src[k + 2]]) + p3[src[k + 3]]) + p4[src[k + 4]]) + p5[src[k + 5]]) + p6[src[k + 6]]) + src[k + 7]);
            k += 8;
        }
//        NSData *printData = [[NSData alloc] initWithBytes:data length:nBytesPerLine];
//        [self printData:printData];
    }
    return data;
}

- (UIImage *)resizeImage:(CGFloat)width height:(CGFloat)height image:(UIImage *)image {
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}

- (UIImage *)toGrayScale:(UIImage *)sourceImage {
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    //Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, sourceImage.size.width * sourceImage.scale, sourceImage.size.height * sourceImage.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [sourceImage CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint8_t gray = (uint8_t) ((30 * rgbaPixel[RED] + 59 * rgbaPixel[GREEN] + 11 * rgbaPixel[BLUE]) / 100);
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:sourceImage.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

@end
