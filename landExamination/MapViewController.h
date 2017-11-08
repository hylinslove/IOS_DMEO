//
//  MapViewController.h
//  landExamination
//
//  Created by xianglong on 2017/9/29.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduMapAPI.h"
#import "MissionModel.h"
#import "RouteAnnotation.h"
//百度导航
#import "BNRoutePlanModel.h"
#import "BNCoreServices.h"
#import "BNaviModel.h"

@interface MapViewController : UIViewController
@property (copy,nonatomic) NSString *taskID ;
@property (strong, nonatomic) MissionModel *mission;

@end
