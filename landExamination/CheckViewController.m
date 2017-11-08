//
//  CheckViewController.m
//  landExamination
//
//  Created by xianglong on 2017/10/9.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "CheckViewController.h"
#import "DLRadioButton.h"
#import "ZQTextView.h"
#import "SQLManager.h"
#import "BaiduMapAPI.h"
#import "TZImagePickerController.h"
#import "ImgPickCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZVideoPlayerController.h"
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import "MacroDefine.h"
#import "KissXML.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <YYCache.h>
#import <MBProgressHUD.h>
#import "SectionHeader.h"
#import "HCImage.h"
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import "MediaViewController.h"
#import "CameraViewController.h"
#import "VideoViewController.h"


@interface CheckViewController ()<UICollectionViewDelegate,BMKLocationServiceDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet DLRadioButton *radioYES;
@property (weak, nonatomic) IBOutlet DLRadioButton *radioNO;
@property (weak, nonatomic) IBOutlet ZQTextView *infoTF;
@property (weak, nonatomic) IBOutlet UITextView *nameTF;
@property (weak, nonatomic) IBOutlet UITextView *timeTextView;
@property (weak, nonatomic) IBOutlet UITextView *sjmjTF;
@property (weak, nonatomic) IBOutlet UITextView *sjnydmjTF;
@property (weak, nonatomic) IBOutlet UITextView *sjgdmjTF;
@property (weak, nonatomic) IBOutlet UITextView *jsjbntTF;
@property (weak, nonatomic) IBOutlet UITextView *sjrkTF;
@property (weak, nonatomic) IBOutlet UITextView *sjjeTF;
@property (weak, nonatomic) IBOutlet ZQTextView *infoTextView;
@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UIButton *paisheBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *mediaBtn;
@property (weak, nonatomic) IBOutlet UIButton *picBtn;
@property (weak, nonatomic) IBOutlet UIButton *eviBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;

@property (strong, nonatomic) NSMutableArray *videoLocArr;
@property (strong, nonatomic) NSTimer *locRecoder;
@property (strong, nonatomic) NSMutableString *xmlStr;
@property (strong, nonatomic) SQLManager *sql;
@property (strong, nonatomic) BMKLocationService *locService;
@property (assign, nonatomic) BOOL isShowAlert;
@property (assign, nonatomic) BOOL isXF;
//保存的信息
@property (strong, nonatomic) NSArray *savedPaths;
@property (strong, nonatomic) NSMutableArray *uploadPaths;

@property (strong, nonatomic) UIImagePickerController *xcPicker;
@property (strong, nonatomic) TZImagePickerController *zzPicker;
@property (strong, nonatomic) NSMutableArray *selectedMP4;//现场核查的视频
@property (strong, nonatomic) NSMutableArray *selectedPhotos;//现场核查选中照片
@property (strong, nonatomic) NSMutableArray *zzSelectedPhotos;//佐证选中照片

@property (assign, nonatomic) NSInteger cellSection;

- (IBAction)areaIsEqual:(id)sender;
- (IBAction)saveTask:(id)sender;
- (IBAction)mediaCollect:(id)sender;
- (IBAction)backToServer:(id)sender;
- (IBAction)seeImage:(id)sender;
- (IBAction)seeEvidence:(id)sender;
- (IBAction)seeVideo:(id)sender;

@end

@implementation CheckViewController{
    NSFileManager *manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //防止导航栏遮挡控件
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _sql = [SQLManager sharedManager];
    
    [self getMissionModelFromSQL];
    
    _locService = [[BMKLocationService alloc] init];
    
    _isXF = YES;
    
//    _saveBtn.alpha = 0.4;
//    _saveBtn.enabled = NO;
    
//    _paisheBtn.alpha = 0.4;
//    _paisheBtn.enabled = NO;
    
      _videoLocArr = [NSMutableArray array];
    NSString *formatStr = @"yyyy年MM月dd日";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatStr];
    _timeTextView.text = [dateFormatter stringFromDate:[NSDate date]];
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //取出填写的数据
        YYCache *cache = [YYCache cacheWithName:@"paths"];
        if ([cache containsObjectForKey:_taskModel.GUID]) {
            
            NSDictionary *cacheDict = (NSDictionary *)[cache objectForKey:_taskModel.GUID];
//            _selectedMP4 = cacheDict[@"videoPath"];
//            _selectedPhotos = cacheDict[@"photos"];
//            _zzSelectedPhotos = cacheDict[@"zzPhoto"];
            _uploadPaths = cacheDict[@"paths"];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cacheDict[@"zgqk"]) {
                    _infoTF.text = cacheDict[@"zgqk"];
                }
                if (cacheDict[@"hcry"]) {
                    _nameTF.text = cacheDict[@"hcry"];
                }
                if (cacheDict[@"hcrq"]) {
                    _timeTextView.text = cacheDict[@"hcrq"];
                }
                if (cacheDict[@"isXF"]) {
                    _radioYES.selected = [cacheDict[@"isXF"] isEqualToString:@"1"]?YES:NO;
                    _radioNO.selected = [cacheDict[@"isXF"] isEqualToString:@"0"]?YES:NO;
                    if(_radioNO.selected == YES) {
                        _sjmjTF.editable = YES;
                        _sjnydmjTF.editable = YES;
                        _sjgdmjTF.editable = YES;
                        _jsjbntTF.editable = YES;
                        _sjjeTF.editable = YES;
                        _sjrkTF.editable = YES;
                    }
                }
                if (cacheDict[@"sjmj"]) {
                    _sjmjTF.text = cacheDict[@"sjmj"];
                }
                if (cacheDict[@"sjnydmj"]) {
                    _sjnydmjTF.text = cacheDict[@"sjnydmj"];
                }
                if (cacheDict[@"sjgdmj"]) {
                    _sjgdmjTF.text = cacheDict[@"sjgdmj"];
                }
                if (cacheDict[@"sjjbnt"]) {
                    _jsjbntTF.text = cacheDict[@"sjjbnt"];
                }
                if (cacheDict[@"sjje"]) {
                    _sjjeTF.text = cacheDict[@"sjje"];
                }
                if (cacheDict[@"sjrk"]) {
                    _sjrkTF.text = cacheDict[@"sjrk"];
                }
            
                [SVProgressHUD dismiss];
            });
        }else{
            [SVProgressHUD dismiss];
        }

        
    });

    _sjmjTF.text = _taskModel.WTSJSJMJ;
    _sjnydmjTF.text = _taskModel.WTSJSJNYD;
    _sjgdmjTF.text = _taskModel.WTSJSJGD;
    _jsjbntTF.text = _taskModel.WTSJSJJBNT;
    _sjjeTF.text = _taskModel.WTSJSJJE;
    _sjrkTF.text = _taskModel.WTSJSJRK;
    
    manager = [NSFileManager defaultManager];
    
    NSString *docPath = [self dirDoc];
    NSString *taskPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",_taskModel.GUID]];
    //判断任务目录是否存在
    if(![manager fileExistsAtPath:taskPath]){
        
        if([[NSFileManager defaultManager] createDirectoryAtPath:taskPath withIntermediateDirectories:YES attributes:nil error:nil]){
            NSLog(@"创建目录成功：-------%@",taskPath);
        } else {
            NSLog(@"创建目录失败：-------");
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self initMedia];
    _locService.delegate = self;
    //启动bmkmap定位服务
    [_locService startUserLocationService];
    //启动timer采集坐标数据
    if (!_locRecoder) {
        _locRecoder = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(recordLocation) userInfo:nil repeats:YES];
        [_locRecoder fire];
    }
    [super viewWillAppear:animated];
}

//初始化多媒体文件
-(void)initMedia{
    _selectedMP4=nil;
    _selectedMP4 = [NSMutableArray array];

    _selectedPhotos=nil;
    _selectedPhotos = [NSMutableArray array];
    
    _zzSelectedPhotos=nil;
    _zzSelectedPhotos = [NSMutableArray array];
    
    _uploadPaths=nil;
    _uploadPaths = [NSMutableArray array];
    
    NSLog(@"************初始化多媒体文件***********");
    NSString *dirDoc = [self dirDoc];
    NSString *mediaPath = [dirDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",_taskModel.GUID]];
    
    NSArray *fileList = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:mediaPath error:nil];
    
    for(NSString *fileName in fileList) {
        
        NSLog(@"file name：------------------- %@",fileName);
        if([fileName containsString:@"zuozhen"]) {
            [_zzSelectedPhotos addObject:[mediaPath stringByAppendingPathComponent:fileName]];
        } else if([fileName hasSuffix:@".jpg"]) {
            [_selectedPhotos addObject:[mediaPath stringByAppendingPathComponent:fileName]];
        } else if([fileName hasSuffix:@".MP4"]) {
            [_selectedMP4 addObject:[mediaPath stringByAppendingPathComponent:fileName]];
        }
    }
    
    [self refreshImageNum];
}

//获取任务
- (void)getMissionModelFromSQL{
    _taskModel = [[SQLManager sharedManager] getMissionModelWithGuid:self.taskID];
    _zbs = _taskModel.SHAPE;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)areaIsEqual:(id)sender {
    UIButton *button = sender;
    if([button.titleLabel.text isEqualToString:@"是"]){
        _radioYES.selected = YES;
        _radioNO.selected = NO;
        _sjmjTF.editable = NO;
        _sjnydmjTF.editable = NO;
        _sjgdmjTF.editable = NO;
        _jsjbntTF.editable = NO;
        _sjjeTF.editable = NO;
        _sjrkTF.editable = NO;
    } else {
        _radioYES.selected = NO;
        _radioNO.selected = YES;
        _sjmjTF.editable = YES;
        _sjnydmjTF.editable = YES;
        _sjgdmjTF.editable = YES;
        _jsjbntTF.editable = YES;
        _sjjeTF.editable = YES;
        _sjrkTF.editable = YES;
    }
}

- (IBAction)saveTask:(id)sender {
    [_locService stopUserLocationService];
    _locService = nil;
    
    //根据有无图斑编号进行不同的处理
    if (_taskModel.SHAPE != nil) {
        HCResult *hcResult = [[HCResult alloc]init];
        hcResult.yw_guid = _taskModel.GUID;
        hcResult.tb_type = _taskModel.TB_TYPE;
        hcResult.hcqk = _infoTextView.text;
        hcResult.hcry = _nameTextView.text;
        hcResult.hcrq = _timeTextView.text;
        hcResult.zbs = _taskModel.SHAPE;
        [_sql saveHCXX:hcResult];
        
    }else{
        if (_zbs) {
            HCResult *hcResult = [[HCResult alloc]init];
            hcResult.yw_guid = _taskModel.GUID;
            hcResult.tb_type = _taskModel.TB_TYPE;
            hcResult.hcqk = _infoTextView.text;
            hcResult.hcry = _nameTextView.text;
            hcResult.hcrq = _timeTextView.text;
            hcResult.zbs = _zbs;
            [_sql saveHCXX:hcResult];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请采集图斑" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    
    WS(wself)
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否保存" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"保存中"];
        });
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //创建核查xml文件并保存地址
            [wself creatTaskXMl];
            
            //视频地址添加到uploadPaths
            if (_selectedMP4.count>0) {
                [_uploadPaths addObject:_selectedMP4[0]];
                //创建videoXML文件并保存地址
                [wself creatVideoXML];
            }
            
            //保存的信息持久化
            [wself yyCacheDictionary];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                //是否上传提示
                [wself showHuiChuanAlert];
                
                [_locService startUserLocationService];
            });
            
        });
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [_locService startUserLocationService];
    }];
    [alertVC addAction:yesAction];
    [alertVC addAction:cancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}

//采集多媒体文件
- (IBAction)mediaCollect:(id)sender {
    
    //创建一个UIActionSheet，其中destructiveButton会红色显示，可以用在一些重要的选项
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"现场拍照", @"佐证拍照", @"录制视频",nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;//默认风格，灰色背景，白色文字
    
    [actionSheet showInView:self.view];
}

//回传至服务器
- (IBAction)backToServer:(id)sender {
    
    //上传任务
    [[ServiceManager sharedManger] uploadTaskWithGuid:_taskModel.GUID progress:^(NSProgress *uploadProgress) {
        
        
    } success:^(id responseOBJ) {
        
        [[SQLManager sharedManager] changeHCZTSTAT2SWithGUID:_taskModel.GUID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //                [wself.navigationController popToRootViewControllerAnimated:YES];
        });
        
        
    } failure:^(NSError *error) {
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //
        //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"上传失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        //                [alert show];
        //            });
        
    }];
    
    
}

//查看多媒体取证文件
- (IBAction)seeImage:(id)sender {
    MediaViewController *mediaVC = [[MediaViewController alloc] init];
    [mediaVC setTitle:@"现场照片"];
    mediaVC.selectedPhotos = _selectedPhotos;
    mediaVC.mediaType = 0;
    
    [self.navigationController pushViewController:mediaVC animated:YES];
    
}

- (IBAction)seeEvidence:(id)sender {
    MediaViewController *mediaVC = [[MediaViewController alloc] init];
    [mediaVC setTitle:@"佐证照片"];
    mediaVC.zzSelectedPhotos = _zzSelectedPhotos;
    mediaVC.mediaType = 1;
    [self.navigationController pushViewController:mediaVC animated:YES];
}

- (IBAction)seeVideo:(id)sender {
    MediaViewController *mediaVC = [[MediaViewController alloc] init];
    [mediaVC setTitle:@"视频"];
    mediaVC.mediaType = 2;
    mediaVC.selectedMP4 = _selectedMP4;
    [self.navigationController pushViewController:mediaVC animated:YES];
}
#pragma mark - UIActionSheetDelegate
//根据被点击的按钮做出反应，0对应destructiveButton，之后的button依次排序
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        CameraViewController *cameraVc = [[CameraViewController alloc]init];
        cameraVc.taskID = self.taskID;
        cameraVc.photoType = 0;
        [self.navigationController presentViewController:cameraVc animated:YES completion:nil];
        
        
    } else if (buttonIndex == 1) {

        CameraViewController *cameraVc = [[CameraViewController alloc]init];
        cameraVc.taskID = self.taskID;
        cameraVc.photoType = 1;
        [self.navigationController presentViewController:cameraVc animated:YES completion:nil];
    } else if(buttonIndex == 2) {
        
        if (_selectedMP4.count>0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"只能拍摄一个视频" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            return;
        }

        VideoViewController *videoVC = [[VideoViewController alloc] init];
        videoVC.taskID = self.taskID;
        [self.navigationController presentViewController:videoVC animated:YES completion:nil];
    }
}
#pragma mark - imagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyMMdd_hhmmss"];
    
    if (_cellSection == 0) {//视频保存处理
        if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie]) {
            NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
            NSString *urlStr=[url path];
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {//判断该视频是否能存入相簿
                //保存视频到相簿
                UISaveVideoAtPathToSavedPhotosAlbum(urlStr,self, @selector(video:didFinishSavingWithError:contextInfo:),nil);//保存视频到相簿
            }
            //保存视频文件夹目录
            NSString *dirDoc = [self dirDoc];
            NSString *mp4DocPath = [dirDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@@%@@%@.MP4",_taskModel.GUID,_taskModel.GUID,[dateFormatter stringFromDate:[NSDate date]],[_videoLocArr lastObject]]];
            
            NSFileManager *fileMgr = [[NSFileManager alloc] init];
            NSError *error = nil;
            
            [fileMgr copyItemAtPath:urlStr toPath:mp4DocPath error:&error];
            //完成之后将视频路径存到数组中
            [_selectedMP4 addObject:mp4DocPath];
            
        }
    }else{//图片保存处理
        
        if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]){
            UIImage *selectedImg = [info objectForKey:UIImagePickerControllerOriginalImage];
            //            NSLog(@"img");
            
            NSString *locationStr = [NSString stringWithFormat:@"经度:%f\n纬度:%f\n方位角:%f",_locService.userLocation.location.coordinate.longitude,_locService.userLocation.location.coordinate.latitude,_locService.userLocation.heading.trueHeading];
            
//            selectedImg = [self addText:selectedImg text:locationStr];
            
            
            //使用hcimage保存图片和位置信息
            HCImage *hcImage = [[HCImage alloc]init];
            hcImage.image = selectedImg;
            hcImage.longitude = [NSString stringWithFormat:@"%f",_locService.userLocation.location.coordinate.longitude];
            hcImage.latitude = [NSString stringWithFormat:@"%f",_locService.userLocation.location.coordinate.latitude];
            hcImage.fxj = [NSString stringWithFormat:@"%.2f",_locService.userLocation.heading.trueHeading];
            
            NSLog(@"经度：%f ，纬度： %f ，方位角：%f",_locService.userLocation.location.coordinate.longitude,_locService.userLocation.location.coordinate.latitude,_locService.userLocation.heading.trueHeading);
            
            //保存图片至本地文件夹
            hcImage.date = [NSDate date];
            NSData *data = UIImageJPEGRepresentation(selectedImg, 0.5);
            NSMutableString *outPath = [NSMutableString string];
            NSString *dirDoc = [self dirDoc];
            NSString *path = [dirDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@@%@@%@@%@@FWJ%@",_taskModel.GUID,_taskModel.GUID,[dateFormatter stringFromDate:hcImage.date],hcImage.longitude,hcImage.latitude,hcImage.fxj]];
            [outPath appendString:path];
            if(_cellSection == 2) {
                
                [outPath appendString:@"@zuozhen"];
            }
            [outPath appendString:@".jpg"];

            if ([data writeToFile:outPath atomically:YES] == YES ) {
                NSLog(@"保存路径：----------------——%@",outPath);
            } else {
                NSLog(@"保存路径：----------------——保存失败");
            }
            
            //根据section不同做不同处理
            if (_cellSection == 1) {
                [_selectedPhotos addObject:outPath];
            }else{
                [_zzSelectedPhotos addObject:outPath];
                
            }
        }
    }
    
    [_xcPicker dismissViewControllerAnimated:YES completion:nil];
    //获取完成之后检查是否符合要求
    [self checkSaveBtnState];
    [self refreshImageNum];
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"%@",error);
    }
}

- (void)creatVideoXML{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyy-MM-dd-hh-mm-ss"];
    NSString *locStr = [_videoLocArr firstObject];
    locStr = [locStr stringByReplacingOccurrencesOfString:@"," withString:@"@"];
    
    
    NSString *dirDoc = [self dirDoc];
    NSString *videoXmlPath = [dirDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@@%@@%@.xml",_taskModel.GUID,_taskModel.GUID,[dateFormatter stringFromDate:[NSDate date]],locStr]];
    
    _xmlStr = [NSMutableString string];
    
    for (NSString *locstr in _videoLocArr) {
        [_xmlStr appendFormat:@"%@;",locstr];
        //        [_xmlStr appendString:locstr];
    }
    
    DDXMLElement *zbs = [DDXMLElement elementWithName:@"zbs" stringValue:_xmlStr];
    DDXMLDocument *zbsDoc = [[DDXMLDocument alloc]initWithXMLString:zbs.XMLString options:0 error:nil];
    [[zbsDoc XMLData] writeToFile:videoXmlPath atomically:YES];
    //保存视频地址
    [_uploadPaths addObject:videoXmlPath];
    
}

- (void)savePhotosToTmpFrom:(NSArray *)arr{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyy-MM-dd-hh-mm-ss"];
    
    for (int i=0; i<arr.count; i++) {
        HCImage *image = arr[i];
        NSMutableString *outputPath = [NSMutableString string];
        NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/%@@%@@%@@%@@FWJ%@",_taskModel.GUID,[dateFormatter stringFromDate:image.date],image.longitude,image.latitude,image.fxj];
        
        [outputPath appendString:path];
        if (arr == _zzSelectedPhotos) {
            [outputPath appendString:@"@zuozhen"];
        }
        
        [outputPath appendString:@".jpg"];
        
        NSData *imgData = UIImageJPEGRepresentation(image.image, 0.5);
        if ([imgData writeToFile:outputPath atomically:YES] == YES ) {
            NSLog(@"导出成功:%@",outputPath);
        }
        //将选择的图片地址添加到上传数组中
        [_uploadPaths addObject:outputPath];
        
    }
    
    
}
- (void)yyCacheDictionary{
    NSLog(@"upload cout %lu",(unsigned long)_uploadPaths.count);
    
    
    YYCache *cache = [YYCache cacheWithName:@"paths"];
    
    
    NSDictionary *cacheDict = @{
//                                @"paths":_uploadPaths,
//                                @"videoPath":_selectedMP4,
//                                @"photos":_selectedPhotos,
//                                @"zzPhoto":_zzSelectedPhotos,
                                @"zgqk":_infoTF.text,
                                @"hcry":_nameTF.text,
                                @"hcrq":_timeTextView.text,
                                @"isXF":_radioYES.isSelected?@"1":@"0",
                                @"sjmj":_sjmjTF.text,
                                @"sjnydmj":_sjnydmjTF.text,
                                @"sjgdmj":_sjgdmjTF.text,
                                @"sjjbnt":_jsjbntTF.text,
                                @"sjje":_sjjeTF.text,
                                @"sjrk":_sjrkTF.text
                                
                                };
    
    [cache setObject:cacheDict forKey:_taskModel.GUID];
    
    NSLog(@"cache:%@",[cache objectForKey:_taskModel.GUID]);
    //保存成功后 改变hcztstate
    [_sql changeHCZTSTAT1SWithGUID:_taskModel.GUID];
    
}
- (void)checkSaveBtnState{
    //检查 整改情况，核查人员 是否填写完整
    if (_infoTextView.text.length<=10 || _nameTextView.text.length<1) {
        
        return;
    }
    
    //检查 是否有图斑
    if (_taskModel.SHAPE == nil && _zbs == nil) {
        return;
    }
    
    //根据有无图斑判断不同
    if ([_taskModel.isXCJ isEqualToString: @"1"]) {
        
        //检查 选取的图片是否符合要求
        if (_selectedMP4.count<1&&_selectedPhotos.count<1) {
            return;
        }
        
    }else{
        
        //检查 选取的图片是否符合要求
        if (_selectedMP4.count<1) {
            return;
        }
        if (_selectedPhotos.count<4) {
            return;
        }
        
    }
    
    _saveBtn.alpha = 1;
    _saveBtn.enabled = YES;
    
    _paisheBtn.alpha = 1;
    _paisheBtn.enabled = YES;
    
}

//显示是否回传
- (void)showHuiChuanAlert{
    if ([_taskModel.isXCJ isEqualToString:@"0"]) {
        
        if (_uploadPaths.count<7) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请完整填写相关信息，点击保存后上传" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            return;
        }
        
    }
    
    //显示回传提示框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否需要回传" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        MissionModel *task =  _taskModel;
        
        //上传任务
        [[ServiceManager sharedManger] uploadTaskWithGuid:task.GUID progress:^(NSProgress *uploadProgress) {
            
            
        } success:^(id responseOBJ) {
            
            [[SQLManager sharedManager] changeHCZTSTAT2SWithGUID:task.GUID];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                

            });
            
            
        } failure:^(NSError *error) {
            
        }];
        
    }];
    
    UIAlertAction *cancelACtion = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:yesAction];
    [alert addAction:cancelACtion];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

//获取唯一设备号
- (NSString *)getIMSI{
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
    
    NSString *imsi = [NSString stringWithFormat:@"%@%@", mcc, mnc];
    
    return imsi;
    
}

//生成taskXml
- (void)creatTaskXMl{
    
    NSString *dirDoc = [self dirDoc];
    NSString *xmlPath = [dirDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.xml",_taskModel.GUID,_taskModel.GUID]];
    
    DDXMLElement *wyhc = [DDXMLElement elementWithName:@"wyhc"];
    DDXMLElement *zbs = [DDXMLElement elementWithName:@"zbs" stringValue:_taskModel.SHAPE];
    DDXMLElement *yw_guid = [DDXMLElement elementWithName:@"yw_guid" stringValue:_taskModel.GUID];
    DDXMLElement *tb_type = [DDXMLElement elementWithName:@"tb_type" stringValue:_taskModel.TB_TYPE];
    DDXMLElement *hcqk = [DDXMLElement elementWithName:@"hcqk" stringValue:_infoTextView.text];
    DDXMLElement *hcrq = [DDXMLElement elementWithName:@"hcrq" stringValue:_timeTextView.text];
    DDXMLElement *hcry = [DDXMLElement elementWithName:@"hcry" stringValue:_nameTextView.text];
    DDXMLElement *wtsjsjmj = [DDXMLElement elementWithName:@"wtsjsjmj" stringValue:_sjmjTF.text];
    DDXMLElement *wtsjsjnyd = [DDXMLElement elementWithName:@"wtsjsjnyd" stringValue:_sjnydmjTF.text];
    DDXMLElement *wtsjsjgd = [DDXMLElement elementWithName:@"wtsjsjgd" stringValue:_sjgdmjTF.text];
    DDXMLElement *wtsjsjjbnt = [DDXMLElement elementWithName:@"wtsjsjjbnt" stringValue:_jsjbntTF.text];
    DDXMLElement *wtsjsjje = [DDXMLElement elementWithName:@"wtsjsjje" stringValue:_sjjeTF.text];
    DDXMLElement *wtsjsjrk = [DDXMLElement elementWithName:@"wtsjsjrk" stringValue:_sjrkTF.text];
    DDXMLElement *imsi = [DDXMLElement elementWithName:@"imsi" stringValue:[self getIMSI]];
    
    [wyhc addChild:zbs];
    [wyhc addChild:yw_guid];
    [wyhc addChild:tb_type];
    [wyhc addChild:hcqk];
    [wyhc addChild:hcrq];
    [wyhc addChild:hcry];
    [wyhc addChild:wtsjsjmj];
    [wyhc addChild:wtsjsjnyd];
    [wyhc addChild:wtsjsjgd];
    [wyhc addChild:wtsjsjjbnt];
    [wyhc addChild:wtsjsjje];
    [wyhc addChild:wtsjsjrk];
    [wyhc addChild:imsi];
    
    DDXMLDocument *taskDoc = [[DDXMLDocument alloc]initWithXMLString:wyhc.XMLString options:0 error:nil];
    
    [[taskDoc XMLData] writeToFile:xmlPath atomically:YES];
    
    NSLog(@"%@",xmlPath);
    //将文件地址添加到数组中
    [_uploadPaths addObject:xmlPath];
    
    
}

//是否在范围内
- (BOOL)isInside:(NSString *)pointsStr {
    
    if ([pointsStr hasSuffix:@";"]) {
        pointsStr = [pointsStr substringToIndex: pointsStr.length-2];
    }
    
    
    
    NSArray *gpsPoints = [pointsStr componentsSeparatedByString:@";"];
    //多边形范围
    BMKMapPoint *points = malloc(gpsPoints.count*sizeof(BMKMapPoint));
    CLLocationCoordinate2D * coords = malloc(gpsPoints.count*sizeof(CLLocationCoordinate2D));
    
    for (int i = 0 ; i<gpsPoints.count; i++) {
        NSArray *point;
        if (gpsPoints[i]) {
            
            point = [gpsPoints[i] componentsSeparatedByString:@","];
            coords[i] = CLLocationCoordinate2DMake([point[1] doubleValue], [point[0] doubleValue]);
            
        }
    }
    for (int i = 0; i<gpsPoints.count; i++) {
        points[i]=BMKMapPointForCoordinate(coords[i]);
    }
    //当前位置
    BMKMapPoint point = BMKMapPointForCoordinate(_locService.userLocation.location.coordinate);
    
    BOOL flag = BMKPolygonContainsPoint(point, points, gpsPoints.count);
    
    free(coords);
    
    return flag;
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

//刷新多媒体文件数量
-(void) refreshImageNum {
    NSLog(@"照片数量：%ld",(long)_selectedPhotos.count );
    NSLog(@"佐证数量：%ld",(long)_zzSelectedPhotos.count );
    NSLog(@"视频数量：%ld",(long)_selectedMP4.count );

    NSLog(@"文件数量：%ld",(long)_uploadPaths.count);
    

    [_picBtn setTitle:[NSString stringWithFormat:@"照片(%ld)",(long)_selectedPhotos.count] forState:UIControlStateNormal];
    
    [_eviBtn setTitle:[NSString stringWithFormat:@"佐证(%ld)",(long)_zzSelectedPhotos.count] forState:UIControlStateNormal];
    
    [_videoBtn setTitle:[NSString stringWithFormat:@"视频(%ld)",(long)_selectedMP4.count] forState:UIControlStateNormal];

}

//获取Documents目录
-(NSString *)dirDoc{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}
-(void)viewWillDisappear:(BOOL)animated{
    [_locService stopUserLocationService];
    _locService.delegate = nil;
}
@end
