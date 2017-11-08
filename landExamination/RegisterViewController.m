//
//  RegisterViewController.m
//  landExamination
//
//  Created by das on 2017/3/1.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import "RegisterViewController.h"
#import "VerifyViewController.h"
#import "ServiceManager.h"
#import <SVProgressHUD.h>
#import "TTTAttributedLabel.h"
#import "YYText.h"
#import "MacroDefine.h"
#import "DocViewController.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phonenumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet YYLabel *attributeLabel;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"请输入手机号";
    _nextBtn.layer.cornerRadius = 4;
    _nextBtn.layer.masksToBounds = YES;
    
    [self setNavi];
    __weak typeof(self) _self = self;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
    
    NSMutableAttributedString * firstPart = [[NSMutableAttributedString alloc] initWithString:@"点击上面的按钮'下一步'\n\n即表示您同意"];
    firstPart.yy_color = [UIColor blackColor];
    [text appendAttributedString:firstPart];
    
    NSMutableAttributedString * secondPart = [[NSMutableAttributedString alloc] initWithString:@"《服务协议》"];
    secondPart.yy_underlineStyle = NSUnderlineStyleSingle;
    [secondPart yy_setTextHighlightRange:secondPart.yy_rangeOfAll color:[UIColor blueColor] backgroundColor:[UIColor colorWithWhite:0.000 alpha:0.220] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
    
        [_self presentDocVC:@"fwxy.htm"];
        
    }];
    
    [text appendAttributedString:secondPart];

    NSMutableAttributedString * thirdPart = [[NSMutableAttributedString alloc] initWithString:@"和"];
    thirdPart.yy_color = [UIColor blackColor];
    [text appendAttributedString:thirdPart];
    
     NSMutableAttributedString * forthPart = [[NSMutableAttributedString alloc] initWithString:@"《隐私政策》"];
    forthPart.yy_underlineStyle = NSUnderlineStyleSingle;
    [forthPart yy_setTextHighlightRange:forthPart.yy_rangeOfAll color:[UIColor blueColor] backgroundColor:[UIColor colorWithWhite:0.000 alpha:0.220] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        
        [_self presentDocVC:@"yszc.htm"];
        
    }];
    [text appendAttributedString:forthPart];
    
    _attributeLabel.attributedText = text;
    _attributeLabel.numberOfLines = 0;
    _attributeLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    _attributeLabel.textAlignment = NSTextAlignmentCenter;
    
    
}

- (void)presentDocVC:(NSString *)text{
    
    DocViewController *doc = [[DocViewController alloc]init];
    doc.docName = text;
    [self presentViewController:doc animated:YES completion:nil];
    
}



- (void)setNavi{
    
    UIColor *color = [UIColor clearColor];
    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.clipsToBounds = YES;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    
    self.navigationItem.leftBarButtonItem = item;
    
}

- (void)dismiss:(id)sender{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)nextBtnAction:(id)sender {
    [SVProgressHUD showWithStatus:@"验证码获取中"];
    
    [[ServiceManager sharedManger] getVerificationWithPhonenumber:_phonenumberTextField.text success:^(NSDictionary *responseOBJ) {
        
        NSString *state = responseOBJ[@"success"];
        if ([state isEqualToString:@"true"]) {
            [SVProgressHUD dismiss];
 //推出验证码输入
            VerifyViewController *verifyVC = [[VerifyViewController alloc]init];
            verifyVC.phoneNumber = _phonenumberTextField.text;
            verifyVC.isRegister = _isRegister;
            [self.navigationController pushViewController:verifyVC animated:YES];
            
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
