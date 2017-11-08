//
//  MainViewController.m
//  landExamination
//
//  Created by xianglong on 2017/9/22.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "MainViewController.h"
#import "TaskViewController.h"
#import "UIColor+ColorChange.h"
#import "NoticeViewController.h"

#import "AppDelegate.h"

@interface MainViewController ()
- (IBAction)todo:(id)sender;
- (IBAction)doing:(id)sender;
- (IBAction)done:(id)sender;

- (IBAction)search:(id)sender;
- (IBAction)warn:(id)sender;
- (IBAction)setting:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *noticeLable;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"主页"];
    
    //设置导航栏按钮颜色
    self.navigationController.navigationBar.tintColor  = [UIColor whiteColor];
    //设置导航栏标题颜色
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //设置导航栏背景颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorwithHexString:@"318cff"]];
    //初始化消息通知
    [self initNoticeLable];
    
}
-(void)viewWillAppear:(BOOL)animated{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    long totalNotice = delegate.backTasks.count+delegate.deleteTasks.count;
    
    if(totalNotice>0) {
        _noticeLable.text = [NSString stringWithFormat:@"%ld",totalNotice];
        _noticeLable.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)todo:(id)sender {
    TaskViewController *taskVC = [[TaskViewController alloc] init];
    taskVC.taskType = 0;
    [self.navigationController pushViewController:[TaskViewController alloc] animated:YES];
    
}

- (IBAction)doing:(id)sender {
    TaskViewController *taskVC = [[TaskViewController alloc] init];
    taskVC.taskType = 1;
    [self.navigationController pushViewController:taskVC animated:YES];
    
}

- (IBAction)done:(id)sender {
    TaskViewController *taskVC = [[TaskViewController alloc] init];
    taskVC.taskType = 2;
    [self.navigationController pushViewController:taskVC animated:YES];
}

- (IBAction)search:(id)sender {
    
}

- (IBAction)warn:(id)sender {
    [self.navigationController pushViewController:[NoticeViewController alloc] animated:YES];
}

- (IBAction)setting:(id)sender {
    
}

-(void)initNoticeLable{
    _noticeLable.layer.cornerRadius = _noticeLable.bounds.size.width/2;
    _noticeLable.layer.masksToBounds = YES;
}
@end
