//
//  SQLManager.m
//  landExamination
//
//  Created by das on 2016/12/14.
//  Copyright © 2016年 JiangsuJiyang. All rights reserved.
//

#import "SQLManager.h"
#import "MissionModel.h"
#import "AppDelegate.h"
#import <YYCache.h>
#import "NoticeMission.h"

@implementation SQLManager

+ (instancetype)sharedManager{
    static SQLManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[SQLManager alloc] init];
            
            
            
        }
    });
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *DBPath = [documentPath stringByAppendingPathComponent:@"wpTask.db"];
//    NSLog(@"%@",DBPath);
    manager.db = [FMDatabase databaseWithPath:DBPath];

    return manager;
    
}

- (void)initTable{
    
//    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *DBPath = [documentPath stringByAppendingPathComponent:@"wpTask.db"];
//    NSLog(@"%@",DBPath);
//    
//    _db = [FMDatabase databaseWithPath:DBPath];
    if (![_db open]) {
        _db = nil;
        NSLog(@"open field");
        return;
    }
    //创建表
    if (![_db executeUpdate:@"CREATE TABLE IF NOT EXISTS WPTASK(ID INTEGER PRIMARY KEY AUTOINCREMENT,XZQH TEXT,GUID TEXT,SHENG TEXT,SHI TEXT,XIAN TEXT,ND TEXT,TBBH TEXT,DKBH TEXT,XMMC TEXT,YDDW TEXT,TDZL TEXT,PZWH TEXT,TDZH TEXT,WTLX TEXT,SHAPE TEXT,XZB TEXT,YZB TEXT,SHAPEBUFFER TEXT,OUTBUFFER TEXT,GXRQ TEXT,YDMJ TEXT,TB_TYPE TEXT,HCZT TEXT,HCZTSTATS TEXT,SFXHC TEXT,WTSJSJMJ TEXT,WTSJSJNYD TEXT,WTSJSJGD TEXT,WTSJSJJBNT TEXT,WTSJSJJE TEXT,WTSJSJRK TEXT,ISTH TEXT,ISXCJ TEXT,UNIQUE(GUID))"]) {
        NSLog(@"创建wptask错误：%@",[_db lastErrorMessage]);
    }
    
    if (![_db executeUpdate:@"CREATE TABLE IF NOT EXISTS TASK(ID INTEGER PRIMARY KEY AUTOINCREMENT,yw_guid TEXT,hcqk TEXT, hcry TEXT,zbs TEXT,hcrq TEXT,tb_type TEXT,UNIQUE(yw_guid))"]) {
        NSLog(@"创建task错误：%@",[_db lastErrorMessage]);
    }
    
    if (![_db columnExists:@"HTLY" inTableWithName:@"WPTASK"]){
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"WPTASK",@"HTLY"];
        BOOL worked = [_db executeUpdate:alertStr];
        if(worked){
            NSLog(@"插入成功");
        }else{
            NSLog(@"插入失败");
        }
    }
    
    
    [_db close];
    
}

- (void)writeToSQLTaskArr:(NSArray *)taskArr withGXNumber:(void(^)(NSInteger ))gxtsBlock{
    //获取app代理
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (![_db open]) {
//        _db = nil;
        NSLog(@"%@",[_db lastErrorMessage]);
        return;
    }
    NSInteger gxts = 0;
    
    NSMutableArray *taskIDs = [NSMutableArray array];
    
    for (int i = 0; i<taskArr.count; i++) {
        MissionModel *model = taskArr[i];
        [taskIDs addObject:model.GUID];
        //判断数据库中是否存在该GUID数据
//        FMResultSet *result = [_db executeQueryWithFormat:@"SELECT * FROM WPTASK WHERE GUID=%@",model.GUID];
        
        FMResultSet *rs =[_db executeQueryWithFormat:@"SELECT COUNT(GUID) AS countNum FROM WPTASK WHERE GUID = %@",model.GUID];
        
        while ([rs next]) {
            
            NSInteger count = [rs intForColumn:@"countNum"];
            
            if (count > 0) {
                //存在
                //能查到 该数据
                NSString *oldTB_type;
                NSString *hcstats;
                FMResultSet *result = [_db executeQueryWithFormat:@"SELECT * FROM WPTASK WHERE GUID=%@",model.GUID];
                while ([result next]) {
                    oldTB_type = [result stringForColumn:@"TB_TYPE"];
                    hcstats = [result stringForColumn:@"HCZTSTATS"];
                }
                
                
                if ([hcstats isEqualToString:@"2"]){
                    if ([model.TB_TYPE isEqualToString:oldTB_type]) {
                        //能查询到 且tbtype相同  且状态是已回传  标记为退回任务 isth = 1
                         [_db executeUpdateWithFormat:@"UPDATE WPTASK SET ISTH = 1,HCZT = 0,HCZTSTATS = 0 WHERE GUID = %@",model.GUID];
                        NoticeMission *notice = [[NoticeMission alloc]init];
                        notice.GUID = model.GUID;
                        notice.CONTENT = model.HTLY;
                        
                        [delegate.backTasks addObject:notice];
                        
                    }else{
                        //type不相同 且状态是已回传  重新加入到待核查列表中
                        [_db executeUpdateWithFormat:@"UPDATE WPTASK SET ISTH = 0, HCZT = 0,HCZTSTATS = 0 WHERE GUID = %@",model.GUID];
                    }
                    //退回任务删除之前保存的信息
//                    YYCache *cache = [YYCache cacheWithName:@"paths"];
//                    if([cache containsObjectForKey:model.GUID]){
//                        [cache removeObjectForKey:model.GUID];
//                    }
                    //更新新的任务
                    [_db executeUpdateWithFormat:@"UPDATE WPTASK SET XZQH= %@,GUID= %@,SHENG= %@,SHI= %@,XIAN= %@,ND= %@,TBBH= %@,DKBH= %@,XMMC= %@,YDDW= %@,TDZL= %@,PZWH= %@,TDZH= %@,WTLX= %@,SHAPE= %@,XZB= %@,YZB= %@,SHAPEBUFFER= %@,OUTBUFFER= %@,GXRQ= %@,YDMJ= %@,TB_TYPE= %@,SFXHC= %@,WTSJSJMJ= %@,WTSJSJNYD= %@,WTSJSJGD= %@,WTSJSJJBNT= %@,WTSJSJJE= %@,WTSJSJRK= %@,ISXCJ= %@,HTLY=%@ WHERE GUID = %@",model.XZQH,model.GUID,model.SHENG,model.SHI,model.XIAN,model.ND,model.TBBH,model.DKBH,model.XMMC,model.YDDW,model.TDZL,model.PZWH,model.TDZH,model.WTLX,model.SHAPE,model.XZB,model.YZB,model.SHAPEBUFFER,model.OUTBUFFER,model.GXRQ,model.YDMJ,model.TB_TYPE,model.SFXHC,model.WTSJSJMJ,model.WTSJSJNYD,model.WTSJSJGD,model.WTSJSJJBNT,model.WTSJSJJE,model.WTSJSJRK,model.SHAPE?@"0":@"1",model.HTLY,model.GUID];
                    
                }
            }
            else
            {
                //不存在
                gxts ++;
                if (![_db executeUpdateWithFormat:@"INSERT OR IGNORE INTO WPTASK(XZQH,GUID,SHENG,SHI,XIAN,ND,TBBH,DKBH,XMMC,YDDW,TDZL,PZWH,TDZH,WTLX,SHAPE,XZB,YZB,SHAPEBUFFER,OUTBUFFER,GXRQ,YDMJ,TB_TYPE,HCZT,HCZTSTATS,SFXHC,WTSJSJMJ,WTSJSJNYD,WTSJSJGD,WTSJSJJBNT,WTSJSJJE,WTSJSJRK,ISTH,ISXCJ,HTLY) VALUES(%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,0,%@,%@)",model.XZQH,model.GUID,model.SHENG,model.SHI,model.XIAN,model.ND,model.TBBH,model.DKBH,model.XMMC,model.YDDW,model.TDZL,model.PZWH,model.TDZH,model.WTLX,model.SHAPE,model.XZB,model.YZB,model.SHAPEBUFFER,model.OUTBUFFER,model.GXRQ,model.YDMJ,model.TB_TYPE,model.HCZT,model.HCZTSTATS,model.SFXHC,model.WTSJSJMJ,model.WTSJSJNYD,model.WTSJSJGD,model.WTSJSJJBNT,model.WTSJSJJE,model.WTSJSJRK,model.SHAPE?@"0":@"1",model.HTLY]) {
                    NSLog(@"插入错误：%@",[_db lastErrorMessage]);
                }
            }
        }
    }//循环结束，删除不在任务列表中的本地任务
    
    
    //添加至通知列表
    NSString *dhcStr = [NSString stringWithFormat:@"SELECT * FROM WPTASK WHERE (HCZT ISNULL OR HCZT <> 1) AND (HCZTSTATS = 0 OR HCZTSTATS ISNULL) AND XZQH = '%@'",delegate.xzqhStr] ;
    NSArray *todoTasks = [self getTasksWithSQLStr:dhcStr];
    for(MissionModel *mission in todoTasks) {
        if(![taskIDs containsObject:mission.GUID]) {
            NoticeMission *notice = [[NoticeMission alloc]init];
            notice.GUID = mission.GUID;
            notice.CONTENT = @"服务器端删除";
            NSLog(@"-------------------------------------同步-------------------------------------");
            [delegate.deleteTasks addObject:notice];
        }
    }
    
    
    NSMutableString *deleteStr = [NSMutableString string];
    [deleteStr appendString:@"DELETE FROM WPTASK WHERE GUID NOT IN ("];

    for (int i = 0; i<taskArr.count; i++) {
        MissionModel *model = taskArr[i];
        if (i==taskArr.count-1) {
            [deleteStr appendFormat:@"%@",model.GUID];
        }else{
            [deleteStr appendFormat:@"%@,",model.GUID];
        }
    
    }
    
    [deleteStr appendString:@") AND (HCZT ISNULL OR HCZT <> 1) AND (HCZTSTATS = 0 OR HCZTSTATS ISNULL)"];
    [_db open];
    [_db executeUpdate:deleteStr];

    NSLog(@"********************************删除******************************");
    gxtsBlock(gxts);
    
    [_db close];
}
//获取到最大更新日期值
- (NSString *)getMaxGXRQ{
    
    if (![_db open]) {
        NSLog(@"%@",[_db lastErrorMessage]);
        _db = nil;
        return nil;
    }
    
    NSString *maxGXRQ;
    FMResultSet *result = [_db executeQuery:@"SELECT MAX(GXRQ) FROM WPTASK"];

    while ([result next]) {
        maxGXRQ = [result stringForColumnIndex:0];
    }
    
    [_db close];
    return maxGXRQ;
}


-(void)updateHCZTWithArr:(NSArray *)arr withTBNumber:(void (^)(NSInteger))tbtsBlock{
    
    if (![_db open]) {
        NSLog(@"%@",[_db lastErrorMessage]);
        _db = nil;
        return ;
    }
    NSInteger tbts = 0;
    
    //当同步条数不为0时  将arr中的数据与数据库中的对比
    if (arr.count != 0) {
        
        for (int i = 0; i<arr.count; i++) {
            
            MissionModel *model = arr[i];
            
            FMResultSet *set = [_db executeQueryWithFormat:@"SELECT COUNT(GUID) AS countNum FROM WPTASK WHERE GUID = %@",model.GUID];
            
            while ([set next]) {
                NSInteger count = [set intForColumn:@"countNum"];
                //当获取guid存在时更新 hczt
                if (count > 0) {
                    tbts++;
                    [_db executeUpdateWithFormat:@"UPDATE WPTASK SET HCZT = %@ WHERE GUID = %@",model.HCZT,model.GUID];
                }
            }
        }
    }
    tbtsBlock(tbts);
    [_db close];
    
}

-(NSArray *)getTasksWithSQLStr:(NSString *)sqlStr{
 
    NSMutableArray *tasksArr = [NSMutableArray array];
    
    if (![_db open]) {
        NSLog(@"%@",[_db lastErrorMessage]);
        _db = nil;
        return @[];
    }

    
    FMResultSet *rs = [_db executeQuery:sqlStr];
    
    while ([rs next]) {
        MissionModel *model = [[MissionModel alloc]init];
        model.XZQH = [rs stringForColumn:@"XZQH"];
        model.GUID = [rs stringForColumn:@"GUID"];
        model.SHENG = [rs stringForColumn:@"SHENG"];
        model.SHI = [rs stringForColumn:@"SHI"];
        model.XIAN = [rs stringForColumn:@"XIAN"];
        model.ND = [rs stringForColumn:@"ND"];
        model.TBBH = [rs stringForColumn:@"TBBH"];
        model.DKBH = [rs stringForColumn:@"DKBH"];
        model.XMMC = [rs stringForColumn:@"XMMC"];
        model.YDDW = [rs stringForColumn:@"YDDW"];
        model.TDZL = [rs stringForColumn:@"TDZL"];
        model.PZWH = [rs stringForColumn:@"PZWH"];
        model.TDZH = [rs stringForColumn:@"TDZH"];
        model.WTLX = [rs stringForColumn:@"WTLX"];
        model.SHAPE = [rs stringForColumn:@"SHAPE"];
        model.XZB = [rs stringForColumn:@"XZB"];
        model.YZB = [rs stringForColumn:@"YZB"];
        model.SHAPEBUFFER = [rs stringForColumn:@"SHAPEBUFFER"];
        model.OUTBUFFER = [rs stringForColumn:@"OUTBUFFER"];
        model.GXRQ = [rs stringForColumn:@"GXRQ"];
        model.YDMJ = [rs stringForColumn:@"YDMJ"];
        model.TB_TYPE = [rs stringForColumn:@"TB_TYPE"];
        model.HCZT = [rs stringForColumn:@"HCZT"];
        model.HCZTSTATS = [rs stringForColumn:@"HCZTSTATS"];
        model.SFXHC = [rs stringForColumn:@"SFXHC"];
        model.WTSJSJMJ = [rs stringForColumn:@"WTSJSJMJ"];
        model.WTSJSJNYD = [rs stringForColumn:@"WTSJSJNYD"];
        model.WTSJSJGD = [rs stringForColumn:@"WTSJSJGD"];
        model.WTSJSJJBNT = [rs stringForColumn:@"WTSJSJJBNT"];
        model.WTSJSJJE = [rs stringForColumn:@"WTSJSJJE"];
        model.WTSJSJRK = [rs stringForColumn:@"WTSJSJRK"];
        model.isTH = [rs stringForColumn:@"ISTH"];
        model.isXCJ = [rs stringForColumn:@"ISXCJ"];
        model.HTLY = [rs stringForColumn:@"HTLY"];
        
        [tasksArr addObject:model];
    }

    [_db close];
    
    return tasksArr;
}
//核查结果存入
- (void)saveHCXX:(HCResult *)hcResult{
    if (![_db open]) {
        NSLog(@"%@",[_db lastErrorMessage]);
        _db = nil;
        return ;
    }

    if (![_db executeUpdateWithFormat:@"INSERT OR IGNORE INTO TASK(yw_guid,hcqk,hcry,zbs,hcrq,tb_type) VALUES(%@,%@,%@,%@,%@,%@)",hcResult.yw_guid,hcResult.hcqk,hcResult.hcry,hcResult.zbs,hcResult.hcry,hcResult.tb_type]) {
        NSLog(@"插入错误：%@",[_db lastErrorMessage]);
    }

    
    
    [_db close];
}

- (void)changeHCZTSTAT1SWithGUID:(NSString *)guid{
    if (![_db open]) {
        NSLog(@"%@",[_db lastErrorMessage]);
        _db = nil;
        return ;
    }
    
    if (![_db executeUpdateWithFormat:@"UPDATE WPTASK SET HCZTSTATS = '1' WHERE GUID = %@",guid]) {
        NSLog(@"更新hcztstats错误:%@",[_db lastErrorMessage]);
        
    }
    
    [_db close];
        
}
- (void)changeHCZTSTAT2SWithGUID:(NSString *)guid{
    if (![_db open]) {
        NSLog(@"%@",[_db lastErrorMessage]);
        _db = nil;
        return ;
    }
    
    if (![_db executeUpdateWithFormat:@"UPDATE WPTASK SET HCZTSTATS = '2' WHERE GUID = %@",guid]) {
        NSLog(@"更新hcztstats错误:%@",[_db lastErrorMessage]);
        
    }
    
    [_db close];
    
}

- (void)updateGuid:(NSString *) guid SHAPEWithZbs:(NSString *)zbs{
    if (![_db open]) {
        NSLog(@"%@",[_db lastErrorMessage]);
        _db = nil;
        return ;
    }
    
    BOOL flag = [_db executeUpdateWithFormat:@"UPDATE WPTASK SET SHAPE = %@ WHERE GUID = %@",zbs,guid];
    [_db executeUpdateWithFormat:@"UPDATE WPTASK SET OUTBUFFER = %@ WHERE GUID = %@",zbs,guid];
    if (!flag) {
        NSLog(@"gengx shape:%@",[_db lastError]);
    }
    
    [_db close];
    
}

- (MissionModel *)getMissionModelWithGuid:(NSString *)guid{
    
    if (![_db open]) {
        NSLog(@"%@",[_db lastErrorMessage]);
        _db = nil;
        return nil;
    }
    
    
    FMResultSet *rs = [_db executeQueryWithFormat:@"SELECT * FROM WPTASK WHERE GUID = %@",guid];
    MissionModel *model = [[MissionModel alloc]init];
    while ([rs next]) {
        model.XZQH = [rs stringForColumn:@"XZQH"];
        model.GUID = [rs stringForColumn:@"GUID"];
        model.SHENG = [rs stringForColumn:@"SHENG"];
        model.SHI = [rs stringForColumn:@"SHI"];
        model.XIAN = [rs stringForColumn:@"XIAN"];
        model.ND = [rs stringForColumn:@"ND"];
        model.TBBH = [rs stringForColumn:@"TBBH"];
        model.DKBH = [rs stringForColumn:@"DKBH"];
        model.XMMC = [rs stringForColumn:@"XMMC"];
        model.YDDW = [rs stringForColumn:@"YDDW"];
        model.TDZL = [rs stringForColumn:@"TDZL"];
        model.PZWH = [rs stringForColumn:@"PZWH"];
        model.TDZH = [rs stringForColumn:@"TDZH"];
        model.WTLX = [rs stringForColumn:@"WTLX"];
        model.SHAPE = [rs stringForColumn:@"SHAPE"];
        model.XZB = [rs stringForColumn:@"XZB"];
        model.YZB = [rs stringForColumn:@"YZB"];
        model.SHAPEBUFFER = [rs stringForColumn:@"SHAPEBUFFER"];
        model.OUTBUFFER = [rs stringForColumn:@"OUTBUFFER"];
        model.GXRQ = [rs stringForColumn:@"GXRQ"];
        model.YDMJ = [rs stringForColumn:@"YDMJ"];
        model.TB_TYPE = [rs stringForColumn:@"TB_TYPE"];
        model.HCZT = [rs stringForColumn:@"HCZT"];
        model.HCZTSTATS = [rs stringForColumn:@"HCZTSTATS"];
        model.SFXHC = [rs stringForColumn:@"SFXHC"];
        model.WTSJSJMJ = [rs stringForColumn:@"WTSJSJMJ"];
        model.WTSJSJNYD = [rs stringForColumn:@"WTSJSJNYD"];
        model.WTSJSJGD = [rs stringForColumn:@"WTSJSJGD"];
        model.WTSJSJJBNT = [rs stringForColumn:@"WTSJSJJBNT"];
        model.WTSJSJJE = [rs stringForColumn:@"WTSJSJJE"];
        model.WTSJSJRK = [rs stringForColumn:@"WTSJSJRK"];
        model.isTH = [rs stringForColumn:@"ISTH"];
        model.isXCJ = [rs stringForColumn:@"ISXCJ"];
        model.HTLY = [rs stringForColumn:@"HTLY"];
    }
    
    [_db close];
    
    return model;
    
}
//删除对应的已回传项目
- (void)removeYHCTasks:(NSArray *)arr{
    //获取app代理
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [_db open];
    NSMutableString *deleteStr = [NSMutableString string];
    [deleteStr appendString:@"DELETE FROM WPTASK WHERE GUID IN ("];
//    
//    for (NSDictionary *dict in arr) {
//        [deleteStr appendFormat:@"%@,",dict[@"GUID"]];
//    }
    for (int i = 0; i<arr.count; i++) {
        NSDictionary *dict = arr[i];
        if (i==arr.count-1) {
            [deleteStr appendFormat:@"%@",dict[@"GUID"]];
        }else{
            [deleteStr appendFormat:@"%@,",dict[@"GUID"]];
        }
        
        FMResultSet *set = [_db executeQueryWithFormat:@"SELECT COUNT(GUID) AS countNum FROM WPTASK WHERE GUID = %@",dict[@"GUID"]];
        
        while ([set next]) {
            NSInteger count = [set intForColumn:@"countNum"];
            
            if (count > 0) {
                NoticeMission *notice = [[NoticeMission alloc]init];
                notice.GUID = dict[@"GUID"];
                notice.CONTENT = @"其他核查人员完成回传";
                if(![delegate.deleteTasks containsObject:notice]){
                    [delegate.deleteTasks addObject:notice];
                }
            }
        }
        
        
    }
    
//    [deleteStr appendString:@") AND HCZTSTATS = '2' "];
    [deleteStr appendString:@") AND (HCZTSTATS = 0 OR HCZTSTATS ISNULL)"];
    
    
//    NSLog(@"%@",deleteStr);
    
    BOOL flag = [_db executeUpdate:deleteStr];
    
    if (!flag) {
        NSLog(@"%@",[_db lastError]);
    }
    
    [_db close];
}
@end
