//
//  JCNewVersion.h
//  auction
//
//  Created by Mac on 15/12/14.
//  Copyright © 2015年 carwins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCNewVersion : NSObject

+(instancetype)shareInstance;

-(void)isNewVersion:(NSString *)str;

+(JCNewVersion *)sharedManager;
@end
