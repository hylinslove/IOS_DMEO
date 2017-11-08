//
//  CameraViewController.m
//  landExamination
//
//  Created by xianglong on 2017/10/24.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "BaiduMapAPI.h"
#import "HCImage.h"
#import "DLRadioButton.h"

@interface CameraViewController ()<UIGestureRecognizerDelegate,BMKLocationServiceDelegate>
- (IBAction)isCompresscAction:(id)sender;

- (IBAction)switchCamera:(id)sender;
- (IBAction)switchFlash:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)captureAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *backView;
//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession* session;
//输入设备
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
//照片输出流
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
//预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
//记录开始的缩放比例
@property(nonatomic,assign)CGFloat beginGestureScale;
//最后的缩放比例
@property(nonatomic,assign)CGFloat effectiveScale;
//定位服务
@property (strong, nonatomic) BMKLocationService *locService;
@property (weak, nonatomic) IBOutlet DLRadioButton *radioBtn;
@property (weak, nonatomic) IBOutlet UIImageView *snailImage;
@end

@implementation CameraViewController{
    BOOL isUsingFrontFacingCamera;
    BOOL isCompress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _locService = [[BMKLocationService alloc] init];
    
    isUsingFrontFacingCamera = NO;
    isCompress = YES;
    
    [self initCaptureSession];
    [self setUpGesture];
    self.effectiveScale = self.beginGestureScale = 1.0f;
}


-(void)initCaptureSession{
    self.session = [[AVCaptureSession alloc]init];
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGSize size = rect.size;
    
    CGFloat width = size.width;
    
    CGFloat height = size.height;
    self.previewLayer.frame = CGRectMake(0, 0,width, height - 130);
    self.backView.layer.masksToBounds = YES;
    [self.backView.layer addSublayer:self.previewLayer];
    

    
}



- (IBAction)isCompresscAction:(id)sender {
    if(isCompress == YES) {
        _radioBtn.selected = NO;
        isCompress = NO;
    }else {
        _radioBtn.selected = YES;
        isCompress = YES;
    }
}

- (IBAction)switchCamera:(id)sender {
    
    AVCaptureDevicePosition desiredPosition;
    if (isUsingFrontFacingCamera){
        desiredPosition = AVCaptureDevicePositionBack;
    }else{
        desiredPosition = AVCaptureDevicePositionFront;
    }
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [self.previewLayer.session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in self.previewLayer.session.inputs) {
                [[self.previewLayer session] removeInput:oldInput];
            }
            [self.previewLayer.session addInput:input];
            [self.previewLayer.session commitConfiguration];
            break;
        }
    }
    
    isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
}

- (IBAction)switchFlash:(id)sender {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //修改前必须先锁定
    [device lockForConfiguration:nil];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([device hasFlash]) {
        UIButton *button = sender;
        if (device.flashMode == AVCaptureFlashModeOff) {
            device.flashMode = AVCaptureFlashModeOn;
            [button setTitle:@"On" forState:UIControlStateNormal];
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeAuto;
            [button setTitle:@"Auto" forState:UIControlStateNormal];
        } else if (device.flashMode == AVCaptureFlashModeAuto) {
            device.flashMode = AVCaptureFlashModeOff;
            [button setTitle:@"Off" forState:UIControlStateNormal];
        }
        
    } else {
        
        NSLog(@"设备不支持闪光灯");
    }
    [device unlockForConfiguration];
}
//返回
- (IBAction)backAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
//拍照
- (IBAction)captureAction:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyMMdd_hhmmss"];
    
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput        connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        //停止预览
        [self stopSession];
        
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        UIImage *selectedImg = [UIImage imageWithData:jpegData];
        
        NSString *locationStr = [NSString stringWithFormat:@"经度:%f\n纬度:%f\n方位角:%f",_locService.userLocation.location.coordinate.longitude,_locService.userLocation.location.coordinate.latitude,_locService.userLocation.heading.trueHeading];
        
        selectedImg = [self addText:selectedImg text:locationStr];
        
        
        //使用hcimage保存图片和位置信息
        HCImage *hcImage = [[HCImage alloc]init];
        hcImage.image = selectedImg;
        hcImage.longitude = [NSString stringWithFormat:@"%f",_locService.userLocation.location.coordinate.longitude];
        hcImage.latitude = [NSString stringWithFormat:@"%f",_locService.userLocation.location.coordinate.latitude];
        hcImage.fxj = [NSString stringWithFormat:@"%.2f",_locService.userLocation.heading.trueHeading];
        
        NSLog(@"经度：%f ，纬度： %f ，方位角：%f",_locService.userLocation.location.coordinate.longitude,_locService.userLocation.location.coordinate.latitude,_locService.userLocation.heading.trueHeading);
        
        //保存图片至本地文件夹
        hcImage.date = [NSDate date];
        NSData *data;
        if (isCompress) {
            data = UIImageJPEGRepresentation(selectedImg, 0.2);
        }else{
            data = UIImageJPEGRepresentation(selectedImg, 1);
        }
        
        NSMutableString *outPath = [NSMutableString string];
        NSString *dirDoc = [self dirDoc];
        NSString *path = [dirDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@@%@@%@@%@@FWJ%@",self.taskID,self.taskID,[dateFormatter stringFromDate:hcImage.date],hcImage.longitude,hcImage.latitude,hcImage.fxj]];
        [outPath appendString:path];
        if(_photoType == 1) {
            
            [outPath appendString:@"@zuozhen"];
        }
        [outPath appendString:@".jpg"];
        
        if ([data writeToFile:outPath atomically:YES] == YES ) {
            NSLog(@"保存路径：----------------——%@",outPath);
        } else {
            NSLog(@"保存路径：----------------——保存失败");
        }
        
        UIImage *image = [UIImage imageWithData:data];
        _snailImage.image = image;
   
        [self startSession];
    }];
    
}

//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.backView];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
    
}

//相机聚焦
- (void)focusAtPoint{
    CGPoint point = CGPointMake(0.5f, 0.5f);
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device.isFocusPointOfInterestSupported &&[device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            NSLog(@"--------聚焦--------------");
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        else{
            NSLog(@"--------聚焦--------------%@",error);
        }
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

#pragma 创建手势
- (void)setUpGesture{
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAtPoint)];
  
    
    tap.delegate = self;
    
    [self.backView addGestureRecognizer:pinch];
    [self.backView addGestureRecognizer:tap];
}
//设备方向
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    if (self.session) {
        
        [self.session startRunning];
    }
    _locService.delegate = self;
    //启动bmkmap定位服务
    [_locService startUserLocationService];
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    
    if (self.session) {
        
        [self.session stopRunning];
    }
}
//添加图片水印
-(UIImage *)addText:(UIImage *)img text:(NSString *)text1
{
    //get image width and height
    NSString* mark = text1;
    int w = img.size.width;
    int h = img.size.height;
    
    //    UIGraphicsBeginImageContext(img.size);
    UIGraphicsBeginImageContextWithOptions(img.size, YES, 1);
    [img drawInRect:CGRectMake(0,0, w, h)];
    
    NSDictionary *attr = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:64],  //设置字体
                           NSForegroundColorAttributeName : [UIColor redColor]   //设置字体颜色
                           };
    
    [mark drawInRect:CGRectMake(20,64,w,300) withAttributes:attr];
    
    UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:UIImageJPEGRepresentation(aimg, 0.8)];
    
}
//开始预览
- (void)startSession{
    
    if (![self.session isRunning]) {
        
        [self.session startRunning];
    }
}
//停止预览
- (void)stopSession{
    
    if ([self.session isRunning]) {
        
        [self.session stopRunning];
    }
}
//获取Documents目录
-(NSString *)dirDoc{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
