//
//  NoticeViewController.m
//  landExamination
//
//  Created by xianglong on 2017/10/23.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "NoticeViewController.h"
#import "AppDelegate.h"
#import "NoticeCell.h"

@interface NoticeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NoticeViewController{
    NSArray *deleteTasks;
    NSArray *backTasks;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //获取app代理
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    deleteTasks = delegate.deleteTasks;
    backTasks = delegate.backTasks;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    NSLog(@"**************************DELETE COUNT :%ld",(long)deleteTasks.count);
    if(section == 0) {
        return backTasks.count;
    } else {
        return deleteTasks.count;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0) {
        return @"回退通知";
    } else{
        return @"删除通知";
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
//    if(deleteTasks.count == 0 && backTasks.count == 0) {
//        return 0;
//    } else if (deleteTasks.count>0 && backTasks.count == 0) {
//        return 1;
//    } else if(backTasks.count>0 && deleteTasks.count ==0){
//        return 1;
//    } else {
//        return 2;
//    }
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NoticeCell *cell = [NoticeCell cell];
    if(indexPath.section == 0) {
        [cell setMisson:[backTasks objectAtIndex:indexPath.row] withType:indexPath.section];
    } else {
        [cell setMisson:[deleteTasks objectAtIndex:indexPath.row] withType:indexPath.section];
    }
    [cell setMisson:[deleteTasks objectAtIndex:indexPath.row] withType:indexPath.section];
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}




@end
