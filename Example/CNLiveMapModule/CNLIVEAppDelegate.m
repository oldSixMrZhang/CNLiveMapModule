//
//  CNLIVEAppDelegate.m
//  CNLiveSendPositonModule
//
//  Created by 郭瑞朋 on 11/19/2019.
//  Copyright (c) 2019 郭瑞朋. All rights reserved.
//

#import "CNLIVEAppDelegate.h"
#import <CNLiveEnvironment.h>
#import "CNLIVEViewController.h"
#import <QMUIKit/QMUIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>//定位功能

#import "BHTimeProfiler.h"
#import <mach-o/dyld.h>
#import "BHModuleManager.h"
#import "BHServiceManager.h"

@interface CNLIVEAppDelegate ()<BMKGeneralDelegate,BMKLocationAuthDelegate>

@end
@implementation CNLIVEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [BHContext shareInstance].application = application;
    [BHContext shareInstance].launchOptions = launchOptions;
    [BHContext shareInstance].moduleConfigName = @"BeeHive.bundle/BeeHive";//可选，默认为BeeHive.bundle/BeeHive.plist
    [BHContext shareInstance].serviceConfigName = @"BeeHive.bundle/BHService";
    [BeeHive shareInstance].enableException = YES;
    [[BeeHive shareInstance] setContext:[BHContext shareInstance]];
    [[BHTimeProfiler sharedTimeProfiler] recordEventTime:@"BeeHive::super start launch"];
    
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    // Override point for customization after application launch.
    [CNLiveEnvironmentManager setEnvironment:CNLiveDebugAppStore];
    ////
    //百度地图
    // 要使用百度地图，请先启动BaiduMapManager
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:BDMapAK authDelegate:self];
    // 要使用百度地图，请先启动BaiduMapManager
    BMKMapManager *_mapManager = [[BMKMapManager alloc] init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
    // 初始化定位SDK
    BOOL ret = [_mapManager start:BDMapAK  generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    /**
     全局设置地图SDK与开发者交互时的坐标类型。不调用此方法时，
     
     设置此坐标类型意味着2个方面的约定：
     1. 地图SDK认为开发者传入的所有坐标均为此类型；
     2. 所有地图SDK返回给开发者的坐标均为此类型；
     
     地图SDK默认使用BD09LL（BMK_COORDTYPE_BD09LL）坐标。
     如需使用GCJ02坐标，传入参数值为BMK_COORDTYPE_COMMON即可。ß
     本方法不支持传入WGS84（BMK_COORDTYPE_GPS）坐标。
     
     @param coorType 地图SDK全局使用的坐标类型
     @return 设置成功返回YES，设置失败返回False
     */
    [BMKMapManager setCoordinateTypeUsedInBaiduMapSDK: BMK_COORDTYPE_COMMON];
    ////
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    CNLIVEViewController *vc = [[CNLIVEViewController alloc] init];
    
    QMUINavigationController *nav = [[QMUINavigationController alloc]initWithRootViewController:vc];
    self.window.rootViewController = nav;//设置根视图控制器
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
