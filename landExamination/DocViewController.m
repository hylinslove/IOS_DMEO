//
//  DocViewController.m
//  landExamination
//
//  Created by das on 2017/3/16.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import "DocViewController.h"

@interface DocViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSURL *url = [[NSBundle mainBundle]URLForResource:_docName withExtension:nil];
    NSString * htmlstr = [[NSString alloc]initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:htmlstr]];
    [_webView loadRequest:request];
    [_webView loadHTMLString:htmlstr baseURL:url];
    
}

- (IBAction)backBtnAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
