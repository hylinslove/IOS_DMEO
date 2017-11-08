//
//  SQLManager.h
//  landExamination
//
//  Created by das on 2016/12/14.
//  Copyright © 2016年 JiangsuJiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "ServiceManager.h"
#import "HCResult.h"
#import "MissionModel.h"

@interface SQLManager : NSObject

@property (strong, nonatomic)FMDatabase *db;

+ (instancetype)sharedManager;
//初始化创建table
- (void)initTable;

/**
 将数据写入sql

 @param taskArr   数据
 @param gxtsBlock gxts 新增条数
 */
- (void)writeToSQLTaskArr:(NSArray *)taskArr withGXNumber:(void(^)(NSInteger gxts))gxtsBlock;

//获得最大的gxrq
- (NSString *)getMaxGXRQ;

/**
 根据同步任务返回的数据更新数据库中的核查状态
 @param arr 同步任务v请求返回的数据
 */
- (void)updateHCZTWithArr:(NSArray *)arr withTBNumber:(void(^)(NSInteger gxts))tbtsBlock;

//根据传入的sql语句 查询结果并处理为model数组返回
- (NSArray *)getTasksWithSQLStr:(NSString *)sqlStr;



/**
 将核查结果存入数据库

 @param hcResult 核查结果
 */
- (void)saveHCXX:(HCResult *)hcResult;

/**
 改变hcztstats

 @param guid guid标识
 */
- (void)changeHCZTSTAT1SWithGUID:(NSString *)guid;

- (void)changeHCZTSTAT2SWithGUID:(NSString *)guid;

- (void)updateGuid:(NSString *) guid SHAPEWithZbs:(NSString *)zbs;

- (MissionModel *)getMissionModelWithGuid:(NSString *)guid;

- (void)removeYHCTasks:(NSArray *)arr;


@end
