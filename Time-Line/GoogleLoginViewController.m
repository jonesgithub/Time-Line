//
//  GoogleLoginViewController.m
//  Time-Line
//
//  Created by IF on 14-9-26.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "GoogleLoginViewController.h"
#import "GoogleCalendarData.h"
#import "CalendarListViewController.h"
#import "AppDelegate.h"
#import "LocalCalendarData.h"
#import "AT_Account.h"
@interface GoogleLoginViewController ()<UIWebViewDelegate,ASIHTTPRequestDelegate>


@property (nonatomic,strong) NSMutableDictionary *oauthDic;
@property (nonatomic,assign) BOOL isRegister;
@property (nonatomic,assign) BOOL isShowCalendarList;
@property (nonatomic,assign) BOOL isLocalClandarList;
@property (nonatomic,strong) NSMutableArray *googleCalendar;
@property (nonatomic,strong) NSMutableArray *accountArr;
@property (nonatomic,strong) UIActivityIndicatorView* activityIndicatorView;
@end

@implementation GoogleLoginViewController
@synthesize oauthDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = blueColor;
    self.googleCalendar=[[NSMutableArray alloc] initWithCapacity:0];
    
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:titleView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titlelabel];
    self.navigationItem.titleView =titleView;
    _activityIndicatorView = [ [ UIActivityIndicatorView  alloc ] initWithFrame:CGRectMake(192.0,13.0,20,20.0)];
    _activityIndicatorView.hidesWhenStopped=NO;
    _activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
    [titleView addSubview:_activityIndicatorView];
    if (self.isBind) {
        if (self.isSeting) {
            if (self.isSync) {
                titlelabel.text = @"Sync with Google";
                UIButton *rightBtn= [self createRightBtn:@" SKIP"];
                self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
            }else{
                titlelabel.text = @"Connect";
                UIButton *leftBtn=[self createLeftButton];
                self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:leftBtn];
            }
        }else{
         titlelabel.text = @"Sync with Google";
         UIButton *rightBtn= [self createRightBtn:@" SKIP"];
         self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        }
    }else {
        if(self.isLogin){
           titlelabel.text=@"Login with Google";
        }else{
            titlelabel.text=@"Sign up with Google";
        }
        UIButton *leftBtn=[self createLeftButton];
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    }
    self.googleLoginView.scalesPageToFit=YES;
    self.googleLoginView.delegate=self;
}


-(UIButton *)createLeftButton{
    UIButton *leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMake(0, 2, 21, 25)];
    [leftBtn addTarget:self action:@selector(dimssGoogleView:) forControlEvents:UIControlEventTouchUpInside];
    return leftBtn;
}

-(UIButton *)createRightBtn:(NSString *) title{
    UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:title forState:UIControlStateNormal];
    [rightBtn setFrame:CGRectMake(290, 4, 60, 20)];
    [rightBtn addTarget:self action:@selector(bindGoogleAccountSkip:) forControlEvents:UIControlEventTouchUpInside];
    return rightBtn;
}




-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.accountArr=[[NSMutableArray alloc] initWithCapacity:0];
    [ _activityIndicatorView startAnimating ];//启动活动图标
    [self loadWebPageWithString:Google_OAuth_URL];
}


-(void)loadWebPageWithString:(NSString *) uilString
{
    NSLog(@"%@",uilString);
    NSURL *url=[NSURL URLWithString:uilString];
        NSArray *cookieArr=[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:uilString]];
        NSHTTPCookie *cookie;
        for (id cook in cookieArr) {
            if ([cook isKindOfClass:[NSHTTPCookie class]]) {
                cookie=(NSHTTPCookie *)cook;
                NSLog(@"%@=====%@",cookie.name,cookie.value);
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
    [self.googleLoginView loadRequest:[NSURLRequest requestWithURL:url]];

}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
   
    if (UIWebViewNavigationTypeFormSubmitted==navigationType) {
        NSString *callback_Url=[[request URL] absoluteString];
         NSLog(@"%@=====%d",[[request URL] absoluteString],navigationType);
         [_activityIndicatorView setHidden:NO];
         [ _activityIndicatorView startAnimating ];
        if ([callback_Url hasPrefix:Google_Oauth2Callback_Url]) {
            NSRange rangeStr=[callback_Url rangeOfString:@"error"];//error=access_denied
            if (rangeStr.location==NSNotFound) {
                
                ASIHTTPRequest *googleRequest= [t_Network httpGet:nil Url:callback_Url Delegate:self Tag:1000];
                [googleRequest startSynchronous];
                return NO;
            }else{
                [self.googleLoginView reload];
            }
        }
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
   [ _activityIndicatorView stopAnimating ];//停止活动图标
    [_activityIndicatorView setHidden:YES];
}

-(void)bindGoogleAccountSkip:(UIButton *)sender
{
    [[AppDelegate getAppDelegate] initMainView];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)requestFinished:(ASIHTTPRequest *)request{
    
    NSString *responseStr=[request responseString];
    NSUserDefaults *userInfo=[NSUserDefaults standardUserDefaults];
    NSLog(@"%@",responseStr);
    switch (request.tag) {
        case 1000:{
            id tmpObj=[responseStr objectFromJSONString];
            if ([tmpObj isKindOfClass:[NSDictionary class]]) {
                    oauthDic=(NSMutableDictionary *)tmpObj  ;
                    if (self.isBind) {//本地账号绑定google账号
                        NSMutableDictionary *paramDic=[NSMutableDictionary dictionaryWithCapacity:0];
                        [paramDic setObject:[oauthDic objectForKey:@"email"] forKey:@"bindAccout"];
                        [paramDic setObject:[oauthDic objectForKey:@"token"] forKey:@"token"];
                        [paramDic setObject:@"refreshToken" forKey:@"refreshToken"];
                        [paramDic setObject:[oauthDic objectForKey:@"tokenTime"] forKey:@"tokenTime"];
                        
                        ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:Google_AccountBind Delegate:self Tag:Google_AccountBind_Tag];
                        [request startAsynchronous];
                    }else{
                        if (oauthDic) {
                            NSMutableDictionary *paramDic=[NSMutableDictionary dictionaryWithCapacity:0];
                            if (!self.isLogin) {
                                [paramDic setObject:[oauthDic objectForKey:@"email"] forKey:@"email"];
                                [paramDic setObject:[oauthDic objectForKey:@"uName"] forKey:@"uName"];
                                [paramDic setObject:[oauthDic objectForKey:@"authCode"] forKey:@"authCode"];
                                [paramDic setObject:[oauthDic objectForKey:@"token"] forKey:@"token"];
                                [paramDic setObject:@"refreshToken" forKey:@"refreshToken"];
                                [paramDic setObject:[oauthDic objectForKey:@"tokenTime"] forKey:@"tokenTime"];
                                [paramDic setObject:@(UserLoginTypeGoogle) forKey:@"type"];
                                ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:LOGIN_REGISTER_URL Delegate:self Tag:LOGIN_REGISTER_URL_TAG userInfo:oauthDic];
                                [request startAsynchronous];
                                self.isRegister=YES;
                            }else{//用google账号直接登陆不用注册
                                [paramDic setObject:[oauthDic objectForKey:@"email"] forKey:@"email"];
                                [paramDic setObject:[oauthDic objectForKey:@"authCode"] forKey:@"authCode"];
                                [paramDic setObject:@(UserLoginTypeGoogle) forKey:@"type"];
                                ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:LOGIN_USER Delegate:self Tag:LOGIN_USER_TAG userInfo:oauthDic];
                                [request startAsynchronous];
                        }
                    }
                }
                
            }
          break;
        }
        case Google_AccountBind_Tag:{
            id tmpObj=[responseStr objectFromJSONString];
            if ([tmpObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic=(NSMutableDictionary *)tmpObj;
                NSString *param= dic[@"statusCode"];
                if ([@"-3" isEqualToString:param]) {
                    [ShowHUD showTextOnly:@"This email has been registered or binding" configParameter:^(ShowHUD *config) {
                        config.animationStyle=MBProgressHUDAnimationZoomOut;
                        config.margin          = 20.f;    // 边缘留白
                        config.opacity         = 0.7f;    // 设定透明度
                        config.cornerRadius    = 10.f;     // 设定圆角
                        config.textFont        = [UIFont systemFontOfSize:14.f];
                    } duration:3 inView:self.view];
                    [self.googleLoginView reload];
                }
            }
            
            break;
        }
        default:
            break;
    }
    if (request.tag==1000) {
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView setHidden:YES];
        return;
    }
    
    if (self.isBind) {//暂时就这样处理，后续优化！哎..!太烂了
      if (responseStr) {
          NSMutableDictionary *googleDataDic=[responseStr objectFromJSONString];
          if ([googleDataDic isKindOfClass:[NSDictionary class]]) {
              NSString *statusCode=[googleDataDic objectForKey:@"statusCode"];
              if (!self.isShowCalendarList) {
                   if ([@"1" isEqualToString:statusCode]) {//绑定成功
                          ASIHTTPRequest *request=[t_Network httpGet:nil Url:Get_Google_GetCalendarList Delegate:self Tag:Get_Google_GetCalendarList_Tag];
                          [request startAsynchronous];
                          self.isShowCalendarList=YES;
                          return;
                  }
              }
              if (self.isShowCalendarList){
                  if (!self.isLocalClandarList) { //取得google日历列表
                      NSArray *arr=[googleDataDic objectForKey:@"items"];
                      
                      NSMutableArray *tmpArr=[NSMutableArray arrayWithCapacity:0];
                      
                      AT_Account *ac=[AT_Account MR_createEntity];
                      
                      [self.accountArr addObject:ac];
                      for (NSDictionary *dic in arr) {
                          NSLog(@"%@",dic);
                          GoogleCalendarData *gcd=[[GoogleCalendarData alloc] init];
                          [gcd parseDictionary:dic];
                          if ([dic objectForKey:@"primary"]) {
                              gcd.isPrimary=YES;
                              ac.account=[dic objectForKey:@"summary"];
                              ac.accountType=@(AccountTypeGoogle);
                          }
                          [gcd setAccount:ac.account];
                          [tmpArr addObject:gcd];
                      }
                      [self.googleCalendar addObject:tmpArr];
                      
                      if (!self.isSeting) {//这里如果是设置页面传来的就不取得本地日历
                          ASIHTTPRequest *request=[t_Network httpGet:nil Url:Local_CalendarOperation Delegate:self Tag:Local_CalendarOperation_Tag];
                          [request startAsynchronous];
                          self.isLocalClandarList=YES;
                       }else{
                           [self.delegate setGoogleCalendarListData:self.googleCalendar];
                           CalendarListViewController *ca=[[CalendarListViewController alloc] init];
                           ca.googleCalendarDataArr=self.googleCalendar;
                           ca.calendarAccountArr=self.accountArr;
                           [self.navigationController pushViewController:ca animated:YES];
                       }
                  }
                  if (self.isLocalClandarList) {
                      NSMutableDictionary *localDataDic=[responseStr objectFromJSONString];
                      NSString *statusCode=[localDataDic objectForKey:@"statusCode"];
                      if ([@"1" isEqualToString:statusCode]) {//成功取得本地日历列表
                         GoogleCalendarData *gcd= [[self.googleCalendar objectAtIndex:0] objectAtIndex:0];
                          NSArray *arr=[localDataDic objectForKey:@"data"];
                          
                          AT_Account *ac=[AT_Account MR_createEntity];
                          ac.account=gcd.account;
                          ac.accountType=@(AccountTypeLocal);

                          [userInfo setValue:@(AccountTypeGoogle) forKey:@"accountType"];
                          [userInfo setValue:gcd.account forKey:@"email"];
                          [userInfo setValue:gcd.account forKey:@"userName"];
                          [userInfo setValue:@(UserLoginStatus_YES) forKey:@"loginStatus"];
                          
                          [self.accountArr addObject:ac];
                          NSMutableArray *localArr=[NSMutableArray arrayWithCapacity:0];
                          for (NSDictionary *dic in arr) {
                              NSLog(@"%@",dic);
                              LocalCalendarData *ld=[[LocalCalendarData alloc] init];
                              [ld parseDictionary:dic];
                              [ld setEmailAccount:ac.account];//用google账号登陆默认本地账号就是google账号
                              [localArr addObject:ld];
                          }
                          [self.googleCalendar addObject:localArr];
                          [self.delegate setGoogleCalendarListData:self.googleCalendar];
                          CalendarListViewController *ca=[[CalendarListViewController alloc] init];
                          ca.googleCalendarDataArr=self.googleCalendar;
                          ca.calendarAccountArr=self.accountArr;
                          [self.navigationController pushViewController:ca animated:YES];
                      }
                  }
               }
          }
        }
    }else{
            oauthDic= [request.userInfo mutableCopy];//[[responseStr objectFromJSONString] mutableCopy]  ;
            if (!self.isLogin) {
                if (!self.isRegister) {
                    if (responseStr) {
                        self.oauthDic=nil;
                        if (oauthDic) {
                            NSMutableDictionary *paramDic=[NSMutableDictionary dictionaryWithCapacity:0];
                            [paramDic setObject:[oauthDic objectForKey:@"email"] forKey:@"email"];
                            [paramDic setObject:[oauthDic objectForKey:@"uName"] forKey:@"uName"];
                            [paramDic setObject:[oauthDic objectForKey:@"authCode"] forKey:@"authCode"];
                            [paramDic setObject:[oauthDic objectForKey:@"token"] forKey:@"token"];
                            [paramDic setObject:@"refreshToken" forKey:@"refreshToken"];
                            [paramDic setObject:[oauthDic objectForKey:@"tokenTime"] forKey:@"tokenTime"];
                            [paramDic setObject:@(UserLoginTypeGoogle) forKey:@"type"];
                            ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:LOGIN_REGISTER_URL Delegate:self Tag:LOGIN_REGISTER_URL_TAG];
                            [request startAsynchronous];
                            self.isRegister=YES;

                        }
                     }
                 }
                if ([@"-1" isEqualToString:responseStr]||[@"1" isEqualToString:responseStr]) {
                    NSMutableDictionary *paramDic=[NSMutableDictionary dictionaryWithCapacity:0];
                    [paramDic setObject:[oauthDic objectForKey:@"email"] forKey:@"email"];
                    [paramDic setObject:[oauthDic objectForKey:@"authCode"] forKey:@"authCode"];
                    [paramDic setObject:@(UserLoginTypeGoogle) forKey:@"type"];
                    ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:LOGIN_USER Delegate:self Tag:LOGIN_USER_TAG];
                    [request startAsynchronous];
                    self.isLogin=YES;
                }
            }else{
                
                if (!self.isShowCalendarList) {
                     if ([@"1" isEqualToString:responseStr]) {
                         ASIHTTPRequest *request=[t_Network httpGet:nil Url:Get_Google_GetCalendarList Delegate:self Tag:Get_Google_GetCalendarList_Tag];
                         [request startAsynchronous];
                         [userInfo setValue:[oauthDic objectForKey:@"authCode"] forKey:@"authCode"];
                         self.isShowCalendarList=YES;
                     }
                }else{
                    if (!self.isLocalClandarList) {//取得google日历集合
                        NSMutableDictionary *googleDataDic=[responseStr objectFromJSONString];
                        NSDictionary  *dataDic=[googleDataDic objectForKey:@"data"];
                        if ([dataDic isKindOfClass:[NSDictionary class]]) {
                            NSArray *arr=[dataDic objectForKey:@"items"];
                            NSMutableArray *googleArr=[NSMutableArray arrayWithCapacity:0];
                            
                            AT_Account *ac=[AT_Account MR_createEntity];
                            
                            [self.accountArr addObject:ac];
                            
                            for (NSDictionary *dic in arr) {
                                NSLog(@"%@",dic);
                                GoogleCalendarData *gcd=[[GoogleCalendarData alloc] init];
                                [gcd parseDictionary:dic];
                                if ([dic objectForKey:@"primary"]) {
                                    gcd.isPrimary=YES;
                                    ac.account=[dic objectForKey:@"summary"];
                                    ac.accountType=@(AccountTypeGoogle);
                                }
                                [gcd setAccount:ac.account];
                                [googleArr addObject:gcd];
                            }
                            
                            [self.googleCalendar addObject:googleArr];
                            ASIHTTPRequest *request=[t_Network httpGet:nil Url:Local_CalendarOperation Delegate:self Tag:Local_CalendarOperation_Tag];
                            [request startAsynchronous];
                            self.isLocalClandarList=YES;

                        }
                        
                    }else{
                        NSMutableDictionary *localDataDic=[responseStr objectFromJSONString];
                        NSString *statusCode=[localDataDic objectForKey:@"statusCode"];
                        if ([@"1" isEqualToString:statusCode]) {//成功取得本地日历列表
                            GoogleCalendarData *gcd= [[self.googleCalendar objectAtIndex:0] objectAtIndex:0];
                            
                            AT_Account *ac=[AT_Account MR_createEntity];
                            ac.account=gcd.account;
                            ac.accountType=@(AccountTypeLocal);
                            
                            [userInfo setValue:gcd.account forKey:@"email"];
                            [userInfo setValue:gcd.account forKey:@"userName"];
                            [userInfo setValue:@(UserLoginStatus_YES) forKey:@"loginStatus"];
                            [userInfo setValue:@(AccountTypeGoogle) forKey:@"accountType"];
                            
                            [self.accountArr addObject:ac];
                            
                            NSArray *arr=[localDataDic objectForKey:@"data"];
                            NSMutableArray *localArr=[NSMutableArray arrayWithCapacity:0];
                            
                            for (NSDictionary *dic in arr) {
                                NSLog(@"%@",dic);
                                LocalCalendarData *ld=[[LocalCalendarData alloc] init];
                                [ld parseDictionary:dic];
                                [ld setEmailAccount:ac.account];
                                [ld setIsLocalAccount:YES];
                                [localArr addObject:ld];
                            }
                            [self.googleCalendar addObject:localArr];
                            
                            [self.delegate setGoogleCalendarListData:self.googleCalendar];
                            CalendarListViewController *ca=[[CalendarListViewController alloc] init];
                            ca.googleCalendarDataArr=self.googleCalendar;
                            ca.calendarAccountArr=self.accountArr;
                            [self.navigationController pushViewController:ca animated:YES];
                        }
                    }
            }
        }
    }
    [userInfo synchronize];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dimssGoogleView:(UIButton *) sender
{
    if (!self.isSeting) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES ];

}

@end
