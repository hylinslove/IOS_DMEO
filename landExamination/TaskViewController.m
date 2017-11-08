//
//  TaskViewController.m
//  landExamination
//
//  Created by xianglong on 2017/9/27.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "TaskViewController.h"
#import "TaskTableViewCell.h"
#import "ServiceManager.h"
#import "SQLManager.h"
#import "AppDelegate.h"
#import "MissionModel.h"
#import <MJExtension.h>
#import "MapViewController.h"

@interface TaskViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *taskTable;

@property (readwrite,nonatomic) NSInteger currentTask;
@property (strong, nonatomic) NSArray *tableViewDataArr;

@property (strong, nonatomic) NSArray *dhcArr;
@property (strong ,nonatomic) NSArray *yhcArr;
@property (strong, nonatomic) NSArray *doneArr;
@property (strong, nonatomic) NSArray *searchResultArr;

@property (assign, nonatomic) NSInteger showFlag;
@end

@implementation TaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //防止导航栏遮挡控件
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _currentTask = -1;
    switch (_taskType) {
        case 0:
            [self setTitle:@"待办任务"];
            //获取任务
            [self getMission];
            break;
        case 1:
            [self setTitle:@"已核查"];
            break;
        case 2:
            [self setTitle:@"已回传"];
            break;
        default:
            [self setTitle:@"待办任务"];
            break;
    }
    
    
    [_taskTable setDelegate:self];
    [_taskTable setDataSource:self];
    _taskTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _showFlag = 0;
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self getTasksFromSQL];
    
    [super viewWillAppear:animated];
    
}

//服务器端获取任务
- (void)getMission{
    AppDelegate *delegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    [[ServiceManager sharedManger] getMissionWithUsername:delegate.userName andXZQMC:delegate.xzqhStr success:^(NSArray *responseOBJ) {
        //将获取到的数据处理为model数组
        NSArray *dataArr = [MissionModel mj_objectArrayWithKeyValuesArray:responseOBJ];
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        for (MissionModel *model in dataArr) {
            model.XZQH = delegate.xzqhStr;
        }
        
        //请求完毕写入数据库
        [[SQLManager sharedManager] writeToSQLTaskArr:dataArr withGXNumber:^(NSInteger gxts) {
            if (gxts!=0) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"新增任务" message:[NSString stringWithFormat:@"%ld条",(long)gxts] delegate:NULL cancelButtonTitle:@"确定" otherButtonTitles:NULL, nil];
                [alert show];
            }
            //更新任务hczt
            [self getTasksFromSQL];
            
        }];
        
        
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"获取任务列表失败" message:[NSString stringWithFormat:@"网络请求失败"] delegate:NULL cancelButtonTitle:@"确定" otherButtonTitles:NULL, nil];
        [alert show];
        [self getTasksFromSQL];
    }];
    
}

//数据库获取数据
- (void)getTasksFromSQL{
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *dhcStr = [NSString stringWithFormat:@"SELECT * FROM WPTASK WHERE (HCZT ISNULL OR HCZT <> 1) AND (HCZTSTATS = 0 OR HCZTSTATS ISNULL) AND XZQH = '%@'",delegate.xzqhStr] ;
    //    NSString *dhcStr = [NSString stringWithFormat:@"SELECT * FROM WPTASK WHERE (HCZT ISNULL OR HCZT <> 1) AND (HCZTSTATS = 0 OR HCZTSTATS ISNULL)"];
    NSString *yhcStr = [NSString stringWithFormat:@"SELECT * FROM WPTASK WHERE HCZTSTATS = '1' AND XZQH = '%@'",delegate.xzqhStr] ;
    NSString *doneStr = [NSString stringWithFormat:@"SELECT * FROM WPTASK WHERE HCZTSTATS = '2' AND XZQH = '%@'",delegate.xzqhStr] ;
    
    _dhcArr = [[SQLManager sharedManager] getTasksWithSQLStr:dhcStr];
    _yhcArr = [[SQLManager sharedManager] getTasksWithSQLStr:yhcStr];
    _doneArr = [[SQLManager sharedManager] getTasksWithSQLStr:doneStr];
    
    [self.taskTable reloadData];
}

//跳转至地图界面
-(void)turnToMap:(UIButton *)sender{
    TaskTableViewCell *myCell = (TaskTableViewCell *)sender.superview.superview;
    NSString *taskID = [myCell.TDBHLb text];
    
    MapViewController *mapVC  = [[MapViewController alloc] init];
    mapVC.taskID = taskID;
    
    [self.navigationController pushViewController:mapVC animated:YES];
    
}

//tableView 协议
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    switch (_taskType) {
        case 0:
            return [_dhcArr count];
            break;
        case 1:
            return [_yhcArr count];
            break;
        case 2:
            return [_doneArr count];
            break;
        default:
            return [_dhcArr count];
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == _currentTask) {
        return 400;
    } else {
        return 47;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TaskTableViewCell *myCell = [TaskTableViewCell cell];
    myCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (_taskType) {
        case 0:
            [myCell setMissionModel:_dhcArr[indexPath.row] number:indexPath.row+1];
            break;
        case 1:
            [myCell setMissionModel:_yhcArr[indexPath.row] number:indexPath.row+1];
            break;
        case 2:
            [myCell setMissionModel:_doneArr[indexPath.row] number:indexPath.row+1];
            break;
        default:
            [myCell setMissionModel:_dhcArr[indexPath.row] number:indexPath.row+1];
            break;
    }

    if(indexPath.row == _currentTask) {
        [myCell showContent];
    }
    
    [myCell.toCheck addTarget:self action:@selector(turnToMap:) forControlEvents:UIControlEventTouchUpInside];
    
    return myCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == _currentTask){
        _currentTask =-1;
    } else{
        _currentTask = indexPath.row;
    }
    
    [_taskTable reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
