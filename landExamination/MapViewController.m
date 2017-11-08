//
//  MapViewController.m
//  landExamination
//
//  Created by xianglong on 2017/9/29.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "MapViewController.h"
#import "Coor.h"
#import <SVProgressHUD.h>
#import "SQLManager.h"
#import "OfflineViewController.h"
#import "CheckViewController.h"
#import "CaiJiViewController.h"


@interface MapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKRouteSearchDelegate,BNNaviUIManagerDelegate,BNNaviRoutePlanDelegate>{
    BMKUserLocation *location;
    int polygonType;
    float lat;
    float log;
    BOOL isMeasure;
    BOOL isArea;
    BOOL isAreaPolygon;
}
- (IBAction)GPSmeasure:(id)sender;
- (IBAction)taskNavi:(id)sender;
- (IBAction)taskLoc:(id)sender;
- (IBAction)taskCheck:(id)sender;
- (IBAction)cancelMeasure:(id)sender;
- (IBAction)lengthMeasure:(id)sender;
- (IBAction)areaMeasure:(id)sender;
- (IBAction)offlineMap:(id)sender;
- (IBAction)collectPoint:(id)sender;



- (IBAction)mapModel:(UISegmentedControl *)sender;
- (IBAction)selfLoc:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *collectBtn;
@property (weak, nonatomic) IBOutlet BMKMapView *BMKMapView;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIButton *locButton;
@property (weak, nonatomic) IBOutlet UIButton *naviButton;
@property (weak, nonatomic) IBOutlet UILabel *measureResult;
@property (weak, nonatomic) IBOutlet UIButton *gpsMeasureButton;

@property (strong, nonatomic) NSMutableArray *pointArr;
//定位服务
@property (strong, nonatomic) BMKLocationService *locService;
//图斑
@property (strong, nonatomic) BMKPolygon *polygon;
//图斑外圈
@property (strong, nonatomic) BMKPolygon *outPolygon;
//大头针
@property (strong, nonatomic) BMKPointAnnotation *pointAnnotation;
//导航
@property (strong, nonatomic)BMKRouteSearch *routesearch;
//图斑标记
@property (strong, nonatomic) BMKPolygon *measurePolygon;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:_taskID];
    //防止导航栏遮挡控件
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initButton:_naviButton];
    [self initButton:_locButton];
    [self initButton:_checkButton];
    
    _locService = [[BMKLocationService alloc]init];
    _routesearch = [[BMKRouteSearch alloc]init];
    
    _BMKMapView.zoomLevel = 17;
    _BMKMapView.showMapScaleBar = YES;
    _BMKMapView.mapScaleBarPosition = CGPointMake(8, 20);
    
    _pointArr = [NSMutableArray array];
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [_BMKMapView viewWillAppear];
    _BMKMapView.delegate = self;
    _locService.delegate = self;
    _routesearch.delegate = self;
    
    [_locService startUserLocationService];
    _BMKMapView.showsUserLocation = NO;
    _BMKMapView.userTrackingMode = BMKUserTrackingModeFollow;
    
    
    [self loc];
    isMeasure = NO;
    isArea = NO;
    isAreaPolygon = NO;
//    [self taskLocationBtnAction:nil];
    _collectBtn.hidden = [_mission.isXCJ isEqualToString:@"0"]?YES:NO;
    
    [self getMissionModelFromSQL];
    
    [self drawPolygon];
    
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [_locService stopUserLocationService];
    [_BMKMapView viewWillDisappear];
    _BMKMapView.delegate = nil;
    _locService.delegate = nil;
    _routesearch.delegate = nil;
    
    
    [super viewWillDisappear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//启动定位
-(void)loc
{
    
    
    if(self.mission.OUTBUFFER.length <10) {
        if(location != nil){
            //启动LocationService
            [_locService startUserLocationService];
            _BMKMapView.centerCoordinate = location.location.coordinate;
        }
    } else{
        [self taskLoc:nil];
    }
}
//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //普通态
    //以下_mapView为BMKMapView对象
    location = userLocation;
    
    lat = userLocation.location.coordinate.latitude;
    log = userLocation.location.coordinate.longitude;
    
    [_BMKMapView updateLocationData:userLocation];
    _BMKMapView.showsUserLocation = YES;
}

//加载图斑
-(void)drawPolygon
{
    NSLog(@"**********************画图斑**********************");
    if(_outPolygon != nil) {
        [_BMKMapView removeOverlay:_outPolygon];
    }
    if(_polygon != nil) {
        [_BMKMapView removeOverlay:_polygon];
    }
    
    if([self.mission.OUTBUFFER length]>10){
        NSArray *latlog = [self.mission.OUTBUFFER componentsSeparatedByString:@";"];
        
        int count = (int)latlog.count-1;
        //位置坐标的个数的情况下这样初始化~
        CLLocationCoordinate2D *coors = malloc(count * sizeof(CLLocationCoordinate2D));
        
        
        for (int i=0; i<count; i++) {
            
            NSArray *ll = [latlog[i] componentsSeparatedByString:@","];
            coors[i].latitude=[ll[1] doubleValue];
            coors[i].longitude=[ll[0] doubleValue];
            
        }
        _outPolygon = [BMKPolygon polygonWithCoordinates:coors count:count];
        [_BMKMapView addOverlay:_outPolygon];
    }
    
    
    if([self.mission.SHAPE length]<10){
        return;
    }
    
    NSArray *latlog2 = [self.mission.SHAPE componentsSeparatedByString:@";"];
    
    int count2 = (int)latlog2.count-1;
    
    //位置坐标的个数的情况下这样初始化~
    CLLocationCoordinate2D *coors2 = malloc(count2 * sizeof(CLLocationCoordinate2D));
    
    for (int i=0; i<count2; i++) {
        
        NSArray *ll = [latlog2[i] componentsSeparatedByString:@","];
        
        coors2[i].latitude=[ll[1] doubleValue];
        coors2[i].longitude=[ll[0] doubleValue];
        
        
    }
    _polygon = [BMKPolygon polygonWithCoordinates:coors2 count:count2];
    [_BMKMapView addOverlay:_polygon];
    
}

//地图覆盖物添加协议方法
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.lineWidth = 1;
        
        polylineView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];nil;
        return polylineView;
    }
    
    
    
    if ([overlay isKindOfClass:[BMKPolygon class]]){
        BMKPolygonView* polygonView = [[BMKPolygonView alloc]initWithOverlay:overlay];
        if(isAreaPolygon){
            polygonView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
            polygonView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
            polygonView.lineWidth = 0.5;
            return polygonView;
        }
        if(polygonType == 0){
            polygonView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
            polygonView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
            polygonView.lineWidth = 0.5;
            polygonType++;
        } else if(polygonType == 1){
            polygonView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:1];
            polygonView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
            polygonView.lineWidth = 0.5;
            polygonType--;
        }
        
        return polygonView;
    }
    return nil;
}


//获取任务
- (void)getMissionModelFromSQL{
    
    _mission = [[SQLManager sharedManager] getMissionModelWithGuid:self.taskID];
    
}

//button样式修改
-(void)initButton:(UIButton*)btn{
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    // 按钮图片和标题总高度
    CGFloat totalHeight = (btn.imageView.frame.size.height + btn.titleLabel.frame.size.height);
    // 设置按钮图片偏移
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-(totalHeight - btn.imageView.frame.size.height), 0.0, 0.0, -btn.titleLabel.frame.size.width)];
    // 设置按钮标题偏移
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -btn.imageView.frame.size.width, -(totalHeight - btn.titleLabel.frame.size.height),0.0)];
    
}

//图斑导航
- (IBAction)taskNavi:(id)sender {
    if (![self checkServicesInited]) return;
    //导航
    NSMutableArray *nodesArray = [[NSMutableArray alloc] init];
    if(location== nil){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"尚未获取有效坐标，请稍后重试" delegate:NULL cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
//    startNode.pos.x = myLocation.coordinate.longitude;
//    startNode.pos.y = myLocation.coordinate.latitude;
    
    startNode.pos.x = 114.122;
    startNode.pos.y = 22.5411;
    startNode.pos.eType = BNCoordinate_OriginalGPS;
    [nodesArray addObject:startNode];
    //导航终点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    
        endNode.pos.x = 114.089863;
        endNode.pos.y = 22.546236;
    
//    endNode.pos.x = _mission.XZB.doubleValue;
//    endNode.pos.y = _mission.YZB.doubleValue;
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    
    [BNCoreServices_RoutePlan setDisableOpenUrl:YES];
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
}

//图斑定位
- (IBAction)taskLoc:(id)sender {
    //没有图斑编号时提示没有图斑
    if (_mission.SHAPE==nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该任务无问题图斑，无法定位！" delegate:NULL cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    CLLocationCoordinate2D coor;
    
    if([self.mission.isXCJ isEqualToString:@"0"]){
        
        coor.latitude = [self.mission.YZB doubleValue];
        coor.longitude = [self.mission.XZB doubleValue];
        [_BMKMapView setCenterCoordinate:coor animated:YES];
    } else {
        if(self.mission.OUTBUFFER.length < 10){
            return;
        }
        NSArray *latlog = [self.mission.OUTBUFFER componentsSeparatedByString:@";"];
        
        if(latlog.count <3) {
            return;
        }
   
        
        NSArray *ll = [latlog[0] componentsSeparatedByString:@","];
        NSArray *ll2 = [latlog[latlog.count-1] componentsSeparatedByString:@","];
        
        coor.latitude=([ll[1] doubleValue] + [ll2[1] doubleValue])/2;
        coor.longitude=([ll[0] doubleValue] + [ll2[0] doubleValue])/2;
            
        [_BMKMapView setCenterCoordinate:coor animated:YES];
        
    }
    
    
}

//任务核查
- (IBAction)taskCheck:(id)sender {
    CheckViewController *checkVC = [[CheckViewController alloc]init];
    checkVC.title = @"任务核查";
    checkVC.taskID = _taskID;
    [self.navigationController pushViewController:checkVC animated:YES];
}



//更改地图模式
- (IBAction)mapModel:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            _BMKMapView.mapType = BMKMapTypeStandard;
            break;
        case 1:
            _BMKMapView.mapType = BMKMapTypeSatellite;
            break;
        default:
            break;
    }
}

//人员定位
- (IBAction)selfLoc:(id)sender {
    if(location != nil){
        [_BMKMapView setCenterCoordinate:location.location.coordinate animated:YES];
    }
}
//取消测量
- (IBAction)cancelMeasure:(id)sender {
    isMeasure = NO;
    isArea = NO;
    isAreaPolygon = NO;
    _measureResult.hidden = YES;
    _gpsMeasureButton.hidden = YES;
    
    [_pointArr removeAllObjects];
    NSArray* array = [NSArray arrayWithArray:_BMKMapView.annotations];
    [_BMKMapView removeAnnotations:array];
    
    NSArray* arrayOverlay = [NSArray arrayWithArray:_BMKMapView.overlays];
    [_BMKMapView removeOverlays:arrayOverlay];
    
    [_BMKMapView addOverlay:_outPolygon];
    [_BMKMapView addOverlay:_polygon];
    
}

//长度测量
- (IBAction)lengthMeasure:(id)sender {
    isArea = NO;
    isMeasure = YES;
    isAreaPolygon = NO;
    _measureResult.hidden = NO;
    _gpsMeasureButton.hidden = NO;
    _measureResult.text = @"0米";
    
    [_pointArr removeAllObjects];
    NSArray* array = [NSArray arrayWithArray:_BMKMapView.annotations];
    [_BMKMapView removeAnnotations:array];
    
    NSArray* arrayOverlay = [NSArray arrayWithArray:_BMKMapView.overlays];
    [_BMKMapView removeOverlays:arrayOverlay];
    
    [_BMKMapView addOverlay:_outPolygon];
    [_BMKMapView addOverlay:_polygon];
    
}

//面积测量
- (IBAction)areaMeasure:(id)sender {
    isArea = NO;
    isAreaPolygon = NO;
    [_pointArr removeAllObjects];
    NSArray* array = [NSArray arrayWithArray:_BMKMapView.annotations];
    [_BMKMapView removeAnnotations:array];
    
    NSArray* arrayOverlay = [NSArray arrayWithArray:_BMKMapView.overlays];
    [_BMKMapView removeOverlays:arrayOverlay];
    
    [_BMKMapView addOverlay:_outPolygon];
    [_BMKMapView addOverlay:_polygon];
    
    isArea = YES;
    isMeasure = YES;
    _measureResult.hidden = NO;
    _gpsMeasureButton.hidden = NO;
    _measureResult.text = @"0亩";
    
   
}

- (IBAction)offlineMap:(id)sender {
    OfflineViewController *offlineVC = [[OfflineViewController alloc]init];
    offlineVC.title = @"离线地图下载";
    [self.navigationController pushViewController:offlineVC animated:YES];
}

- (IBAction)collectPoint:(id)sender {
    CaiJiViewController *caiJiVC = [[CaiJiViewController alloc] init];
    caiJiVC.guid = _mission.GUID;
    [self.navigationController pushViewController:caiJiVC animated:YES];
}

//GPS打点测量
- (IBAction)GPSmeasure:(id)sender {
    [self addAnnotation:location.location.coordinate];
    
}


- (BOOL)checkServicesInited
{
    if(![BNCoreServices_Instance isServicesInited])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"引擎尚未初始化完成，请稍后再试"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}
#pragma mark - BNNaviRoutePlanDelegate
//算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo
{
    NSLog(@"算路成功");
    //路径规划成功，开始导航
    [BNCoreServices_UI showPage:BNaviUI_NormalNavi delegate:self extParams:nil];
}

//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary*)userInfo
{
    switch ([error code]%10000)
    {
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONFAILED:
            NSLog(@"暂时无法获取您的位置,请稍后重试");
            break;
        case BNAVI_ROUTEPLAN_ERROR_ROUTEPLANFAILED:
            NSLog(@"无法发起导航");
            break;
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONSERVICECLOSED:
            NSLog(@"定位服务未开启,请到系统设置中打开定位服务。");
            break;
        case BNAVI_ROUTEPLAN_ERROR_NODESTOONEAR:
            NSLog(@"起终点距离起终点太近");
            break;
        default:
            NSLog(@"算路失败");
            break;
    }
}

//算路取消回调
-(void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    NSLog(@"算路取消");
}


#pragma mark - 安静退出导航

- (void)exitNaviUI
{
    [BNCoreServices_UI exitPage:EN_BNavi_ExitTopVC animated:YES extraInfo:nil];
}

#pragma mark - BNNaviUIManagerDelegate

//退出导航页面回调
- (void)onExitPage:(BNaviUIType)pageType  extraInfo:(NSDictionary*)extraInfo
{
    if (pageType == BNaviUI_NormalNavi)
    {
        NSLog(@"退出导航");
    }
    else if (pageType == BNaviUI_Declaration)
    {
        NSLog(@"退出导航声明页面");
    }
}




#pragma mark - 底图手势操作
/**
 *点中底图标注后会回调此接口
 *@param mapview 地图View
 *@param mapPoi 标注点信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi
{
    if(isMeasure == NO) {
        return;
    }
    
    
    //添加标注
    CLLocationCoordinate2D coor = mapPoi.pt;
    [self addAnnotation:coor];
    
    NSLog(@"onClickedMapPoi-%@",mapPoi.text);
    NSString* showmeg = [NSString stringWithFormat:@"您点击了底图标注:%@,\r\n当前经度:%f,当前纬度:%f,\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d", mapPoi.text,mapPoi.pt.longitude,mapPoi.pt.latitude, (int)_BMKMapView.zoomLevel,_BMKMapView.rotation,_BMKMapView.overlooking];
    NSLog(@"%@",showmeg);
    
}
/**
 *点中底图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    if(isMeasure == NO) {
        return;
    }
    
    //添加标注
    [self addAnnotation:coordinate];
    
    NSLog(@"onClickedMapBlank-latitude==%f,longitude==%f",coordinate.latitude,coordinate.longitude);
    NSString* showmeg = [NSString stringWithFormat:@"您点击了地图空白处(blank click).\r\n当前经度:%f,当前纬度:%f,\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d", coordinate.longitude,coordinate.latitude,
                         (int)_BMKMapView.zoomLevel,_BMKMapView.rotation,_BMKMapView.overlooking];
    NSLog(@"%@",showmeg);
    
}
- (void)addAnnotation:(CLLocationCoordinate2D )coor{
    
    //将点击位置的坐标转换成 coor model 放入数组中
    [_pointArr addObject:[Coor initWith:coor]];
    
    if (!isArea) {
        double distance = 0;
        for (int i = 0; i<_pointArr.count; i++) {
            BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
            pointAnnotation.coordinate = coor;
            BMKPolyline *line;
            //第一个点 标注为起点
            if (i==0) {
                pointAnnotation.title = @"起点";
            }else{
                //第二个点 添加标注添加直线
                CLLocationCoordinate2D coords[2] = {0};
                coords[0].latitude = [_pointArr[i-1] lat];
                coords[0].longitude = [_pointArr[i-1] lon];
                coords[1].latitude = [_pointArr[i] lat];
                coords[1].longitude = [_pointArr[i] lon];
                line = [BMKPolyline polylineWithCoordinates:coords count:2];
                //计算距离
                BMKMapPoint point1 = BMKMapPointForCoordinate(coords[0]);
                BMKMapPoint point2 = BMKMapPointForCoordinate(coords[1]);
                CLLocationDistance meter = BMKMetersBetweenMapPoints(point1, point2);
                distance = distance + meter;
                pointAnnotation.title = [NSString stringWithFormat:@"%.2f米",distance];
            }
            _measureResult.text = [NSString stringWithFormat:@"%.2f米",distance];
            //添加到视图中
            [_BMKMapView addAnnotation:pointAnnotation];
            if (line != nil) {
                [_BMKMapView addOverlay:line];
            }
        }
        
    }else{
        
        [self refreshAnnotation];
        
    }
}


- (void)refreshAnnotation{
    
    NSArray* array = [NSArray arrayWithArray:_BMKMapView.annotations];
    [_BMKMapView removeAnnotations:array];
    //移除图斑
    [_BMKMapView removeOverlay:_measurePolygon];
    
    //大头针位置
    for (Coor *coorObj in _pointArr) {
        
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(coorObj.lat, coorObj.lon);
        
        BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
        pointAnnotation.coordinate = coor;
        pointAnnotation.title = @"";
        
        //        [_BMKMapView setCenterCoordinate:coor animated:YES];
        //添加大头针
        [_BMKMapView addAnnotation:pointAnnotation];
    }
    
    //有三个以上点时显示范围
    if (_pointArr.count>2) {
        isAreaPolygon = YES;
        //多边形覆盖物
        CLLocationCoordinate2D * coords = malloc(_pointArr.count*sizeof(CLLocationCoordinate2D));
        
        for (int i = 0 ; i<_pointArr.count; i++) {
            
            Coor *coorObj=_pointArr[i];
            coords[i] = CLLocationCoordinate2DMake(coorObj.lat, coorObj.lon);
        }
        
        _measurePolygon = [BMKPolygon polygonWithCoordinates:coords count:_pointArr.count];
        
        [_BMKMapView addOverlay:_measurePolygon];
        
        double area = [self areaWithPoints:coords count:_pointArr.count];
        NSLog(@"面积：-------------%f",area);
        _measureResult.text = [NSString stringWithFormat:@"%.2f亩",area];
        
    }
    
    
    
}

- (double)areaWithPoints:(CLLocationCoordinate2D *)coords count:(NSUInteger)count{
    
    static double   EARTHRADIUS= 6378137.0;
    double totalArea = 0;//初始化总面积
    double LowX = 0.0;
    double LowY = 0.0;
    double MiddleX = 0.0;
    double MiddleY = 0.0;
    double HighX = 0.0;
    double HighY = 0.0;
    double AM = 0.0;
    double BM = 0.0;
    double CM = 0.0;
    double AL = 0.0;
    double BL = 0.0;
    double CL = 0.0;
    double AH = 0.0;
    double BH = 0.0;
    double CH = 0.0;
    double CoefficientL = 0.0;
    double CoefficientH = 0.0;
    double ALtangent = 0.0;
    double BLtangent = 0.0;
    double CLtangent = 0.0;
    double AHtangent = 0.0;
    double BHtangent = 0.0;
    double CHtangent = 0.0;
    double ANormalLine = 0.0;
    double BNormalLine = 0.0;
    double CNormalLine = 0.0;
    double OrientationValue = 0.0;
    double AngleCos = 0.0;
    double Sum1 = 0.0;
    double Sum2 = 0.0;
    double Count2 = 0;
    double Count1 = 0;
    double Sum = 0.0;
    double Radius = EARTHRADIUS; //6378137.0,WGS84椭球半径
    int Count = (int)count;
    for (int i = 0; i < Count; i++) {
        if (i == 0) {
            LowX = coords[Count - 1].longitude *  M_PI/ 180;
            LowY = coords[Count - 1].latitude * M_PI / 180;
            MiddleX = coords[0].longitude * M_PI / 180;
            MiddleY = coords[0].latitude * M_PI / 180;
            HighX = coords[1].longitude * M_PI / 180;
            HighY = coords[1].latitude * M_PI / 180;
        }
        else if (i == Count - 1) {
            LowX = coords[Count - 2].longitude * M_PI / 180;
            LowY = coords[Count - 2].latitude * M_PI / 180;
            MiddleX = coords[Count - 1].longitude * M_PI / 180;
            MiddleY = coords[Count - 1].latitude * M_PI / 180;
            HighX = coords[0].longitude * M_PI / 180;
            HighY = coords[0].latitude * M_PI / 180;
        }
        else {
            LowX = coords[i - 1].longitude * M_PI / 180;
            LowY = coords[i - 1].latitude * M_PI / 180;
            MiddleX = coords[i].longitude * M_PI / 180;
            MiddleY = coords[i].latitude * M_PI / 180;
            HighX = coords[i + 1].longitude * M_PI / 180;
            HighY = coords[i + 1].latitude * M_PI / 180;
        }
        AM = cos(MiddleY) * cos(MiddleX);
        BM = cos(MiddleY) * sin(MiddleX);
        CM = sin(MiddleY);
        AL = cos(LowY) * cos(LowX);
        BL = cos(LowY) * sin(LowX);
        CL = sin(LowY);
        AH = cos(HighY) * cos(HighX);
        BH = cos(HighY) * sin(HighX);
        CH = sin(HighY);
        CoefficientL = (AM * AM + BM * BM + CM * CM) / (AM * AL + BM * BL + CM * CL);
        CoefficientH = (AM * AM + BM * BM + CM * CM) / (AM * AH + BM * BH + CM * CH);
        ALtangent = CoefficientL * AL - AM;
        BLtangent = CoefficientL * BL - BM;
        CLtangent = CoefficientL * CL - CM;
        AHtangent = CoefficientH * AH - AM;
        BHtangent = CoefficientH * BH - BM;
        CHtangent = CoefficientH * CH - CM;
        AngleCos = (AHtangent * ALtangent + BHtangent * BLtangent + CHtangent * CLtangent) / (sqrt(AHtangent * AHtangent + BHtangent * BHtangent + CHtangent * CHtangent) * sqrt(ALtangent * ALtangent + BLtangent * BLtangent + CLtangent * CLtangent));
        AngleCos = acos(AngleCos);
        ANormalLine = BHtangent * CLtangent - CHtangent * BLtangent;
        BNormalLine = 0 - (AHtangent * CLtangent - CHtangent * ALtangent);
        CNormalLine = AHtangent * BLtangent - BHtangent * ALtangent;
        if (AM != 0)
            OrientationValue = ANormalLine / AM;
        else if (BM != 0)
            OrientationValue = BNormalLine / BM;
        else
            OrientationValue = CNormalLine / CM;
        if (OrientationValue > 0) {
            Sum1 += AngleCos;
            Count1++;
        }
        else {
            Sum2 += AngleCos;
            Count2++;
        }
    }
    double tempSum1, tempSum2;
    tempSum1 = Sum1 + (2 * M_PI * Count2 - Sum2);
    tempSum2 = (2 * M_PI * Count1 - Sum1) + Sum2;
    if (Sum1 > Sum2) {
        if ((tempSum1 - (Count - 2) * M_PI) < 1)
            Sum = tempSum1;
        else
            Sum = tempSum2;
    }
    else {
        if ((tempSum2 - (Count - 2) * M_PI) < 1)
            Sum = tempSum2;
        else
            Sum = tempSum1;
    }
    totalArea = (Sum - (Count - 2) * M_PI) * Radius * Radius;
    
    totalArea = totalArea/666.6666;
    
    return totalArea; //返回总面积
}

@end
