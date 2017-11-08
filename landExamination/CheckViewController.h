//
//  CheckViewController.h
//  landExamination
//
//  Created by xianglong on 2017/10/9.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MissionModel.h"

@interface CheckViewController : UIViewController
@property (copy,nonatomic) NSString *taskID ;
@property (strong, nonatomic) MissionModel *taskModel;
@property (strong, nonatomic) NSString *zbs;
@end
