//
//  AppDelegate.m
//  auction
//
//  Created by wang on 10/17/15.
//  Copyright © 2015 carwins. All rights reserved.
//
#import <ShareSDK/ShareSDK.h>

#import "AppDelegate.h"

#import "ViewController.h"

#import "PromptViewController.h"

#import <ShareSDKConnector/ShareSDKConnector.h>

#import "WXApi.h"

//腾讯SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>

#import <TencentOpenAPI/QQApiInterface.h>

#import "AFNetworking/AFNetworking.h"

#import "JCNewVersion.h"

#import "APService.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   
    [[JCNewVersion shareInstance] isNewVersion:@""];
    //--------push
    
    // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
    
    
    //-------------ShareSDK-------------
  
    
    
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
//    [ShareSDK registerApp:@"be5deeec0f72"
//     
//          activePlatforms:@[
//                            
//                            @(SSDKPlatformTypeWechat)
//                            
//                            ]
//                 onImport:^(SSDKPlatformType platformType)
//     {
//         switch (platformType)
//         {
//             case SSDKPlatformTypeWechat:
//                 [ShareSDKConnector connectWeChat:[WXApi class]];
//                 break;
//                default:
//                 break;
//         }
//     }
//          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
//     {
//         
//         switch (platformType)
//         {
//           
//                 break;
//             case SSDKPlatformTypeWechat:
//                 [appInfo SSDKSetupWeChatByAppId:@"wx31adc95417c1d6e5"
//                                       appSecret:@"f940dcf799d92fa4b2eec95f5f5d68e4"];
//                 break;
//             default:
//                 break;
//         }
//     }];
 
    
    [ShareSDK registerApp:@"be5deeec0f72"
          activePlatforms:@[
                            // 不要使用微信总平台进行初始化
                            //@(SSDKPlatformTypeWechat),
                            // 使用微信子平台进行初始化，即可
                            @(SSDKPlatformSubTypeWechatSession),
                            @(SSDKPlatformSubTypeWechatTimeline),
                            @(SSDKPlatformSubTypeQQFriend),
                            @(SSDKPlatformSubTypeQZone)
                            ]
                 onImport:^(SSDKPlatformType platformType) {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                             break;
                         default:
                             break;
                     }
                     
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
              switch (platformType)
              {
                  case SSDKPlatformTypeWechat:
                      [appInfo SSDKSetupWeChatByAppId:@"wx31adc95417c1d6e5"
                                            appSecret:@"f940dcf799d92fa4b2eec95f5f5d68e4"];
                    
                      break;
                  case SSDKPlatformTypeQQ:
                      [appInfo SSDKSetupQQByAppId:@"1104973358"
                                           appKey:@"ANPyiFBdxlRSbPlm"
                                         authType:SSDKAuthTypeSSO];
                      
                      break;
                 
                  default:
                      break;
              }
          }];
    
    //提示！-----------
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *isture = [defaults objectForKey:@"isfirstlaunch"];
    
    if ([isture  isEqual: @"yes"]) {
        
        ViewController *view = [[ViewController alloc] init];
        
        
        //设置根控制器
        
        [self.window setRootViewController:view];
        
    }
    else{
    
        //创建一个控制器
        
        PromptViewController *prompt = [[PromptViewController alloc] init ];
        
        //设置根控制器
        
        [self.window setRootViewController:prompt];

    
         [self  IsFirstLaunch];
    }
    
   
    
    //显示
    
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}

//---------监测更新------------


//是不是首次转载app

-(void)IsFirstLaunch{

    NSUserDefaults *deuault = [NSUserDefaults standardUserDefaults];
    
    [deuault setObject:@"yes" forKey:@"isfirstlaunch"];
    
    [deuault synchronize];
    
}



//----------推送的方法开始------------

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
      NSLog(@"Token%@",[[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding]);
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

//-------------结束----------------

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    // Do something with the url here
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
