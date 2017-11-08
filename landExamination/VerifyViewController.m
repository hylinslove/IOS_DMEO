//
//  VerifyViewController.m
//  landExamination
//
//  Created by das on 2017/3/2.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import "VerifyViewController.h"
#import "PZXVerificationCodeView.h"
#import "InfoFillViewController.h"
#import "ServiceManager.h"
#import "PasswordResetViewController.h"
#import <SVProgressHUD.h>

@interface VerifyViewController ()
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet PZXVerificationCodeView *verifyView;
@property (weak, nonatomic) IBOutlet UIButton *verfyBtn;

@end

@implementation VerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"请输入验证码";
    self.infoLabel.text = [NSString stringWithFormat:@"验证码已发送至：%@",_phoneNumber];
    _verfyBtn.layer.cornerRadius = 4;
    _verfyBtn.layer.masksToBounds = YES;
}
- (IBAction)verifyBtnAction:(id)sender {
    
    NSArray *arr = _verifyView.textFieldArray;
    for (UITextField *tf in arr) {
        [tf resignFirstResponder];
    }
    
    [SVProgressHUD showWithStatus:@"验证中"];
    
    [[ServiceManager sharedManger] verifyPhonenumber:_phoneNumber verification:_verifyView.vertificationCode success:^(NSDictionary *responseOBJ) {
        NSString *state = responseOBJ[@"success"];
        if ([state isEqualToString:@"true"]) {
            [SVProgressHUD dismiss];
            if (_isRegister) {
                //推出信息填写
                InfoFillViewController *infoFillVC = [[InfoFillViewController alloc]init];
                infoFillVC.phoneNumber = _phoneNumber;
                [self.navigationController pushViewController:infoFillVC animated:YES];
            }else{
                
                PasswordResetViewController *modifyVC = [[PasswordResetViewController alloc]init];
                modifyVC.phonenumber = _phoneNumber;
                [self.navigationController pushViewController:modifyVC animated:YES];
            }
            
        }else if ([state isEqualToString:@"false"]){
            [SVProgressHUD showErrorWithStatus:responseOBJ[@"msg"]];
            [SVProgressHUD dismissWithDelay:1.5];
            
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络错误"];
        [SVProgressHUD dismissWithDelay:1.5];

    }];
    
    
    
    
    
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

@end
