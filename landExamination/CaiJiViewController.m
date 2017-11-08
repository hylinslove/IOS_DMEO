//
//  CaiJiViewController.m
//  landExamination
//
//  Created by xianglong on 2017/10/19.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "CaiJiViewController.h"
#import "Coor.h"
@interface CaiJiViewController ()
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *caijiBtn;
@property (weak, nonatomic) IBOutlet UIButton *chexiaoBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
- (IBAction)GPS:(id)sender;
- (IBAction)chexiaoAction:(id)sender;
- (IBAction)clearAction:(id)sender;
- (IBAction)saveAction:(id)sender;


@property (strong, nonatomic) SQLManager *sql;
@property (strong, nonatomic) NSMutableArray *zbsArr;
@property (strong, nonatomic) NSMutableString *zbs;
@property (strong, nonatomic) Coor *coorTmp;
//定位服务
@property (strong, nonatomic) BMKLocationService *locService;
//图斑标记
@property (strong, nonatomic) BMKPolygon *polygon;
@end

@implementation CaiJiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _zbsArr = [NSMutableArray array];
    _zbs = [NSMutableString string];
    
    _sql = [SQLManager sharedManager];
    
    _locService = [[BMKLocationService alloc]init];
    
    _mapView.zoomLevel = 15;
    _mapView.showMapScaleBar = YES;
    _mapView.mapScaleBarPosition = CGPointMake(8, 20);
    
    self.title = @"点击采集按钮采集点";
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _locService.delegate = self;
    
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
    
    [super viewWillAppear:animated];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请采集三个点以上" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [_locService stopUserLocationService];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _locService.delegate = nil;
    
    [super viewWillDisappear:animated];
}


- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    
    
    BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
    //绘制线的颜色
    polygonView.strokeColor = [[UIColor alloc] initWithRed:0.0 green:0 blue:0.5 alpha:1];
    //填充的颜色
    polygonView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:0.2];
    //绘制线的宽度
    polygonView.lineWidth =1.0;
    //是否是虚线
    polygonView.lineDash = NO;
    return polygonView;
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        return [(RouteAnnotation*)annotation getRouteAnnotationView:mapView];
    }
    //普通annotation
    NSString *AnnotationViewID = @"renameMark";
    BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        // 设置颜色
        annotationView.pinColor = BMKPinAnnotationColorRed;
        // 设置可拖拽
        annotationView.draggable = NO;
    }
    return annotationView;
    
}
/**
 *点中底图标注后会回调此接口
 *@param mapview 地图View
 *@param mapPoi 标注点信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi
{
    
    [self addPoint:mapPoi.pt];
    
}
/**
 *点中底图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    
    [self addPoint:coordinate];
    
}


#pragma mark - locationServiceDelegate

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)GPS:(id)sender {
    CLLocationCoordinate2D coor = _locService.userLocation.location.coordinate;
    Coor *coorObj = [Coor initWith:coor];
    _coorTmp = coorObj;
    [_zbsArr addObject:coorObj];
    
    self.title = [NSString stringWithFormat:@"已采集%lu个点",(unsigned long)_zbsArr.count];
    
    [self refreshAnnotation];
}

- (IBAction)chexiaoAction:(id)sender {
    [_zbsArr removeLastObject];
    self.title = [NSString stringWithFormat:@"已采集%lu个点",(unsigned long)_zbsArr.count];
    [self refreshAnnotation];
}

- (IBAction)clearAction:(id)sender {
    //清空做提示需要确认清空
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否需要清空" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"清空" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [_zbsArr removeAllObjects];
        self.title = [NSString stringWithFormat:@"已采集%lu个点",(unsigned long)_zbsArr.count];
        [self refreshAnnotation];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:yesAction];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)saveAction:(id)sender {
    if (_zbsArr.count < 3) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"需采集三个点以上" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self saveZbs];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addPoint:(CLLocationCoordinate2D )coor{
    
    Coor *coorObj = [Coor initWith:coor];
    _coorTmp = coorObj;
    [_zbsArr addObject:coorObj];
    self.title = [NSString stringWithFormat:@"已采集%lu个点",(unsigned long)_zbsArr.count];
    [self refreshAnnotation];
    
}


- (void)saveZbs{
    
    for (int i =0; i<_zbsArr.count; i++) {
        Coor *coorObj = _zbsArr[i];
        if (i == _zbsArr.count-1) {
            [_zbs appendFormat:@"%f,%f;",coorObj.lon,coorObj.lat];
            continue;
        }
        [_zbs appendFormat:@"%f,%f;",coorObj.lon,coorObj.lat];
    }
    Coor *coorObj = _zbsArr[0];
    [_zbs appendFormat:@"%f,%f",coorObj.lon,coorObj.lat];
    
    NSLog(@"zbs-------------:%@",_zbs);
    
    [_sql updateGuid:_guid SHAPEWithZbs:_zbs];
    
    
    
    
    
}


- (void)refreshAnnotation{
    
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    //移除图斑
    [_mapView removeOverlays:array];
    //大头针位置
    for (Coor *coorObj in _zbsArr) {
        
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(coorObj.lat, coorObj.lon);
        
        BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
        pointAnnotation.coordinate = coor;
        pointAnnotation.title = @"";

        //添加大头针
        [_mapView addAnnotation:pointAnnotation];
    }
    
    //有三个以上点时显示范围
    if (_zbsArr.count>2) {
        
        //多边形覆盖物
//        CLLocationCoordinate2D * coords = new CLLocationCoordinate2D[_zbsArr.count];
        //malloc(gpsPoints.count*sizeof(CLLocationCoordinate2D));
        
        CLLocationCoordinate2D *coords = malloc(_zbsArr.count * sizeof(CLLocationCoordinate2D));
        
        for (int i = 0 ; i<_zbsArr.count; i++) {
            
            Coor *coorObj=_zbsArr[i];
            coords[i] = CLLocationCoordinate2DMake(coorObj.lat, coorObj.lon);
        }
        _polygon = [BMKPolygon polygonWithCoordinates:coords count:_zbsArr.count];
        
        [_mapView addOverlay:_polygon];
    }
    
}


@end
