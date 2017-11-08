//
//  InfoFillViewController.m
//  landExamination
//
//  Created by das on 2017/3/2.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import "InfoFillViewController.h"
#import "ServiceManager.h"
#import <SVProgressHUD.h>
#define FirstComponent 0
#define SubComponent 1
#define ThirdComponent 2
@interface InfoFillViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *xzqhTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UITextField *organizationTextField;
@property (weak, nonatomic) IBOutlet UITextField *jobTextField;
@property(nonatomic,retain)NSDictionary* dict;
@property(nonatomic,retain)NSArray* pickerArray;
@property(nonatomic,retain)NSArray* subPickerArray;
@property(nonatomic,retain)NSArray* thirdPickerArray;
@property(nonatomic,retain)NSDictionary* thirdPickerDic;
@property(nonatomic,retain)NSArray* selectArray;
- (IBAction)setCode:(id)sender;

@end

@implementation InfoFillViewController {
    BOOL _isSettingCode;
    NSInteger _cityIndex;
    NSInteger _countyIndex;
    NSString *provinceIndex;
}
@synthesize dict=_dict;

@synthesize pickerArray=_pickerArray;
@synthesize subPickerArray=_subPickerArray;
@synthesize thirdPickerArray=_thirdPickerArray;
@synthesize thirdPickerDic=_thirdPickerDic;
@synthesize selectArray=_selectArray;
typedef enum _DATEPICKER_TAG
{
    BG_VIEW_TAG = 1000,
    SELECT_SITE_TAG,
    CANCEL_BTN_TAG,
    COMFIRM_BTN_TAG,
    PICKERVIEW_TAG,
}DATEPICKER_TAG;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"填写信息";
    _phoneNumberTextField.text = _phoneNumber;
    _registerBtn.layer.cornerRadius = 4;
    _registerBtn.layer.masksToBounds = YES;

    [_xzqhTextField setDelegate:self];
    _isSettingCode = NO;
    
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"Address" ofType:@"plist"];
    
    _dict=[[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    _pickerArray = [[NSArray alloc] initWithObjects:@"江苏省",@"安徽省",@"江西省", nil];

}
- (IBAction)registerBtnAction:(id)sender {
    
    if (_phoneNumberTextField.text.length == 0 || _passwordTextField.text.length == 0 || _nameTextField.text.length == 0 || _xzqhTextField.text.length == 0 || _organizationTextField.text.length == 0 || _jobTextField.text.length == 0) {
        [SVProgressHUD showWithStatus:@"请填写完整信息"];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"注册中"];
    [[ServiceManager sharedManger] registerWithUsername:_phoneNumberTextField.text password:_passwordTextField.text fullname:_nameTextField.text xzqh:_xzqhTextField.text organization:_organizationTextField.text job:_jobTextField.text success:^(NSDictionary *responseOBJ) {
        NSString *state = responseOBJ[@"success"];
        if ([state isEqualToString:@"true"]) {
            [SVProgressHUD showSuccessWithStatus:@"注册成功"];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(_isSettingCode) {
        [self updateAreaList:0 inComponent:0];
        [self updateAreaList:0 inComponent:1];
        
        [self.view endEditing:YES];
        [self showPicker];
        
        _isSettingCode = NO;
        
        [self pause];
    }
    
    return NO;
}



- (IBAction)setCode:(id)sender {
    _isSettingCode = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component==FirstComponent) {
        return [self.pickerArray count];
    }
    if (component==SubComponent) {
        return [self.subPickerArray count];
    }
    if (component==ThirdComponent) {
        return [self.thirdPickerArray count];
    }
    return 0;
}
#pragma mark--
#pragma mark--UIPickerViewDelegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component==FirstComponent) {
        return [self.pickerArray objectAtIndex:row];
    }
    if (component==SubComponent) {
        return [self.subPickerArray objectAtIndex:row];
    }
    if (component==ThirdComponent) {
        return [self.thirdPickerArray objectAtIndex:row];
    }
    return nil;
    
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    [self updateAreaList:row inComponent:component];
    if (component==0) {

        [pickerView selectedRowInComponent:1];
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectedRowInComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
        
    }
    if (component==1) {

        [pickerView selectedRowInComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
    }
    
    
    [pickerView reloadComponent:2];
    
}



- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component==FirstComponent) {
        return 90.0;
    }
    if (component==SubComponent) {
        return 90.0;
    }
    if (component==ThirdComponent) {
        return 120.0;
    }
    return 0;
}


- (void)showPicker {
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 162 - 44,self.view.frame.size.width, 206)];
    bgView.tag = BG_VIEW_TAG;
    bgView.backgroundColor = [UIColor colorWithRed:227/255.0f green:227/255.0f blue:227/255.0f alpha:1];
    
    UIButton *comfirmBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    comfirmBtn.tag = COMFIRM_BTN_TAG;
    comfirmBtn.frame = CGRectMake(bgView.frame.size.width - 60 - 15, 7, 60, 30);
    [comfirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [comfirmBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [comfirmBtn addTarget:self action:@selector(comfirmOrCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:comfirmBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelBtn.tag = CANCEL_BTN_TAG;
    cancelBtn.frame = CGRectMake(15, 7, 60, 30);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(comfirmOrCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:cancelBtn];
    
    
    UIPickerView *datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, [[UIScreen mainScreen] bounds].size.width, 162)];
    datePicker.backgroundColor = [UIColor whiteColor];
    datePicker.tag = PICKERVIEW_TAG;
    datePicker.delegate = self;
    datePicker.dataSource = self;
    [self.view addSubview:bgView];
    [bgView addSubview:datePicker];
//    [self.view addSubview:datePicker];
    
}
- (void)comfirmOrCancelClicked:(id)sender
{
    UIButton *senderBtn = sender;
    
    switch (senderBtn.tag)
    {
        case COMFIRM_BTN_TAG:
        {
            NSString *countyName =  [self.thirdPickerArray objectAtIndex:_countyIndex];
            
            NSString *countyCode = [self.thirdPickerDic valueForKey:countyName];
            
            _xzqhTextField.text = [[NSString alloc] initWithFormat:@"%@",countyCode];
            
        }
            break;
        case CANCEL_BTN_TAG:
            break;
        default:
            break;
    }
    UIView *bgView = [self.view viewWithTag:BG_VIEW_TAG];
    [bgView removeFromSuperview]; //移除视图
    
    [self resume];
    
//    UIButton *selectBtn = (UIButton *)[self.view viewWithTag:SELECT_SITE_TAG];
//    [selectBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];//再次添加事件
    
}

-(void) updateAreaList: (NSInteger)row inComponent:(NSInteger)component{
    
    if(component == 2) {
        _countyIndex = row;
        return;
    }
    
    if(component == 0){
        NSString *index = [[NSString alloc] initWithFormat:@"%zi",row+1];
        provinceIndex = index;
        NSArray *cities = [[_dict valueForKey:index]valueForKey:@"cities"];
        NSMutableArray *shi = [[NSMutableArray alloc] init];
        
        for (int i = 0; i< [cities count]; i++) {
            NSDictionary *tempDic = [cities objectAtIndex:i];
            [shi addObject:[tempDic valueForKey:@"name"] ];
        }
        
        _subPickerArray = shi;
        _cityIndex = 0;
        _countyIndex = 0;
        
    }
    
    if(component==1){
        _cityIndex = row;
        _countyIndex = 0;
    }
    
    NSArray *counties = [[[[_dict valueForKey:provinceIndex]valueForKey:@"cities"] objectAtIndex:_cityIndex]valueForKey:@"counties"];
    
    NSMutableDictionary *cun = [[NSMutableDictionary alloc] init];
    NSMutableArray *cunArray = [[NSMutableArray alloc] init];
    for (int i = 0; i< [counties count]; i++) {
        NSDictionary *tempDic = [counties objectAtIndex:i];
        NSString *name = [tempDic valueForKey:@"name"];
        NSString *code = [tempDic valueForKey:@"code"];
        
        [cun setObject:code forKey:name];
        [cunArray addObject:name];
        
    }
    _thirdPickerArray = cunArray;
    _thirdPickerDic = cun;
}

-(void) pause {
    _phoneNumberTextField.enabled = NO;
    _passwordTextField.enabled = NO;
    _nameTextField.enabled = NO;
    _xzqhTextField.enabled = NO;
    _registerBtn.enabled = NO;
    _organizationTextField.enabled = NO;
    _jobTextField.enabled = NO;
    
}
-(void) resume {
    _phoneNumberTextField.enabled = YES;
    _passwordTextField.enabled = YES;
    _nameTextField.enabled = YES;
    _xzqhTextField.enabled = YES;
    _registerBtn.enabled = YES;
    _organizationTextField.enabled = YES;
    _jobTextField.enabled = YES;
}

@end














