//
//  AppDelegate.h
//  landExamination
//
//  Created by das on 16/11/5.
//  Copyright © 2016年 Chinastis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import "BaiduMapAPI.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKLocationServiceDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *xzqhStr;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *psw;
@property (strong, nonatomic) NSTimer* locRecoder;
@property (strong,nonatomic) NSMutableArray *deleteTasks;
@property (strong,nonatomic) NSMutableArray *backTasks;

- (void)uploadLocation;

@end

