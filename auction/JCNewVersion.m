

//
//  JCNewVersion.m
//  auction
//
//  Created by Mac on 15/12/14.
//  Copyright © 2015年 carwins. All rights reserved.
//

#import "JCNewVersion.h"
#import "AFNetworking/AFNetworking.h"

static JCNewVersion *shareObj = nil;
@implementation JCNewVersion


//单列
+(instancetype)shareInstance{


    @synchronized(self)
    {
    
        if (!shareObj) {
            
            shareObj = [[JCNewVersion alloc] init];
        }
    
    }
    
    return shareObj;
}

//单列2
+ (JCNewVersion *)sharedManager
{
    static JCNewVersion *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}


//IsNewVersion
-(void)isNewVersion:(NSString *)str{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *shortcut = @"carwins_auction_ipa";
    
    
    
    NSString *_api_key = @"981881eee56171aa61dc8b32b484e5c8";
    
    NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    
    [manager POST:@"http://www.pgyer.com/apiv1/app/getAppKeyByShortcut" parameters:[NSDictionary dictionaryWithObjectsAndKeys:shortcut,@"shortcut",_api_key,@"_api_key", nil] success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSDictionary *dic  = (NSDictionary *)responseObject;
        
        
        
        
        if ([str isEqualToString:@""]) {
            
            if ( [currentVersion doubleValue]<[[dic[@"data"] objectForKey:@"appVersion"] doubleValue]) {
                
                [[[UIAlertView alloc] initWithTitle:@"提示!" message:@"亲,发现新版本~" delegate:self cancelButtonTitle:@"去更新" otherButtonTitles:@"取消", nil] show];
                
            }
        }
        else{
        
        
            if ( [currentVersion doubleValue]<[[dic[@"data"] objectForKey:@"appVersion"] doubleValue]) {
                
                [[[UIAlertView alloc] initWithTitle:@"提示!" message:@"亲,发现新版本~" delegate:self cancelButtonTitle:@"去更新" otherButtonTitles:@"取消", nil] show];
                
            }
            
            else{
            
                
                [[[UIAlertView alloc] initWithTitle:@"提示!" message:@"已是最新版本~" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
            }
            
            
        }
        
       
        
        
        
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"gg");
    }];
    
}

 

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if (buttonIndex == 0 && [alertView.message isEqualToString:@"亲,发现新版本~"]) {
        
        //
        //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //
        //         NSString *_api_key = @"981881eee56171aa61dc8b32b484e5c8";
        ////
        ////       [ manager GET:@"http://www.pgyer.com/apiv1/app/install" parameters:[NSDictionary dictionaryWithObjectsAndKeys:self.aKey,@"aKey",_api_key,@"_api_key", nil] success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        ////
        ////
        ////        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        ////
        ////        }];
        ////
        
        
        //[view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http:www.baidu.com" ]]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=https%3A%2F%2Fwww.pgyer.com%2Fapiv1%2Fapp%2Fplist%3FaId%3Df01085ea3a0d032d96ce72f4aaa55001%26_api_key%3D981881eee56171aa61dc8b32b484e5c8"]];
        
        
        
        
        
        //  NSURL* url = [[NSURL alloc] initWithString:@"tel:110"];
        //  [[ UIApplication sharedApplication]openURL:url];
        
        
        // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"www.baidu.com"]];
        
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    }
    
}

@end
