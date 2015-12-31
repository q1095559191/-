//
//  PromptViewController.m
//  auction
//
//  Created by 郑仁根 on 15/11/3.
//  Copyright © 2015年 carwins. All rights reserved.
//

#import "PromptViewController.h"
#import "ViewController.h"

@interface PromptViewController ()

@end

@implementation PromptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)GoMian:(id)sender {

    ViewController *viewController = [[ViewController alloc] init];
    
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:viewController animated:YES completion:nil];
    
    
}

//掩藏状态栏
-(BOOL)prefersStatusBarHidden{
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
