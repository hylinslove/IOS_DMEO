//
//  PasswordResetViewController.m
//  landExamination
//
//  Created by das on 2017/3/2.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import "PasswordResetViewController.h"
#import "ServiceManager.h"
#import <SVProgressHUD.h>

@interface PasswordResetViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordVerifyTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation PasswordResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"修改密码";
    _confirmBtn.layer.cornerRadius = 4;
    _confirmBtn.layer.masksToBounds = YES;
}
- (IBAction)confirmBtnAction:(id)sender {
    
    
    if (![_passwordTextField.text isEqualToString:_passwordVerifyTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"两次密码输入不一致"];
        [SVProgressHUD dismissWithDelay:1.5];
    }else{
        [SVProgressHUD showErrorWithStatus:@"更改中"];
        [[ServiceManager sharedManger] modifyPasswordPhonenumber:_phonenumber password:_passwordTextField.text success:^(NSDictionary *responseOBJ) {
            NSString *state = responseOBJ[@"success"];
            if ([state isEqualToString:@"true"]) {
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                [SVProgressHUD dismissWithDelay:1.5];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }else if ([state isEqualToString:@"false"]){
                [SVProgressHUD showErrorWithStatus:responseOBJ[@"msg"]];
                [SVProgressHUD dismissWithDelay:1.5];
            }

        } failure:^(NSError *error) {
            
            [SVProgressHUD showErrorWithStatus:@"网络错误"];
            [SVProgressHUD dismissWithDelay:1.5];

        }];
        
        
    }
    
    
    
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
