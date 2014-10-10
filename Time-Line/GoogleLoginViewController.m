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
@interface GoogleLoginViewController ()<UIWebViewDelegate,ASIHTTPRequestDelegate>


@property (nonatomic,strong) NSMutableDictionary *oauthDic;
@property (nonatomic,assign) BOOL isRegister;
@property (nonatomic,assign) BOOL isShowCalendarList;
@property (nonatomic,assign) BOOL isLocalClandarList;
@property (nonatomic,strong) NSMutableArray *googleCalendar;

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
    if (self.isBind) {
        self.navigationItem.title=@"Sync with Google";
        UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitle:@"SKIP" forState:UIControlStateNormal];
        [rightBtn setFrame:CGRectMake(260, 2, 60, 20)];
        [rightBtn addTarget:self action:@selector(bindGoogleAccountSkip:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        
    }else {
        
        if(self.isLogin){
            self.navigationItem.title=@"Login with Google";
        }else{
            self.navigationItem.title=@"Sign up with Google";
        }
        UIButton *leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
        [leftBtn setFrame:CGRectMake(0, 2, 20, 20)];
        [leftBtn addTarget:self action:@selector(dimssGoogleView:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    }
    self.googleLoginView.scalesPageToFit=YES;
    self.googleLoginView.delegate=self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    if (self.isLogin) {
        
         [self loadWebPageWithString:Google_OAuth_URL];
    }else{
        [self loadWebPageWithString:Google_OAuth_URL];
    }
}


-(void)loadWebPageWithString:(NSString *) uilString
{
    NSLog(@"%@",uilString);
    NSURL *url=[NSURL URLWithString:uilString];
 //   if (!self.isLogin) {
        NSArray *cookieArr=[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:uilString]];
        NSHTTPCookie *cookie;
        for (id cook in cookieArr) {
            if ([cook isKindOfClass:[NSHTTPCookie class]]) {
                cookie=(NSHTTPCookie *)cook;
                NSLog(@"%@=====%@",cookie.name,cookie.value);
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
  //  }
    [self.googleLoginView loadRequest:[NSURLRequest requestWithURL:url]];

}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
   
    if (UIWebViewNavigationTypeFormSubmitted==navigationType) {
        NSString *callback_Url=[[request URL] absoluteString];
         NSLog(@"%@=====%d",[[request URL] absoluteString],navigationType);
        
        if ([callback_Url hasPrefix:Google_Oauth2Callback_Url]) {
            NSRange rangeStr=[callback_Url rangeOfString:@"error"];//error=access_denied
            if (rangeStr.location==NSNotFound) {
                 self.googleLoginView.hidden=YES;
            }else{
                [self.googleLoginView reload];
            }
        }
    }
    return YES;
}


-(void)bindGoogleAccountSkip:(UIButton *)sender
{
    [[AppDelegate getAppDelegate] initMainView];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *content=[self.googleLoginView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText"];
    if(content){
        id tmpObj=[content objectFromJSONString];
        if ([tmpObj isKindOfClass:[NSDictionary class]]) {
            oauthDic=[[content objectFromJSONString] mutableCopy]  ;
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
                    if (!self.isLogin) {//用google账号直接登陆不用注册
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
                    }else{
                        [paramDic setObject:[oauthDic objectForKey:@"email"] forKey:@"email"];
                        [paramDic setObject:[oauthDic objectForKey:@"authCode"] forKey:@"authCode"];
                        [paramDic setObject:@(UserLoginTypeGoogle) forKey:@"type"];
                        ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:LOGIN_USER Delegate:self Tag:LOGIN_USER_TAG];
                        [request startAsynchronous];
                    }
                }
            }

        }
    }
}


- (void)requestFinished:(ASIHTTPRequest *)request{
    
    NSString *responseStr=[request responseString];
    NSLog(@"%@",responseStr);
    if (self.isBind) {
      if (responseStr) {
          NSMutableDictionary *googleDataDic=[responseStr objectFromJSONString];
          if ([googleDataDic isKindOfClass:[NSDictionary class]]) {
              NSString *statusCode=[googleDataDic objectForKey:@"statusCode"];
              if ([@"1" isEqualToString:statusCode]) {//绑定成功
                  if (!self.isShowCalendarList) {
                          ASIHTTPRequest *request=[t_Network httpGet:nil Url:Get_Google_GetCalendarList Delegate:self Tag:Get_Google_GetCalendarList_Tag];
                          [request startAsynchronous];
                          self.isShowCalendarList=YES;
                          return;
                  }
              }
              if (self.isShowCalendarList){
                  if (!self.isLocalClandarList) { //与下面重复！需优化
                      NSArray *arr=[googleDataDic objectForKey:@"items"];
                      NSMutableArray *tmpArr=[NSMutableArray arrayWithCapacity:0];
                      for (NSDictionary *dic in arr) {
                          NSLog(@"%@",dic)
                          GoogleCalendarData *gcd=[[GoogleCalendarData alloc] init];
                          [gcd parseDictionary:dic];
                          [tmpArr addObject:gcd];
                      }
                      [self.googleCalendar addObject:tmpArr];
                      
                      ASIHTTPRequest *request=[t_Network httpGet:nil Url:Local_CalendarOperation Delegate:self Tag:Local_CalendarOperation_Tag];
                      [request startAsynchronous];
                      self.isLocalClandarList=YES;
                  }else{
                      NSMutableDictionary *localDataDic=[responseStr objectFromJSONString];
                      NSString *statusCode=[localDataDic objectForKey:@"statusCode"];
                      if ([@"1" isEqualToString:statusCode]) {//成功取得本地日历列表
                          
                          NSArray *arr=[localDataDic objectForKey:@"data"];
                          NSMutableArray *localArr=[NSMutableArray arrayWithCapacity:0];
                          for (NSDictionary *dic in arr) {
                              NSLog(@"%@",dic)
                              LocalCalendarData *ld=[[LocalCalendarData alloc] init];
                              [ld parseDictionary:dic];
                              [localArr addObject:ld];
                          }
                          [self.googleCalendar addObject:localArr];
                          
                          [self.delegate setGoogleCalendarListData:self.googleCalendar];
                          CalendarListViewController *ca=[[CalendarListViewController alloc] init];
                          ca.googleCalendarDataArr=self.googleCalendar;
                          [self.navigationController pushViewController:ca animated:YES];
                      }
                  }
               }
          }
        }
    }else{
            if (!self.isLogin) {
                if (!self.isRegister) {
                    if (responseStr) {
                        self.oauthDic=nil;
                        oauthDic=[[responseStr objectFromJSONString] mutableCopy]  ;
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
                         self.isShowCalendarList=YES;
                         return;
                     }
                }else{
                    if (!self.isLocalClandarList) {//取得本地日历集合
                        NSMutableDictionary *googleDataDic=[responseStr objectFromJSONString];
                        NSArray *arr=[googleDataDic objectForKey:@"items"];
                        NSMutableArray *googleArr=[NSMutableArray arrayWithCapacity:0];
                        for (NSDictionary *dic in arr) {
                            NSLog(@"%@",dic)
                            GoogleCalendarData *gcd=[[GoogleCalendarData alloc] init];
                            [gcd parseDictionary:dic];
                            [googleArr addObject:gcd];
                        }
                        [self.googleCalendar addObject:googleArr];
                        ASIHTTPRequest *request=[t_Network httpGet:nil Url:Local_CalendarOperation Delegate:self Tag:Local_CalendarOperation_Tag];
                        [request startAsynchronous];
                        self.isLocalClandarList=YES;
                    }else{
                        NSMutableDictionary *localDataDic=[responseStr objectFromJSONString];
                        NSString *statusCode=[localDataDic objectForKey:@"statusCode"];
                        if ([@"1" isEqualToString:statusCode]) {//成功取得本地日历列表
                            
                            NSArray *arr=[localDataDic objectForKey:@"data"];
                            NSMutableArray *localArr=[NSMutableArray arrayWithCapacity:0];
                            for (NSDictionary *dic in arr) {
                                NSLog(@"%@",dic)
                                LocalCalendarData *ld=[[LocalCalendarData alloc] init];
                                [ld parseDictionary:dic];
                                [localArr addObject:ld];
                            }
                            [self.googleCalendar addObject:localArr];
                            
                            [self.delegate setGoogleCalendarListData:self.googleCalendar];
                            CalendarListViewController *ca=[[CalendarListViewController alloc] init];
                            ca.googleCalendarDataArr=self.googleCalendar;
                            [self.navigationController pushViewController:ca animated:YES];
                        }
                    }
            }
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dimssGoogleView:(UIButton *) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end