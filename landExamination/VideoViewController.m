//
//  VideoViewController.m
//  landExamination
//
//  Created by xianglong on 2017/10/25.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "VideoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "BaiduMapAPI.h"
#import "KissXML.h"


#define TIMER_INTERVAL 0.05
#define VIDEO_RECORDER_MAX_TIME 10 //视频最大时长 (单位/秒)
#define VIDEO_RECORDER_MIN_TIME 1  //最短视频时长 (单位/秒)

#define KMainScreenW [UIScreen mainScreen].bounds.size.width
#define KMainScreenH [UIScreen mainScreen].bounds.size.height
@interface VideoViewController ()<AVCaptureFileOutputRecordingDelegate,BMKLocationServiceDelegate>
//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession* session;
//视频输入设备
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
//声音输入
@property (nonatomic, strong) AVCaptureDeviceInput* audioInput;
//视频输出流
@property(nonatomic,strong)AVCaptureMovieFileOutput *movieFileOutput;
//预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
//记录录制时间
@property (nonatomic, strong) NSTimer* timer;
//定位服务
@property (strong, nonatomic) BMKLocationService *locService;
@property (strong, nonatomic) NSMutableArray *videoLocArr;
@property (strong, nonatomic) NSMutableString *xmlStr;

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) NSTimer *locRecoder;
@property (weak, nonatomic) IBOutlet UILabel *latLabel;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;

- (IBAction)backAction:(id)sender;
- (IBAction)startAction:(id)sender;

@end

@implementation VideoViewController{
    BOOL isRcording;
    float lat;
    float log;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAVCaptureSession];
    _videoLocArr = [NSMutableArray array];
    _locService = [[BMKLocationService alloc] init];
    isRcording = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//退出视频录制
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startAction:(id)sender {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        
        return;
    }
    
    //判断用户是否允许访问麦克风权限
    authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        //无权限
        
        return;
    }
    
    if(!isRcording) {
        [self startSession];
        [self startVideoRecorder];
        NSLog(@"***************开始****************");
        
        isRcording = YES;
    } else {
        [self stopVideoRecorder];
        NSLog(@"***************结束****************");
        [self stopSession];
        isRcording = NO;
    }
    

}

//视频文件存入相册
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
//    NSLog(@"***************存入相册****************");
//    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
//    [lib writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
//        
//    }];
}



//初始化摄像session
- (void)initAVCaptureSession{
    
    
    self.session = [[AVCaptureSession alloc] init];
    
    //这里根据需要设置  可以设置4K
    self.session.sessionPreset = AVCaptureSessionPreset640x480;
    
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    
    if (error) {
        NSLog(@"%@",error);
    }
    
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    
    if ([self.session canAddInput:self.audioInput]) {
        
        [self.session addInput:self.audioInput];
    }
    
    if ([self.session canAddOutput:self.movieFileOutput]) {
        
        [self.session addOutput:self.movieFileOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGSize size = rect.size;
    
    CGFloat width = size.width;
    
    CGFloat height = size.height;
    self.previewLayer.frame = CGRectMake(0, 0,width, height-130);
    self.backView.layer.masksToBounds = YES;
    [self.backView.layer addSublayer:self.previewLayer];
    
}



- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    [self startSession];
    
    _locService.delegate = self;
    //启动bmkmap定位服务
    [_locService startUserLocationService];
    
    //启动timer采集坐标数据
    if (!_locRecoder) {
        _locRecoder = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(recordLocation) userInfo:nil repeats:YES];
        [_locRecoder fire];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    
    [self stopSession];
    
    
    [_locService stopUserLocationService];
    _locService.delegate = nil;
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

#pragma mark 开始录制和结束录制
- (void)startVideoRecorder{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyMMdd_hhmmss"];
    //保存视频文件夹目录
    NSString *dirDoc = [self dirDoc];
    NSString *mp4DocPath = [dirDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@@%@@%@.MP4",self.taskID,self.taskID,[dateFormatter stringFromDate:[NSDate date]],[_videoLocArr lastObject]]];
    AVCaptureConnection *movieConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    AVCaptureVideoOrientation avcaptureOrientation = AVCaptureVideoOrientationPortrait;
    [movieConnection setVideoOrientation:avcaptureOrientation];
    [movieConnection setVideoScaleAndCropFactor:1.0];
    NSURL *url = [NSURL fileURLWithPath:mp4DocPath];
    [self.movieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];

//    [self timerFired];
    
}


- (void)creatVideoXML{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyy-MM-dd-hh-mm-ss"];
    NSString *locStr = [_videoLocArr firstObject];
    locStr = [locStr stringByReplacingOccurrencesOfString:@"," withString:@"@"];
    
    
    NSString *dirDoc = [self dirDoc];
    NSString *videoXmlPath = [dirDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@@%@@%@.xml",self.taskID,self.taskID,[dateFormatter stringFromDate:[NSDate date]],locStr]];
    
    _xmlStr = [NSMutableString string];
    
    for (NSString *locstr in _videoLocArr) {
        [_xmlStr appendFormat:@"%@;",locstr];
        //        [_xmlStr appendString:locstr];
    }
    
    DDXMLElement *zbs = [DDXMLElement elementWithName:@"zbs" stringValue:_xmlStr];
    DDXMLDocument *zbsDoc = [[DDXMLDocument alloc]initWithXMLString:zbs.XMLString options:0 error:nil];
    [[zbsDoc XMLData] writeToFile:videoXmlPath atomically:YES];
    
    
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //普通态
    //以下_mapView为BMKMapView对象
    
    lat = userLocation.location.coordinate.latitude;
    log = userLocation.location.coordinate.longitude;
    
    _latLabel.text = [NSString stringWithFormat:@"纬度：%f",lat];
    _logLabel.text = [NSString stringWithFormat:@"经度：%f",log];
    
    NSLog(@"经纬度 %f,%f",lat,log);
    
}
//timer记录位置
- (void)recordLocation{
    
    CLLocationCoordinate2D coor = _locService.userLocation.location.coordinate;
    if (_videoLocArr.count > 5 ) {
        [_videoLocArr removeObjectAtIndex:0];
    }
    NSString *locStr = [NSString stringWithFormat:@"%f,%f",coor.latitude,coor.longitude];
    [_videoLocArr addObject:locStr];
}
//获取Documents目录
-(NSString *)dirDoc{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}
- (void)stopVideoRecorder{

    [self.movieFileOutput stopRecording];
//    [self timerStop];
//    [self.progressView hidePopUpViewAnimated:YES];
//    [self.progressView setProgress:0.0 animated:YES];
//    self.progressView.hidden = YES;
    
}


@end
