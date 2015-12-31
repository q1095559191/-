//
//  CustomShareView.m
//  auction
//
//  Created by Mac on 15/11/17.
//  Copyright © 2015年 carwins. All rights reserved.
//

#import "CustomShareView.h"

@implementation CustomShareView

+(instancetype)initView:(UIViewController *)ViewContorller{

    CGRect rect = ViewContorller.view.frame;
    
    CustomShareView *cusView = [[CustomShareView alloc] initWithFrame:CGRectMake(0, rect.size.height-rect.size.height/8.0, rect.size.width, rect.size.height/7)];
    
   // [cusView setBackgroundColor:[UIColor orangeColor]];
    
     
    
  
    

    return cusView;
}


@end
