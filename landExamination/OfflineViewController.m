//
//  OfflineViewController.m
//  landExamination
//
//  Created by das on 2017/1/13.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "OfflineViewController.h"
#import <MBProgressHUD.h>

@interface OfflineViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (strong, nonatomic) BMKOfflineMap *offlineMap;

//显示列表（0）或已下载（1）
@property (assign, nonatomic) NSInteger flag;
//热门城市
@property (strong, nonatomic) NSArray *arrayHotCityData;
//全部城市
@property (strong, nonatomic) NSArray *arrayOfflineCityData;
//本地下载的城市
@property (strong, nonatomic) NSMutableArray *arrayLocalDownLoaded;

@end

@implementation OfflineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //初始化离线地图服务
    _offlineMap = [[BMKOfflineMap alloc]init];
    //获取热门城市
    _arrayHotCityData = [_offlineMap getHotCityList];
    //获取支持离线下载城市列表
    _arrayOfflineCityData = [_offlineMap getOfflineCityList];
    //默认显示可下载列表
    _flag = 0;
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _offlineMap.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    _offlineMap.delegate = nil;
    _offlineMap = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)segmentAction:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            _flag = 0;
            [_tableView reloadData];
        }
            break;
        case 1:
        {
            _flag = 1;
            //获取各城市离线地图更新信息
            _arrayLocalDownLoaded = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
            [_tableView reloadData];
        }
            break;
            
        default:
            break;
    }

    
}


#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_flag == 0) {
        return 2;
    }else{
        return 1;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (_flag == 0) {
        
        NSString *provincName = @"";
        if (section == 0) {
            provincName = @"热门城市";
        }else if(section == 1){
            provincName = @"全国";
        }
        return provincName;
    }
    return nil;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_flag == 0) {
        if (section == 0) {
            return _arrayHotCityData.count;
        }else if (section == 1){
            return _arrayOfflineCityData.count;
        }else{
            return 0;
        }
    }else{
        
        return _arrayLocalDownLoaded.count;
        
    }
}

//定义cell样式填充数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"OfflineMapCityCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if(_flag == 0)
    {
        //热门城市列表
        if(indexPath.section==0)
        {
            BMKOLSearchRecord* item = [_arrayHotCityData objectAtIndex:indexPath.row];
//            cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
             cell.textLabel.text = [NSString stringWithFormat:@"%@", item.cityName];
            //转换包大小
            NSString*packSize = [self getDataSizeString:item.size];
            UILabel *sizelabel =[[UILabel alloc] initWithFrame:CGRectMake(250, 0, 60, 40)];
            sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            sizelabel.text = @"";
            sizelabel.backgroundColor = [UIColor clearColor];
            cell.accessoryView = sizelabel;
            
        }
        //支持离线下载城市列表
        else if(indexPath.section==1)
        {
            BMKOLSearchRecord* item = [_arrayOfflineCityData objectAtIndex:indexPath.row];
//            cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", item.cityName];
            //转换包大小
            NSString*packSize = [self getDataSizeString:item.size];
            UILabel *sizelabel =[[UILabel alloc] initWithFrame:CGRectMake(250, 0, 60, 40)];
            sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            sizelabel.text = @"";
            sizelabel.backgroundColor = [UIColor clearColor];
            cell.accessoryView = sizelabel;
            
        }
    }
    else
    {
        if(_arrayLocalDownLoaded!=nil&&_arrayLocalDownLoaded.count>indexPath.row)
        {
            BMKOLUpdateElement* item = [_arrayLocalDownLoaded objectAtIndex:indexPath.row];
            //是否可更新
            if(item.update)
            {
                cell.textLabel.text = [NSString stringWithFormat:@"%@————%d(可更新)", item.cityName,item.ratio];
            }
            else
            {
                cell.textLabel.text = [NSString stringWithFormat:@"%@————%d", item.cityName,item.ratio];
            }
            
            NSString*packSize = [self getDataSizeString:item.size];
            UILabel *sizelabel =[[UILabel alloc] initWithFrame:CGRectMake(250, 0, 60, 40)];
            sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            sizelabel.text = packSize;
            sizelabel.backgroundColor = [UIColor clearColor];
            cell.accessoryView = sizelabel;

        }
        else
        {
            cell.textLabel.text = @"";
        }
        
    }
    
    return cell;
}

//是否允许table进行编辑操作
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_flag == 0)
    {
        return YES;
    }
    else
    {
        return YES;
    }
}
//侧滑动作
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewRowAction *action;
    if (_flag == 0) {
        action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"下载" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            //热门城市下载
            if(indexPath.section==0)
            {
                BMKOLSearchRecord* item = [_arrayHotCityData objectAtIndex:indexPath.row];
                [_offlineMap start:item.cityID];
                
            }
            //所有城市下载
            else if(indexPath.section==1)
            {
                BMKOLSearchRecord* item = [_arrayOfflineCityData objectAtIndex:indexPath.row];
                [_offlineMap start:item.cityID];
            }
            [self.segmentControl setSelectedSegmentIndex:1];
            [self segmentAction:self.segmentControl];
        }];
    }else{
        
        action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            
            BMKOLUpdateElement* item = [_arrayLocalDownLoaded objectAtIndex:indexPath.row];
            //删除指定城市id的离线地图
            [_offlineMap remove:item.cityID];
            //将此城市的离线地图信息从数组中删除
            [(NSMutableArray*)_arrayLocalDownLoaded removeObjectAtIndex:indexPath.row];
            [_tableView reloadData];

        }];
        
    }
    
    return @[action];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - BMKOfflineMapDelegate
//离线地图delegate，用于获取通知
- (void)onGetOfflineMapState:(int)type withState:(int)state
{
    
    if (type == TYPE_OFFLINE_UPDATE) {
        //id为state的城市正在下载或更新，start后会毁掉此类型
        BMKOLUpdateElement* updateInfo;
        updateInfo = [_offlineMap getUpdateInfo:state];
        NSLog(@"城市名：%@,下载比例:%d",updateInfo.cityName,updateInfo.ratio);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (_flag == 1) {
                
                _arrayLocalDownLoaded = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
                
//                NSMutableArray *indexpaths = [NSMutableArray array];
                
                for (int i=0 ; i<_arrayLocalDownLoaded.count; i++) {
                    BMKOLUpdateElement *element = _arrayLocalDownLoaded[i];
                    if (element.status != 4) {
                        
                        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
                        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexpath];
                        
                        cell.textLabel.text = [NSString stringWithFormat:@"%@————%d", element.cityName,element.ratio];
                        
                        
//                        [indexpaths addObject:indexpath];
                    }
                }
                
//                [_tableView reloadRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationNone];
                
//                [_tableView reloadData];

            }
            
        });
        
    }
    if (type == TYPE_OFFLINE_NEWVER) {
        //id为state的state城市有新版本,可调用update接口进行更新
        BMKOLUpdateElement* updateInfo;
        updateInfo = [_offlineMap getUpdateInfo:state];
        NSLog(@"是否有更新%d",updateInfo.update);
    }
    if (type == TYPE_OFFLINE_UNZIP) {
        //正在解压第state个离线包，导入时会回调此类型
    }
    if (type == TYPE_OFFLINE_ZIPCNT) {
        //检测到state个离线包，开始导入时会回调此类型
        NSLog(@"检测到%d个离线包",state);
        if(state==0)
        {
            [self showImportMesg:state];
        }
    }
    if (type == TYPE_OFFLINE_ERRZIP) {
        //有state个错误包，导入完成后会回调此类型
        NSLog(@"有%d个离线包导入错误",state);
    }
    if (type == TYPE_OFFLINE_UNZIPFINISH) {
        NSLog(@"成功导入%d个离线包",state);
        //导入成功state个离线包，导入成功后会回调此类型
        [self showImportMesg:state];
    }
    
}

//导入提示框
- (void)showImportMesg:(int)count
{
    NSString* showmeg = [NSString stringWithFormat:@"成功导入离线地图包个数:%d", count];
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"导入离线地图" message:showmeg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
    [myAlertView show];
}




#pragma mark 包大小转换工具类（将包大小转换成合适单位）
-(NSString *)getDataSizeString:(int) nSize
{
    NSString *string = nil;
    if (nSize<1024)
    {
        string = [NSString stringWithFormat:@"%dB", nSize];
    }
    else if (nSize<1048576)
    {
        string = [NSString stringWithFormat:@"%dK", (nSize/1024)];
    }
    else if (nSize<1073741824)
    {
        if ((nSize%1048576)== 0 )
        {
            string = [NSString stringWithFormat:@"%dM", nSize/1048576];
        }
        else
        {
            int decimal = 0; //小数
            NSString* decimalStr = nil;
            decimal = (nSize%1048576);
            decimal /= 1024;
            
            if (decimal < 10)
            {
                decimalStr = [NSString stringWithFormat:@"%d", 0];
            }
            else if (decimal >= 10 && decimal < 100)
            {
                int i = decimal / 10;
                if (i >= 5)
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 1];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 0];
                }
                
            }
            else if (decimal >= 100 && decimal < 1024)
            {
                int i = decimal / 100;
                if (i >= 5)
                {
                    decimal = i + 1;
                    
                    if (decimal >= 10)
                    {
                        decimal = 9;
                    }
                    
                    decimalStr = [NSString stringWithFormat:@"%d", decimal];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", i];
                }
            }
            
            if (decimalStr == nil || [decimalStr isEqualToString:@""])
            {
                string = [NSString stringWithFormat:@"%dMss", nSize/1048576];
            }
            else
            {
                string = [NSString stringWithFormat:@"%d.%@M", nSize/1048576, decimalStr];
            }
        }
    }
    else	// >1G
    {
        string = [NSString stringWithFormat:@"%dG", nSize/1073741824];
    }
    
    return string;
}


@end
