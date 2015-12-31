//
//  ViewController.m
//  auction
//
//  Created by wang on 10/17/15.
//  Copyright © 2015 carwins. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"
#import <ShareSDK/ShareSDK.h>
#import "AFNetworking.h"
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "CustomShareView.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "JCNewVersion.h"

// 自定义分享菜单栏需要导入的头文件
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>


@interface ViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *shakeBtn;

@property(nonatomic,assign) BOOL isViaWiFi; //判断是否用网络

@property(nonatomic,strong) UINavigationBar *navig;

@property (nonatomic,weak) UIImageView *NotConncetion;

@property(nonatomic,strong) MBProgressHUD *mbhud;

@property(nonatomic,assign) BOOL IsFirst;

@property(nonatomic,strong) UIButton *searchBtn; //筛选按钮

@property (nonatomic,strong) UILabel *lable; //文本框

@property (nonatomic,strong) UIButton *backBtn;//回退按钮

@property(nonatomic,strong)  UIButton *button;

@property (nonatomic,strong) UIImageView *carwinsIcon;//车赢图标

@property (nonatomic,strong) UITapGestureRecognizer *testure; //图片的点击手势

@property (nonatomic,strong) UILabel *lable_title; //网络差时，提示

@property (nonatomic,strong) CustomShareView *CVIew ;

@property (nonatomic,strong) UITapGestureRecognizer *testure_web; //webView的点击手势

@property (nonatomic,assign) CGRect rect_web;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    
    //调用监测网络
    
    self.IsFirst = YES;
    
    [self clean]; //清除缓存
    
    [self loadwebView];
    
    [self loadController];
   
    
}



-(void)loadData{
    
    UIButton *btn  = [[UIButton alloc] initWithFrame:CGRectMake(20,self.view.bounds.size.height-150, 45, 45)];
    
    [btn setTitle:@"检测" forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(jianceNewVersion) forControlEvents:UIControlEventTouchUpInside];
    
    [btn setFont:[UIFont systemFontOfSize:12]];
    
    [btn setBackgroundColor:[UIColor redColor]];
    
    [btn.layer setMasksToBounds:YES];
    
    btn.layer.cornerRadius = 22.5;
    
    if (!self.button) {
        
        self.button = btn;
    }
    
    
}
//检测新版本
-(void)jianceNewVersion{

    [[JCNewVersion sharedManager] isNewVersion:@"1"];

    [self.button setEnabled:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.button setEnabled:YES];
    });
}

//-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    
//    CGPoint point = [[touches anyObject] locationInView:webView];
//    
//    self.button.center = point;
//    
//    
//}

/**
 *  监测服务器是否正常
 */
-(void)IsNormal{
    
    
    NSString *str = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if ( [str isEqualToString:@"无法找到资源。"]||[str  isEqual: @"Not Found"] ||[str  isEqual: @""]|| !str  || [str  isEqual: @"编译错误"] || [str  isEqual: @"Service Unavailable"]) {
        
        [self AlertView:@"服务器异常，请刷新重试"];
    }
    
    [self.view setAlpha:1];
    [self.mbhud setHidden:YES];
}

///**
// *  开始加载
// *
// *  @param webView <#webView description#>
// */
-(void)webViewDidStartLoad:(UIWebView *)webView{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"加载中";
    
    // hud.detailsLabelText = @"Test detail";
    
    [self.view setAlpha:0.5];
    
    self.mbhud = hud;
    
    [hud show:YES];
    
}


/**
 *  加载WebView
 */
-(void)loadwebView{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = 10;
    
    NSString *shortcut = @"carwins_auction_ipa";
    
    NSString *_api_key = @"981881eee56171aa61dc8b32b484e5c8";
    
    
    [manager POST:@"http://www.pgyer.com/apiv1/app/getAppKeyByShortcut" parameters:[NSDictionary dictionaryWithObjectsAndKeys:shortcut,@"shortcut",_api_key,@"_api_key", nil] success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        
        [self loadwebViewData ];
        
        
        
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        self.isViaWiFi = YES;
        [self loadwebViewData];
    }];
    
    
    
}

-(void)clean{

    
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];

}




-(void)jianceWifi{

    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];//开启监测
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: //未知的网络
                
                 self.isViaWiFi = YES;
                //[webView reload];
                break;
            case AFNetworkReachabilityStatusNotReachable: //无网络
                
                //[self AlertView];
                //[self reload];
                 self.isViaWiFi = NO;
                break;
            
            case AFNetworkReachabilityStatusReachableViaWiFi: //WIfi网络
                 self.isViaWiFi = YES;
                 //[webView reload];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN: //手机网络
                
                 self.isViaWiFi = YES;
                //[webView reload];
                
                break;
                
                
            default:
                break;
        }
        
    }];

}






/**
 *  有图片的下拉刷新
 */
-(void)imageWithReload{
    
    
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    
    
    
    NSMutableArray *img_arred = [NSMutableArray  array];
    
    //    for (int i = 1; i < 61; i++) {
    //
    //        UIImage * img= [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__000%d",i]];
    //
    //        [img_arring addObject:img];
    //
    //    }
    //
    //    for (int i = 1; i < 3; i++) {
    //
    //        UIImage * img= [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%d",i]];
    //
    //        [img_arred addObject:img];
    //
    //    }
    
    //    for (int i = 1; i < 31; i++) {
    //
    //        UIImage * img= [UIImage imageNamed:[NSString stringWithFormat:@"redcar%d",i]];
    //
    //        [img_arring addObject:img];
    //
    //    }
    //
    //    for (int i = 1; i < 3; i++) {
    //
    //        UIImage * img= [UIImage imageNamed:[NSString stringWithFormat:@"redcar%d",i]];
    //
    //        [img_arred addObject:img];
    //
    //    }
    
    
    for (int i = 1; i <=2; i++) {
        
        UIImage * img= [UIImage imageNamed:[NSString stringWithFormat:@"ajax_loading(3)%d",i]];
        
        [img_arred addObject:img];
        
    }
    
    // 设置普通状态的动画图片
    [header setImages:@[[UIImage imageNamed:@"ajax_loading(3)1"]] forState:MJRefreshStateIdle];
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    [header setImages:img_arred forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [header setImages:img_arred forState:MJRefreshStateRefreshing];
    // 设置header
    webView.scrollView.header = header;
}

-(void)loadNewData{
    
    [self removeCustomShare];
    
    [self reload:[webView stringByEvaluatingJavaScriptFromString:@"document.location.href"]];
    //
    [webView.scrollView.header endRefreshing];
    
    
}


////掩藏状态栏
//-(BOOL)prefersStatusBarHidden{
//
//    return YES;
//}

//刷新webview
-(void)reload:(NSString *)str{

    if ([str isEqualToString:@"about:blank"]) {
        
        str = @"http://m.auction.carwins.cn";
    }
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:str]];
    
    [webView loadRequest:request];
}

//加载控件

-(void)loadController{

    CGRect rect  = [[UIApplication sharedApplication] statusBarFrame];
 
    
    //------------创建一个tabbar-----------------
    
    UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, self.view.bounds.size.width, 44)];
    
    [nav setBarTintColor :[UIColor colorWithRed:228/255.0f green:128/255.0f blue:30/255.0f alpha:1]];
    
    UINavigationBar *bar =[UINavigationBar appearance];
    [bar setBarTintColor:[UIColor orangeColor]];
    [bar setTintColor:[UIColor whiteColor]];
    //[bar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:228/255 green:128/255 blue:30/255 alpha:1]}];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

//    
//    UINavigationItem *item_title = [[UINavigationItem alloc] initWithTitle:@"我要拍车"];
//
//    
//    [nav addSubview:item_title];

    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 20)] ;
    
    [la  setText:@"我要拍车"];
    
    [la setTextColor:[UIColor whiteColor]];
    
    [la setTextAlignment:NSTextAlignmentCenter];
    
    [la setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    
    
    
    [la setCenter:CGPointMake(nav.center.x, nav.center.y+8)];
    
    self.lable = la;
    
    [nav addSubview:la];
    
    [self.view addSubview:nav];
    
    self.navig = nav;
    
}


/**
 *  加载WebView
 */
-(void)loadwebViewData{
   
   

    CGRect rect  = [[UIApplication sharedApplication] statusBarFrame];
    //    NSLog(@"rect.height = %f,rect.width = %f,rect.x = %f,rect.y = %f",rect.size.height,rect.size.width,rect.origin.x,rect.origin.y);
    CGRect rx = [ UIScreen mainScreen ].bounds;
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(rx.origin.x, self.view.frame.origin.y+44, rx.size.width, rx.size.height-44)];
    
    //webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.auction.carwins.cn"]];
    [webView setUserInteractionEnabled:YES];
    
     [webView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview: webView];
    [webView setDelegate:self];
    [webView loadRequest:request];
   
    [self loadshakeBtn];//分享按钮
    
    [self loadsearch];//搜索按钮
    
    [self loadBack];//返回按钮
    
    [self loadData];//检测按钮

    

}
//加载分享按钮
-(void)loadshakeBtn{

    UIButton *Icon_btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-40,15 , 35, 30)];
    
    [Icon_btn setFont:[UIFont systemFontOfSize:14]];
    
    [Icon_btn addTarget:self action:@selector(shake) forControlEvents:UIControlEventTouchUpInside];
    
    [Icon_btn setTitle:@"分享" forState:UIControlStateNormal];
    
    self.shakeBtn   =  Icon_btn ;
 
}

/**
 *  加载搜索按钮
 */
-(void)loadsearch{
    
    
    UIButton *Icon_btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-40,15 , 35, 30)];
    
    [Icon_btn setFont:[UIFont systemFontOfSize:14]];
    
    [Icon_btn addTarget:self action:@selector(choose) forControlEvents:UIControlEventTouchUpInside];
    
    [Icon_btn setTitle:@"筛选" forState:UIControlStateNormal];
    
    self.searchBtn   =  Icon_btn ;
    
}
/**
 *  回退按钮
 */
-(void)loadBack{
    
    
    UIButton *Icon_btn = [[UIButton alloc] initWithFrame:CGRectMake(3,20 , 15, 20)];
    
    [Icon_btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [Icon_btn setBackgroundImage:[UIImage imageNamed:@"back2"] forState:UIControlStateNormal];
    
    self.backBtn   =  Icon_btn ;
    
}

//-(void)loadcarWinsIcon{
//    
//    
//    UIImageView  *Icon_btn = [[UIImageView alloc] initWithFrame:CGRectMake(3,15 , 95, 30)];
//    
//    [Icon_btn setImage:[UIImage imageNamed:@"font_l"]];
//    
//    self.carwinsIcon   =  Icon_btn ;
//    
//}



-(void)back{

    [self reload:@"http://m.auction.carwins.cn/"];

}


-(void)downreload {

    webView.scrollView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        //        if (self.isViaWiFi) {
        //
        //            [webView reload];
        //        }
        //
        //        else{
        //
        //
        //
        //        }
        //        [self jianceWifi];
        
        [self removeCustomShare];
        
        
        [self reload:[webView stringByEvaluatingJavaScriptFromString:@"document.location.href"]];
        
        [webView.scrollView.header endRefreshing];
    }];
    

}

#pragma mark webView的delegate方法

-(void)webViewDidFinishLoad:(UIWebView *)webView{

    
    
     [self setMainTitle];
    
    
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    
    NSRange car_range = [currentURL rangeOfString:@"auctiondetail"];
    
    NSString *login_str = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldCarName').innerText"];
    
    // NSString *load = [webView stringByEvaluatingJavaScriptFromString:@"$('.head_inner:visible:last').find('span').text()"];
    
     NSString *load = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('list_wrapper').getElementsByClassName('head_inner')[0].getElementsByTagName('span')[0].innerText"];
    
    [webView setAlpha:1];
 
    //NSString *currentitle = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('list_wrapper').getElementsByClassName('head_inner')[0].getElementsByTagName('span')[0].innerText"];
    
    //NSString *aaxx = [webView stringByEvaluatingJavaScriptFromString:@"$('.head_inner:visible:last').find('span').text()"];
   
    // NSLog(@"我要日狗---------------%@",aaxx);
    
    //判断是不是否进入了商品详情页
//    if (car_range.length > 0 || ![load isEqualToString:@"登录"]) {
//        
//        
//        [self.view addSubview:self.shakeBtn];
//        
//        
//    }

    /**
     *  如何是主页和详情页则让下拉刷新
     */
    
    if ([load isEqualToString:@"我要拍车"] || [load isEqualToString:@"车辆竞价"] || [load isEqualToString:@"参与的竞拍"]  || [load isEqualToString:@"成功竞拍详情"] ) {
        
     
        
        
      
        
        if ([load isEqualToString:@"参与的竞拍"]) {
            
            [self.searchBtn removeFromSuperview];
            
            int i = [[webView stringByEvaluatingJavaScriptFromString:@"$('#login_wrapper:visible').length"] intValue];
            
            
            if (i == 0) {
                
                //[self downreload];
                
                [self imageWithReload];
                 webView.scrollView.bounces = YES;
                
            }
            
            else{
            
                 webView.scrollView.bounces = NO;
                
                 webView.scrollView.header = nil;
            
            }
            
        }
        else{
            
             webView.scrollView.bounces = YES;
           
            [self imageWithReload];
            // [self downreload];
            
        }
        
        
    }
    else{
        
        webView.scrollView.bounces = NO;

        
         webView.scrollView.header = nil;
    
        
    
    }
    
    
//    if ([load isEqualToString:@"我要拍车"] || [load isEqualToString:@"车辆竞价"] || [load isEqualToString:@"参与的竞拍"] || [load isEqualToString:@"成功竞拍详情"] || [load isEqualToString:@"商户中心"] ) {
//        
//       
//        
//        [self.view addSubview:self.carwinsIcon];
//    }
//    
//    else{
//        
//        
//        [self.carwinsIcon removeFromSuperview];
//        
//    }
    
    if ([load isEqualToString:@"登录"] ) {
        
        [self.view addSubview:self.backBtn];
    }
    
    else{
    
        [self.backBtn removeFromSuperview];
    
    }
    if ([load isEqualToString:@"车辆竞价"] || [load isEqualToString:@"成功竞拍详情"]) {
        
        
        [self.view addSubview:self.shakeBtn];
        
        
    }

    else {
    
        
        if ([[[self.shakeBtn titleLabel] text]  isEqual: @"分享"]) {
            
            [self.shakeBtn removeFromSuperview];
        }
        
    }
    
    
    //判断是不是主页
    
    if ([currentURL isEqualToString:@"http://m.auction.carwins.cn/"]|| [currentURL isEqualToString:@"http://m.auction.carwins.cn/Home/auctionlist"] || [load isEqualToString:@"参与的竞拍"] ) {
        
        if ([load isEqualToString:@"参与的竞拍"]) {
            
            [self.searchBtn removeFromSuperview];
            
            int i = [[webView stringByEvaluatingJavaScriptFromString:@"$('#login_wrapper:visible').length"] intValue];
            
            
            if (i == 0) {
                
                [self.view addSubview:self.searchBtn];
                
                
            }
            
            NSLog(@"%d",i);
            
        }
        else{
        
            [self.view addSubview:self.searchBtn];
        
        }
        
        
        
    }
    
    else{
    
        if (self.searchBtn) {
            
            [self.searchBtn  removeFromSuperview ];
        }
    
    }
    
    
    if ([currentURL isEqualToString:@"http://m.auction.carwins.cn/"] || [currentURL isEqualToString:@"http://m.auction.carwins.cn/Home/auctionlist"]) {
        
        [webView addSubview:self.button];

        
    }
    
    else{
    
        [self.button removeFromSuperview];
    
    }
   
    
    [self IsNormal];
    
    NSLog(@"sucess");
    
}


-(void)setMainTitle{

    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('list_wrapper').getElementsByClassName('head_inner')[0].getElementsByTagName('span')[0].innerText"];
    

//    if (self.lable_title) {
//        
//        
//        
//        
//        [UIView animateWithDuration:1.0 animations:^{
//            //放入你的代码
//            
//            [self.lable_title setAlpha:0];
//            
//            [self.lable_title setText:@""];
//            
//            [self.lable_title removeFromSuperview];
//
//        }];
//        
//        
//    }
    
    
   // NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"$('.head_inner:visible:last').find('span').text()"];
    /**
     *  判断是不是无网络，然后连接上网络
     */
    if (self.isViaWiFi) {
        
        if (self.NotConncetion) {
            
            
            NSLog(@"删掉img");
            
            [self.NotConncetion removeGestureRecognizer:self.testure];
            
            [UIView animateWithDuration:1 animations:^{
                
                [self.NotConncetion setAlpha:0];
                
                [self.NotConncetion removeFromSuperview];
                

            }];
           
        }
    }
    
    
    self.lable.text = currentURL;
    
    if (self.searchBtn) {
        
        [self.searchBtn setAlpha:1];
    }
    
    
    
    
}

-(void)choose{

    
    
    [webView stringByEvaluatingJavaScriptFromString:@"function ciao () {$('#filter_wrapper').show();$('#list_wrapper').hide();if ($('.filterbox-l ul li:visible.cur').length == 0)$('.filterbox-l ul li:visible:first').addClass('cur').siblings('li').removeClass('cur');if ($('#brandfiter_cont .brand_main .brand_item').length == 0) {ajaxobj.initajax(\"BrandHanlder.ashx\", \"GetStockBrandList\", \"GetStockBrandList\", { cityID: AreaID, subId: sidiaryID });}if ($('#typefiter_cont ul li').length == 0) {ajaxobj.initajax(\"CarHanlder.ashx\", \"GetCarTypeAll\", \"GetCarTypeAll\");}$('#spanplace').text(getCookie('placeName') == '' ? $('#spanplace').data('orgin') : getCookie('placeName'));$('#place .filter-li a[data-id=' + getCookie('placeID') + ']').addClass('cur');} "];
    
    [webView stringByEvaluatingJavaScriptFromString:@"ciao();"];
    
    NSLog(@"---");

}
#pragma mark share

-(void)shake{
    

    
    
   //  [self shareTest1];
    
   //[self shareTest2];
   
   //[self shareTest3];
    
   [UIView  animateWithDuration:1.0 animations:^{
       
       [self CustomShare];
   }];
}



#pragma webViewDelegate method

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{

    [self IsNormal];
    
//判断网络是否连接，以及网络是否超时
    if(error.code == NSURLErrorNotConnectedToInternet || error.code ==  NSURLErrorTimedOut || error.code == NSURLErrorFileDoesNotExist|| error.code == NSURLErrorCannotFindHost)
    {
        
        if ([[webView stringByEvaluatingJavaScriptFromString:@"document.location.href"] isEqualToString:@"about:blank"]) {
            
             [webView setAlpha:1];
        }
        
        else{
        
            [webView setAlpha:0.1];
            
            
    
        }
        
        [self jianceWifi];
      
        
        

        
      //  if (self.IsFirst) {


 


            webView.scrollView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                
                //        if (self.isViaWiFi) {
                //
                //            [webView reload];
                //        }
                //
                //        else{
                //
                //
                //
                //        }
                //        [self jianceWifi];
                
                [self reload:[webView stringByEvaluatingJavaScriptFromString:@"document.location.href"]];
                
                [webView.scrollView.header endRefreshing];
            }];
            
        
        /**
         *  如果不为空测代表已经是断网状态下的点击则不创建新对象
         */
            
            if (!self.NotConncetion) {
                
                UIImageView *iv = [[UIImageView alloc] initWithFrame:self.view.frame];
                
                [iv setImage:[UIImage imageNamed:@"error2"]];
                
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refresh)];
                
                self.testure = tap;
                
                [iv addGestureRecognizer:tap];
                
                
                [iv setUserInteractionEnabled:YES];
                
                self.NotConncetion = iv;
                
                [self.view addSubview:iv];
                
            }
            
   
                self.IsFirst = !self.IsFirst;
            
            
            if (self.searchBtn) {
                
                [self.searchBtn setAlpha:0];
            }
        
        
//    }
//    
//        else{
//        
//         
//            if (!self.NotConncetion) {
//                
//               
//                if (!self.lable_title) {
//                    
//                    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-100, 50)];
//                    
//                    [lable setCenter:self.view.center];
//                    
//                    [lable setText:@"亲！网络不好，请下拉刷新重试"];
//                    
//                    self.lable_title = lable;
//                    
//                    [self.view addSubview:lable];
//                }
//               
//            }
//        
//        
//        }
        
        
        
    
    }

}
/**
 *  手势执行的方法
 */

-(void)refresh{

    

    NSString *string = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
  
    [self reload:string];
    
}

-(void)AlertView:(NSString *)str{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    
    [alertView show];

}

-(void)dealloc{

    [webView removeObserver:self forKeyPath:@"contentOffset"];
}



-(void)shareTest1{

    
    NSString *login_str = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldCarName').innerText"];
    
    
    NSString *login_str3 = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldPlateFirstDate').innerText"];
    
    NSString *login_str4 = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldKM').innerText"];
    
    NSString *strshare = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    //  NSString *img_src = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('picSlide').children[0].children[0].children[0].children[0].src"];
    //    ;
    NSString *img_src = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('picSlide').children[0].getElementsByTagName('img')[0].src"];
    ;
    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img_src]]];
    //创建分享参数
    NSArray* imageArray = [NSArray arrayWithObjects:img, nil];
    //（注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    
    
    
    
    if (imageArray) {
        
        NSString *share_url = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@\n首次上牌时间:%@\n售价:%@",login_str,login_str3,login_str4 ]
                                         images:imageArray
                                            url:[NSURL URLWithString:share_url]
                                          title:strshare
                                           type:SSDKContentTypeAuto];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               
                               NSString *domin  = nil;
                               
                               if (error.code == 105) {
                                   
                                   domin = @"亲，未监测到微信客户端哦~";
                               }
                               
                               else{
                                   
                                   domin = [NSString stringWithFormat:@"%@",error];
                                   
                               }
                               
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:domin
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               //                           {
                               //                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"卧槽" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                               //
                               //                               [alert show];
                               //                           }
                               break;
                       }
                       
                   }];
        
        
    }

}


-(void)shareTest2{
    
    NSString *login_str = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldCarName').innerText"];
    
    
    NSString *login_str3 = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldPlateFirstDate').innerText"];
    
    NSString *login_str4 = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldKM').innerText"];
    
    NSString *strshare = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    NSString *img_src = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('picSlide').children[0].getElementsByTagName('img')[0].src"];
           ;
    NSString *share_url = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];//分享的URL
    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img_src]]];
    
    NSArray* imageArray = @[img];
    //1、创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    // （注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    
    
    [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@\n首次上牌时间:%@\n售价:%@",login_str,login_str3,login_str4 ] images:imageArray url:[NSURL URLWithString:share_url] title:strshare type:SSDKContentTypeAuto];
    
    
    
    // 设置分享菜单栏样式（非必要）
    // 设置分享菜单的背景颜色
    
   // [SSUIShareActionSheetStyle setActionSheetBackgroundColor:[UIColor colorWithRed:249/255.0 green:0/255.0 blue:12/255.0 alpha:0.5]];
    
    // 设置分享菜单颜色
    [SSUIShareActionSheetStyle setActionSheetColor:[UIColor whiteColor]];
    //[SSUIShareActionSheetStyle setActionSheetColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    
    // 设置分享菜单－取消按钮背景颜色
    [SSUIShareActionSheetStyle setCancelButtonBackgroundColor:[UIColor whiteColor]];
    //[SSUIShareActionSheetStyle setCancelButtonBackgroundColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    
    // 设置分享菜单－取消按钮的文本颜色
    [SSUIShareActionSheetStyle setCancelButtonLabelColor:[UIColor blackColor]];
    // 设置分享菜单－社交平台文本颜色
    [SSUIShareActionSheetStyle setItemNameColor:[UIColor blackColor]];
    // 设置分享菜单－社交平台文本字体
    [SSUIShareActionSheetStyle setItemNameFont:[UIFont systemFontOfSize:10]];
    
    //2、弹出ShareSDK分享菜单
    [ShareSDK showShareActionSheet:self.view items:@[
                                                     // 不要使用微信总平台进行初始化
                                                     //@(SSDKPlatformTypeWechat),
                                                     // 使用微信子平台进行初始化，即可
                                                     @(SSDKPlatformSubTypeWechatSession),
                                                     @(SSDKPlatformSubTypeWechatTimeline),
                                                     @(SSDKPlatformSubTypeQQFriend)
                                                     ]  shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                                                         NSString *domin  = nil;
                                                         
                                                         if (error.code == 105) {
                                                             
                                                             domin = @"亲，未监测到微信客户端哦~";
                                                         }
                                                         
                                                         else{
                                                         
                                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                                                             message:domin
                                                                                                            delegate:nil
                                                                                                   cancelButtonTitle:@"OK"
                                                                                                   otherButtonTitles:nil, nil];
                                                             [alert show];
                                                         }
                                                        

        
    }];
    
}

-(void)shareTest3{
    
    
    NSString *login_str = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldCarName').innerText"];//车名
    
    NSString *login_str3 = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldPlateFirstDate').innerText"];//首次上牌时间
    
    NSString *login_str4 = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldKM').innerText"];//价钱
    
    NSString *strshare = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    NSString *share_url = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    
    NSString *img_src = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('picSlide').children[0].getElementsByTagName('img')[0].src"];
    
    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img_src]]];
    
    NSArray* imageArray = @[img];
    
    
    //先构造分享参数：
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@\n首次上牌时间:%@\n售价:%@",login_str,login_str3,login_str4 ]
                                     images:imageArray
                                        url:[NSURL URLWithString:share_url]
                                      title:strshare
                                       type:SSDKContentTypeAuto];
    //调用分享的方法
    SSUIShareActionSheetController *sheet = [ShareSDK showShareActionSheet:self.view
                                                                     items:nil
                                                               shareParams:shareParams
                                                       onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                                                           switch (state) {
                                                               case SSDKResponseStateSuccess:
                                                                   NSLog(@"分享成功!");
                                                                   break;
                                                               case SSDKResponseStateFail:
                                                                   NSLog(@"分享失败%@",error);
                                                                   break;
                                                               case SSDKResponseStateCancel:
                                                                   NSLog(@"分享已取消");
                                                                   break;
                                                               default:
                                                                   break;
                                                           }
                                                       }];
    //删除和添加平台示例
    [sheet.directSharePlatforms removeObject:@(SSDKPlatformTypeWechat)];//(默认微信，QQ，QQ空间都是直接跳客户端分享，加了这个方法之后，可以跳分享编辑界面分享)
    [sheet.directSharePlatforms addObject:@(SSDKPlatformTypeSinaWeibo)];//（加了这个方法之后可以不跳分享编辑界面，直接点击分享菜单里的选项，直接分享）
    
}


-(void)CustomShare{
    
    
    if (!self.CVIew) {
    
       
      
        
        [webView setAlpha:0.2];
        
        
        CustomShareView  *cusView =  [CustomShareView initView:self];
        
        if (self.rect_web.size.height != 0) {
            
            cusView.frame = self.rect_web;
            
        }
        
        self.CVIew = cusView;
        
         [self addtapture];
        
        [cusView setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat float_y = cusView.bounds.size.width/4;
        
        CGFloat float_width = cusView.bounds.size.height;
        
        
//        UIButton *wechat = [[UIButton alloc] initWithFrame:CGRectMake(0,0 , cusView.bounds.size.height, cusView.bounds.size.height)];
//        
//        UIButton *wechatFirend = [[UIButton alloc] initWithFrame:CGRectMake(float_width-1 ,0 , cusView.bounds.size.height, cusView.bounds.size.height)];
//        
//        UIButton *QQ = [[UIButton alloc] initWithFrame:CGRectMake(float_width *2-1,0 , cusView.bounds.size.height, cusView.bounds.size.height)];
//        
//        UIButton *QQZone = [[UIButton alloc] initWithFrame:CGRectMake(float_width *3-1,0 , cusView.bounds.size.height, cusView.bounds.size.height)];
//        
//        
//        //--微信好友
//        [wechat setBackgroundImage:[UIImage imageNamed:@"weChat"] forState:UIControlStateNormal];
//        
//        [wechat setTitle:@"微信好友" forState:UIControlStateNormal];
//        
//        [wechat addTarget:self action:@selector(testShare) forControlEvents:UIControlEventTouchUpInside];
//        
//        
//        //--朋友圈
//        [wechatFirend setBackgroundImage:[UIImage imageNamed:@"weChatFirend"] forState:UIControlStateNormal];
//        
//        [wechatFirend setTitle:@"朋友圈" forState:UIControlStateNormal];
//        
//        //--QQ好友
//        [QQ setBackgroundImage:[UIImage imageNamed:@"QQ"] forState:UIControlStateNormal];
//        
//        [QQ setTitle:@"QQ" forState:UIControlStateNormal];
//        
//        //--QQ空间
//        [QQZone setBackgroundImage:[UIImage imageNamed:@"QQZone"] forState:UIControlStateNormal];
//        
//        [QQZone setTitle:@"QQ空间" forState:UIControlStateNormal];
//        
//        [cusView addSubview:wechat];
//        [cusView addSubview:wechatFirend];
//        [cusView addSubview:QQ];
//        [cusView addSubview:QQZone];

      
                
                
//                [webView setAlpha:0.5];
//                
//                
//                CustomShareView  *cusView =  [CustomShareView initView:self];
//                
//                [cusView setBackgroundColor:[UIColor whiteColor]];
//                
//                CGFloat float_y = cusView.bounds.size.width/4;
//                
//                CGFloat float_width = cusView.bounds.size.height;
        
                
                UIButton *wechat = [[UIButton alloc] initWithFrame:CGRectMake(0,0 , cusView.bounds.size.height, cusView.bounds.size.height)];
                
                UIButton *wechatFirend = [[UIButton alloc] initWithFrame:CGRectMake(float_width-1 ,0 , cusView.bounds.size.height, cusView.bounds.size.height)];
                
                UIButton *QQ = [[UIButton alloc] initWithFrame:CGRectMake(float_width *2-1,0 , cusView.bounds.size.height, cusView.bounds.size.height)];
                
                UIButton *QQZone = [[UIButton alloc] initWithFrame:CGRectMake(float_width *3-1,0 , cusView.bounds.size.height, cusView.bounds.size.height)];
                
                UIImageView *imgv1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
                
                
                [imgv1 setImage:[UIImage imageNamed:@"weChat"]];
                
                [imgv1 setCenter:CGPointMake(wechat.center.x, wechat.center.y-15)];
                
                [cusView addSubview:imgv1];
                
                UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wechat.bounds.size.width, 20)];
                
                [lbl1 setCenter:CGPointMake(lbl1.center.x, wechat.center.y+10)];
                
                [lbl1 setTextAlignment:NSTextAlignmentCenter];
                
                [lbl1 setText:@"微信好友"];
                
                [lbl1 setFont:[UIFont systemFontOfSize:11]];
                
                [cusView addSubview:lbl1];
                
                //-------朋友圈图片
                
                UIImageView *imgv2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
                
                [imgv2 setImage:[UIImage imageNamed:@"weChatFirend"]];
                
                [imgv2 setCenter:CGPointMake(wechatFirend.center.x, wechatFirend.center.y-15)];
                
                [cusView addSubview:imgv2];
                
                UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wechat.bounds.size.width, 20)];
                
                [lbl2 setCenter:CGPointMake(wechatFirend.center.x, wechatFirend.center.y+10)];
                
                [lbl2 setTextAlignment:NSTextAlignmentCenter];
                
                [lbl2 setText:@"朋友圈"];
                
                [lbl2 setFont:[UIFont systemFontOfSize:11]];
                
                [cusView addSubview:lbl2];
                
                //-------QQ图片
                UIImageView *imgv3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
                
                [imgv3 setImage:[UIImage imageNamed:@"QQ"]];
                
                [imgv3 setCenter:CGPointMake(QQ.center.x, QQ.center.y-15)];
                
                [cusView addSubview:imgv3];
                
                UILabel *lbl3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wechat.bounds.size.width, 20)];
                
                [lbl3 setCenter:CGPointMake(QQ.center.x, QQ.center.y+10)];
                
                [lbl3 setTextAlignment:NSTextAlignmentCenter];
                
                [lbl3 setText:@"QQ好友"];
                
                [lbl3 setFont:[UIFont systemFontOfSize:11]];
                
                [cusView addSubview:lbl3];
                
                
                //----------QQ空间
                UIImageView *imgv4 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
                
                [imgv4 setImage:[UIImage imageNamed:@"QQZone"]];
                
                [imgv4 setCenter:CGPointMake(QQZone.center.x, QQZone.center.y-15)];
                
                [cusView addSubview:imgv4];
                
                UILabel *lbl4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wechat.bounds.size.width, 20)];
                
                [lbl4 setCenter:CGPointMake(QQZone.center.x, QQZone.center.y+10)];
                
                [lbl4 setTextAlignment:NSTextAlignmentCenter];
                
                [lbl4 setText:@"QQ空间"];
                
                [lbl4 setFont:[UIFont systemFontOfSize:11]];
                
                [cusView addSubview:lbl4];
                
                //--微信好友
                //[wechat setBackgroundImage:[UIImage imageNamed:@"weChat"] forState:UIControlStateNormal];
                
                //[wechat setTitle:@"微信好友" forState:UIControlStateNormal];
                
        [wechat addTarget:self action:@selector(testShare:) forControlEvents:UIControlEventTouchUpInside];
        
                [wechat setTag:22]; //微信好友
        
                
        [wechatFirend addTarget:self action:@selector(testShare:) forControlEvents:UIControlEventTouchUpInside];
        
                [wechatFirend setTag:23];//朋友圈
        
        [QQ addTarget:self action:@selector(testShare:) forControlEvents:UIControlEventTouchUpInside];
        
                [QQ setTag:24];
        
        [QQZone addTarget:self action:@selector(testShare:) forControlEvents:UIControlEventTouchUpInside];
        
                [QQZone setTag:6];
        
                //--朋友圈
                //        [wechatFirend setBackgroundImage:[UIImage imageNamed:@"weChatFirend"] forState:UIControlStateNormal];
                //        
                //        [wechatFirend setTitle:@"朋友圈" forState:UIControlStateNormal];
                
                //--QQ好友
                //        [QQ setBackgroundImage:[UIImage imageNamed:@"QQ"] forState:UIControlStateNormal];
                //        
                //        [QQ setTitle:@"QQ" forState:UIControlStateNormal];
                
                //--QQ空间
                //        [QQZone setBackgroundImage:[UIImage imageNamed:@"QQZone"] forState:UIControlStateNormal];
                //        
                //        [QQZone setTitle:@"QQ空间" forState:UIControlStateNormal];
                
                [cusView addSubview:wechat];
                [cusView addSubview:wechatFirend];
                [cusView addSubview:QQ];
                [cusView addSubview:QQZone];
                
                [cusView setBackgroundColor:[UIColor whiteColor]];
                
                
                [self.view addSubview:cusView];
                
     
    
    
   }


}


-(void)testShare:(id)sender{

    int tag = [sender tag];
    
    NSString *login_str = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldCarName').innerText"];
    
    
    NSString *login_str3 = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldPlateFirstDate').innerText"];
    
    NSString *login_str4 = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('fldKM').innerText"];
    
    NSString *strshare = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    NSString *img_src = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('picSlide').children[0].getElementsByTagName('img')[0].src"];
    ;
    NSString *share_url = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];//分享的URL
    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img_src]]];
    
    NSArray* imageArray = @[img];
    //1、创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    // （注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    
    
    [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@\n首次上牌时间:%@\n售价:%@",login_str,login_str3,login_str4 ] images:imageArray url:[NSURL URLWithString:share_url] title:strshare type:SSDKContentTypeAuto];
    
    
    /**
     *  分享内容
     *
     *  @param platformType             平台类型
     *  @param parameters               分享参数
     *  @param stateChangeHandler       状态变更回调处理
     */
//        + (void)share:(SSDKPlatformType)platformType
//    parameters:(NSMutableDictionary *)parameters
//    onStateChanged:(SSDKShareStateChangedHandler)stateChangedHandler;
    /*
     
     @[
     // 不要使用微信总平台进行初始化
     //@(SSDKPlatformTypeWechat),
     // 使用微信子平台进行初始化，即可
     @(SSDKPlatformSubTypeWechatSession),
     @(SSDKPlatformSubTypeWechatTimeline),
     @(SSDKPlatformSubTypeQQFriend)
     ]
     
     */

    NSLog(@"%d",tag);
    
        [ShareSDK share: tag  parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    
            switch (state) {
                case SSDKResponseStateSuccess:
                   
                     [self showView];
                    
                    [self removeCustomShare];
                    
                   
                    //[self AlertView:@"分享成功"];
                    break;
                case SSDKResponseStateFail:
                    
                    if (error.code == 105 || error.code == 208) {
                        
                        [self AlertView:@"亲，未监测到微信客户端哦~"];
                        
                    }
                    else{
                    
                        NSLog(@"分享失败%@",error);
                    
                        [self AlertView:@"分享失败!"];
                    }
                    
                    break;
                case SSDKResponseStateCancel:
                    [self removeCustomShare];
                    NSLog(@"分享已取消");
                    break;
                default:
                    break;
            }
    
        }];

}

/**
 *  为webView添加手势
 *
 *  @return
 */
-(void)addtapture{

    if (self.CVIew) {
        
        UITapGestureRecognizer *tapture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeCustomShare)];
        [tapture setDelegate:self];
        [webView addGestureRecognizer:tapture];
        [webView setUserInteractionEnabled:YES];
        
        self.testure_web  = tapture;
        
        
    }
    
    else{
    
        if (self.testure_web) {
            
            [webView removeGestureRecognizer:self.testure_web];
        }
    
    }

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
    
}

//必须实现

//-(void)OnclikeWeb:(UITapGestureRecognizer *)tap
//
//{
//    
//    [self Hidekey:nil];
//    
//    
//    
//}

-(void)removeCustomShare{


    [UIView animateWithDuration:0.5 animations:^{
        
        [webView setAlpha:1];
        
        self.rect_web = self.CVIew.frame;
        
        [self.CVIew setCenter:CGPointMake(1000, 1000)];
        
        self.CVIew = nil;
        
        [self.CVIew removeFromSuperview];
    }];

}

/**
 *  弹出提示
 */
-(void)showView{

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,100 , 30)];
    
    [view setBackgroundColor:[UIColor lightGrayColor]];
    
    // [view setCenter:CGPointMake(self.view.center.x, self.view.center.y-100)];
    
    [view setCenter:self.view.center];
    
    UILabel *lal_text =  [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    
    [lal_text setText:@"分享成功"];
    
    //[lal_text setCenter: self.view.center];
    
    [lal_text setTextColor:[UIColor whiteColor]];
    
    [lal_text setTextAlignment:NSTextAlignmentCenter];
    
    [view addSubview:lal_text];
    
    [self.view addSubview:view];
    
    [UIView animateWithDuration:2.0 animations:^{
        
        [view setAlpha:0.3];
        
    } completion:^(BOOL finished) {
        
        [view removeFromSuperview];
    }];
   

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
