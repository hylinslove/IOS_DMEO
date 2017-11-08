//
//  CaiJiViewController.h
//  landExamination
//
//  Created by xianglong on 2017/10/19.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduMapAPI.h"
#import "MissionModel.h"
#import "RouteAnnotation.h"
#import "SQLManager.h"

@interface CaiJiViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKRouteSearchDelegate>
@property (strong, nonatomic)NSString *guid;
@end
