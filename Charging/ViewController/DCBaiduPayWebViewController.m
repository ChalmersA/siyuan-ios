////
////  DCBaiduPayWebViewController.m
////  Charging
////
////  Created by Pp on 15/11/24.
////  Copyright © 2015年 xpg. All rights reserved.
////
//
//#import "DCBaiduPayWebViewController.h"
//#import "UIViewController+HSSYExtensions.h"
//#import "GlobalConstants.h"
//#import "DCSiteApi.h"
//#import "DCApp.h"
//
//@interface DCBaiduPayWebViewController ()<UIWebViewDelegate>
//
//@property (nonatomic, strong) UIWebView *web;
//@property (nonatomic, strong) MBProgressHUD *myHub;
//
//@end
//
//@implementation DCBaiduPayWebViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
//    
//    self.web = [[UIWebView alloc]init];
//    [self.view addSubview:self.web];
//    
//    self.web.translatesAutoresizingMaskIntoConstraints = NO;
//    NSArray *constraintA = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[web]-0-|" options:0 metrics:nil views:@{@"web":self.web}];
//    NSArray *constraintB = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[web]-0-|" options:0 metrics:nil views:@{@"web":self.web}];
//    [self.view addConstraints:constraintA];
//    [self.view addConstraints:constraintB];
//    
//    self.web.delegate = self;
//    
//    [self openUrl];
//    self.myHub = [self showHUDIndicator];
//}
//
//#pragma mark - 加载结束
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    [self.myHub hide:YES];
//}
//
//#pragma mark - 加载失败
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
//{
//    [self hideHUD:self.myHub withDetailsText:@"加载失败"];
//}
//
//#pragma mark - 每次加载之前都会调用
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    NSString *url = request.URL.absoluteString;
//    // 说明协议头是SERVER_URL
//    if ([url hasPrefix:SERVER_URL]) {
//        [self.navigationController popViewControllerAnimated:YES];
//        return NO;
//    }
//    return YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    NSString *uid = [DCApp sharedApp].user.userId;
//    [DCSiteApi getBaidubingWithUserId:uid completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//        if (![webResponse isSuccess]) {
//            return;
//        }
//        if ([(NSNumber*)webResponse.result boolValue]) {
//            [DCApp sharedApp].user.contractFlag = DCUserContractFlagYES;
//            [self.myDelegate baiduPayBingingSuccessBack];
//        }
//        else {
//            [DCApp sharedApp].user.contractFlag = DCUserContractFlagNO;
//            [self.myDelegate baiduPayBingingFailureBack];
//        }
//        [DCDefault saveLoginedUser:[DCApp sharedApp].user];
//    }];
//}
//
////
//- (void)openUrl
//{
//    NSURLRequest *url = [NSURLRequest requestWithURL:[NSURL URLWithString:self.baidupayUrl]];
//    [self.web loadRequest:url];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}
//
//@end
