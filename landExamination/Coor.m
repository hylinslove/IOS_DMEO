//
//  Coor.m
//  landExamination
//
//  Created by das on 2017/1/5.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import "Coor.h"

@implementation Coor


+ (instancetype)initWith:(CLLocationCoordinate2D)coor{
    
    Coor *obj = [[Coor alloc]init];
    obj.lon = coor.longitude;
    obj.lat = coor.latitude;
    
    return obj;
}

@end
