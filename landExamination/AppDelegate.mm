//
//  AppDelegate.m
//  landExamination
//
//  Created by das on 16/11/5.
//  Copyright © 2016年 Chinastis. All rights reserved.
//

#import "AppDelegate.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "SQLManager.h"
#import "BNCoreServices.h"
#import "ServiceManager.h"
#import "LoginViewController.h"

@interface AppDelegate ()
{
    BMKMapManager* _mapManager;
    BMKLocationService* _locService;
//    NSTimer* _locRecoder;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //注册百度地图
    _mapManager = [[BMKMapManager alloc]init];
    //baiduMapAppKey : HvPaMF3GQZVshIW2Ky9WH3h27GxwYFGK
    //beidc测试key：lu9nFsPfmkNdYdcLT8OHYTLRp4ODxm8p
    BOOL ret = [_mapManager start:@"HvPaMF3GQZVshIW2Ky9WH3h27GxwYFGK"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"开启失败");
    }
    
    //初始化导航SDK
    [BNCoreServices_Instance initServices: @"HvPaMF3GQZVshIW2Ky9WH3h27GxwYFGK"];
    [BNCoreServices_Instance startServicesAsyn:nil fail:nil];
    
    SQLManager *sqlM = [SQLManager sharedManager];
    [sqlM initTable];
    
    
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动bmkmap定位服务
    [_locService startUserLocationService];
    
    //启动timer采集坐标数据
//    _locRecoder = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(uploadLocation) userInfo:nil repeats:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:loginVC];
    
    [self.window setRootViewController:navigationController];
    
    _deleteTasks = [NSMutableArray array];
    _backTasks = [NSMutableArray array];
    
    return YES;
}

- (void)uploadLocation{
    
    
    NSDictionary *locDict = @{
                                  @"gps_x":[NSString stringWithFormat:@"%f", _locService.userLocation.location.coordinate.longitude],
                                  @"gps_y":[NSString stringWithFormat:@"%f", _locService.userLocation.location.coordinate.latitude],
                                  @"gps_id":_userName};
    
//    NSLog(@"%@",locDict);
    [[ServiceManager sharedManger] uploadLocInfo:locDict];
    
    
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
   
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
