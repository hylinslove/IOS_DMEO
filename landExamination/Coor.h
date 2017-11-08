//
//  Coor.h
//  landExamination
//
//  Created by das on 2017/1/5.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaiduMapAPI.h"

@interface Coor : NSObject

@property (assign, nonatomic) float lon;
@property (assign, nonatomic) float lat;

+ (instancetype)initWith:(CLLocationCoordinate2D)coor;


@end
