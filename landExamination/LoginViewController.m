//
//  LoginViewController.m
//  landExamination
//
//  Created by xianglong on 2017/9/22.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "LoginViewController.h"
#import "ServiceManager.h"
#import "AppDelegate.h"
#import "MacroDefine.h"
#import <SVProgressHUD.h>
#import "MainViewController.h"
#import "RegisterViewController.h"
#import "InfoFillViewController.h"

@interface LoginViewController ()<UINavigationControllerDelegate,BMKLocationServiceDelegate>
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)doLogin:(id)sender;
- (IBAction)registerAction:(id)sender;
- (IBAction)forgetAction:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //隐藏导航栏
    self.navigationController.delegate = self;
    [self getLonginInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

- (IBAction)doLogin:(id)sender {
    [SVProgressHUD show];
    //登录请求
    [[ServiceManager sharedManger] userLogin:_account.text password:_password.text success:^(NSDictionary *responseObj) {
        [SVProgressHUD dismiss];
    
        
        @try {
            
            //success的值为true时登录成功 跳转到任务列表   否则提示登录失败
            if ([responseObj[@"success"] isEqualToString:@"true"]) {
                //登录成功将用户数据存入delegate中
                AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                delegate.xzqhStr = responseObj[@"msg"];
                delegate.userName = _account.text;
                delegate.psw = _password.text;
                [self saveLonginInfo];
                
                //启动定位并回传至服务器
                delegate.locRecoder = [NSTimer scheduledTimerWithTimeInterval:5 target:delegate selector:@selector(uploadLocation) userInfo:nil repeats:YES];
                [self.navigationController pushViewController:[MainViewController alloc] animated:YES];
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:responseObj[@"msg"] delegate:NULL cancelButtonTitle:@"确定" otherButtonTitles:NULL, nil];
                [alert show];
                
            }
            
        }
        @catch (NSException *exception) {
            // 捕获到的异常exception
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:@"请检查网络情况" delegate:NULL cancelButtonTitle:@"确定" otherButtonTitles:NULL, nil];
            [alert show];
            return ;
        }
        
    } failure:^(NSError *err) {
        [SVProgressHUD dismiss];
        //        [hud hideAnimated:YES];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:[NSString stringWithFormat:@"请检查网络情况"] delegate:NULL cancelButtonTitle:@"确定" otherButtonTitles:NULL, nil];
        [alert show];
        
    }];

}
//注册用户
- (IBAction)registerAction:(id)sender {
    RegisterViewController *registerVC = [[RegisterViewController alloc]init];
    registerVC.isRegister = YES;
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:registerVC];
    [self presentViewController:navi animated:YES completion:nil];
}
//忘记密码
- (IBAction)forgetAction:(id)sender {
    RegisterViewController *registerVC = [[RegisterViewController alloc]init];
    registerVC.isRegister = NO;
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:registerVC];
    [self presentViewController:navi animated:YES completion:nil];
}

//保存登录信息
- (void)saveLonginInfo{
    [mUserDefaults setObject:_account.text forKey:@"userName"];
    [mUserDefaults setObject:_password.text forKey:@"password"];
    
    
}
//初始化登录信息
- (void)getLonginInfo{
    _account.text = [mUserDefaults objectForKey:@"userName"];
    _password.text = [mUserDefaults objectForKey:@"password"];
    
}
@end



















