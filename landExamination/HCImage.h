//
//  HCImage.h
//  landExamination
//
//  Created by das on 2017/2/16.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaiduMapAPI.h"

@interface HCImage : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *longitude;//经度
@property (strong, nonatomic) NSString *latitude;//纬度
@property (strong, nonatomic) NSString *fxj;
@property (strong, nonatomic) NSDate *date;

@end
