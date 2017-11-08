//
//  MissionModel.h
//  landExamination
//
//  Created by das on 2016/12/10.
//  Copyright © 2016年 JiangsuJiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MissionModel : NSObject

@property (strong, nonatomic) NSString *XZQH;//行政区号
@property (strong, nonatomic) NSString *GUID;
@property (strong, nonatomic) NSString *SHENG;//省
@property (strong, nonatomic) NSString *SHI;//市
@property (strong, nonatomic) NSString *XIAN;//区
@property (strong, nonatomic) NSString *ND;//年度
@property (strong, nonatomic) NSString *TBBH;//图标编号
@property (strong, nonatomic) NSString *DKBH;//地块编号
@property (strong, nonatomic) NSString *XMMC;//
@property (strong, nonatomic) NSString *YDDW;//用地单位
@property (strong, nonatomic) NSString *TDZL;//土地坐落
@property (strong, nonatomic) NSString *PZWH;//
@property (strong, nonatomic) NSString *TDZH;//
@property (strong, nonatomic) NSString *WTLX;
@property (strong, nonatomic) NSString *SHAPE;
@property (strong, nonatomic) NSString *XZB;
@property (strong, nonatomic) NSString *YZB;
@property (strong, nonatomic) NSString *SHAPEBUFFER;
@property (strong, nonatomic) NSString *OUTBUFFER;
@property (strong, nonatomic) NSString *GXRQ;
@property (strong, nonatomic) NSString *YDMJ;
@property (strong, nonatomic) NSString *TB_TYPE;

@property (strong, nonatomic) NSString *HCZT;
@property (strong, nonatomic) NSString *HCZTSTATS;
@property (strong, nonatomic) NSString *SFXHC;

@property (strong, nonatomic) NSString *isTH;//是否是退回的任务
@property (strong, nonatomic) NSString *WTSJSJMJ;//实际面积
@property (strong, nonatomic) NSString *WTSJSJNYD;//实际农用地面积
@property (strong, nonatomic) NSString *WTSJSJGD;//实际供地面积
@property (strong, nonatomic) NSString *WTSJSJJBNT;//实际基本农田
@property (strong, nonatomic) NSString *WTSJSJJE;//实际金额
@property (strong, nonatomic) NSString *WTSJSJRK;//实际人口

@property (strong, nonatomic) NSString *HTLY;

@property (strong, nonatomic) NSString *isXCJ;



@end
