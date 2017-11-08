//
//  ServiceManager.m
//  landExamination
//
//  Created by das on 2016/12/7.
//  Copyright © 2016年 JiangsuJiyang. All rights reserved.
//

#import "ServiceManager.h"
#import <YYCache.h>
#import "SQLManager.h"
#import "SSZipArchive.h"
#import <SVProgressHUD.h>

#define kLOGINURL @"http://192.168.1.30:8090/domain/service/rest/exchangeAction/login_Ios"

#define kGETDATA @"http://192.168.1.30:8090/domain/service/rest/exchangeAction/getData"
#define kRemoveYHC @"http://192.168.1.30:8090/domain/service/rest/exchangeAction/getYhcTb"

#define kGETINFOBYHCZT @"http://192.168.1.30:8090/domain/service/rest/sjdj/getInfoByHczt"

#define kUploadLocInfo @"http://192.168.1.30:8090/domain/service/rest/zghcAction/updateGPS"

#define kURL @"http://221.178.156.98:8090"
#define CESHI @"http://218.4.170.54:8093"
#define CESHI2 @"http://192.168.1.30:8090"

@implementation ServiceManager
static ServiceManager *manager = nil;

+(instancetype)sharedManger{

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[self alloc]init];
        manager.serviceManager = [AFHTTPSessionManager manager];
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        manager.serviceManager.responseSerializer = responseSerializer;
        manager.serviceManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json", @"text/javascript", @"text/plain", nil];
        
    });
    return manager;
}

//注册通过手机号获取验证码
- (void)getVerificationWithPhonenumber:(NSString *)phonenumber success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock{
    
    NSDictionary *param = @{@"phone":phonenumber};
    NSString *url = @"http://221.178.156.98:8090/domain/service/rest/registerAction/sendVerification";
    [_serviceManager POST:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
    }];
}
//注册验证验证码
- (void)verifyPhonenumber:(NSString *)phonenumber verification:(NSString *)verification success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock{
    
    NSDictionary *param = @{@"phone":phonenumber,
                            @"verification":verification};
    NSString *url = @"http://221.178.156.98:8090/domain/service/rest/registerAction/verify";
    [_serviceManager POST:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
    }];
}
//注册
-(void)registerWithUsername:(NSString *)username password:(NSString *)password fullname:(NSString *)fullname xzqh:(NSString *)xzqh organization:(NSString *)organization job:(NSString *)job success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock{
    
    NSDictionary *param = @{@"username":username==nil?@"":username,
                            @"password":password==nil?@"":password,
                            @"fullname":fullname==nil?@"":fullname,
                            @"xzqh":xzqh==nil?@"":xzqh,
                            @"organization":organization==nil?@"":organization,
                            @"job":job==nil?@"":job};
    
    NSString *url = @"http://192.168.1.30:8090/domain/service/rest/registerAction/regPhone";
    [_serviceManager POST:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
    }];

 
}

//重置密码
- (void)modifyPasswordPhonenumber:(NSString *)phonenumber password:(NSString *)password success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock{
    
    NSDictionary *param = @{@"username":phonenumber,
                            @"password":password};
    
    NSString *url = @"http://192.168.1.30:8090/domain/service/rest/registerAction/modifyPassword";
    
    [_serviceManager POST:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
    }];
    
}

//登录
- (void)userLogin:(NSString *)userName password:(NSString *)password success:(void (^)(NSDictionary *))successBlock failure:(void (^)(NSError *))failureBlock{
    
    NSDictionary *param = @{@"username":userName,
                            @"password":password};
    
  [self.serviceManager POST:kLOGINURL parameters:param progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      
      successBlock(responseObject);
      [self removeYhcTaskbyXian:[responseObject valueForKey:@"msg"]];
      
      
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      
      failureBlock(error);
      
  }];
    
}

- (void)removeYhcTaskbyXian:(NSString *)xian{
    NSDictionary *param = @{@"GXRQ":@"1",
                            @"XIAN":xian
                            };
    
    [self.serviceManager POST:kRemoveYHC parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *guidArr = responseObject;
        
//        获取guid列表 删除相应的guid数据
        [[SQLManager sharedManager] removeYHCTasks:guidArr];
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    
}

//更新任务
- (void)getMissionWithUsername:(NSString *)username andXZQMC:(NSString *)xzqmc success:(void (^)(NSArray *))successBlock failure:(void (^)(NSError *))failureBlock{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *gxrq = [formatter stringFromDate:[NSDate date]];
    
    NSDictionary *param = @{@"GXRQ":gxrq,
                            @"XIAN":xzqmc,
                            @"USERNAME":username
                            };
    
    [self.serviceManager POST:kGETDATA parameters:param progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        successBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failureBlock(error);
    }];
    
}

//同步任务
- (void)updateMissionWithGXRQ:(NSString *)gxrq andUserName:(NSString *)userName success:(void (^)(NSArray *))successBlock failure:(void (^)(NSError *))failureBlock{
    
    if (gxrq == nil || userName == nil) {
        NSLog(@"gxrq 或者 userName 为空");
        return;
    }
    
    NSDictionary *param = @{
                          @"GXRQ":gxrq,
                          @"USERNAME":userName
                          };
    
    [self.serviceManager POST:kGETINFOBYHCZT parameters:param progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        successBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
    }];
    
    
}

- (void)uploadTaskWithGuid:(NSString *)guid progress:(void (^)(NSProgress *))progressBlock success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock{
    
    [SVProgressHUD showWithStatus:@"正在处理..."];
    
//    YYCache *cache = [YYCache cacheWithName:@"paths"];
//    NSDictionary *cacheDict = (NSDictionary *)[cache objectForKey:guid];
//    NSArray *paths = cacheDict[@"paths"];
    
    
    NSString *dirDoc = [self dirDoc];
    NSString *mediaPath = [dirDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",guid]];
    NSString *path = [dirDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",guid]];

//    BOOL flag = [SSZipArchive createZipFileAtPath:path withFilesAtPaths:paths];
    BOOL flag = [SSZipArchive createZipFileAtPath:path withContentsOfDirectory:mediaPath];
    
    
    if (!flag) {
        NSLog(@"压缩失败");
    }
//上传zip
    
    
//    NSURL *filePath = [NSURL fileURLWithPath:path];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://192.168.1.30:8090/domain/service/rest/wyxc/saveDataIos" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"file" fileName:[NSString stringWithFormat:@"%@.zip",guid] mimeType:@"application/zip" error:nil];
        
        
    } error:nil];
    

    NSURLSessionUploadTask *uploadTask = [_serviceManager
                                          uploadTaskWithStreamedRequest:request
                                          progress:^(NSProgress * _Nonnull uploadProgress) {
                                              // This is not called back on the main queue.
                                              // You are responsible for dispatching to the main queue for UI updates
                                              progressBlock(uploadProgress);
                                              
                                              [SVProgressHUD showProgress:uploadProgress.fractionCompleted];
                                              
                                          }
                                          completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                              if (error) {
                                                  [SVProgressHUD showWithStatus:@"上传失败"];
                                                  [SVProgressHUD dismissWithDelay:0.8];
                                                  failureBlock(error);
                                              } else {
                                                  
                                                  [SVProgressHUD showWithStatus:@"上传成功"];
                                                  [SVProgressHUD dismissWithDelay:0.8];
                                                  successBlock(responseObject);
                                                  
                                              }
                                          }];
    
    [uploadTask resume];
    
}

- (void)uploadLocInfo:(NSDictionary *)info{
    
//http://218.4.170.54:8093/domain/service/rest/zghcAction/updateGPS

    [self.serviceManager POST:kUploadLocInfo parameters:info progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSLog(@"111");
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

    
    
}
//获取Documents目录
-(NSString *)dirDoc{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

@end
