//
//  HSSYDynamicDetailsViewController.m
//  Charging
//
//  Created by xpg on 15/9/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDynamicDetailsViewController.h"
#import "DCPreloadingView.h"

@interface DCDynamicDetailsViewController (){
}
@property (nonatomic, retain) DCPreloadingView* preloadView;

@end

@implementation DCDynamicDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"资讯详情";
    
    [self webViewLoadRequest];
}

- (void)webViewLoadRequest {
    NSLog(@"~~~~~~~~~~~~~~: %@", self.url);
    NSString *string = nil;
    if (self.soucrceType == 1) {
        string = [[SERVER_URL stringByAppendingString:@"open/information/"] stringByAppendingString:self.url];
    } else {
        string = self.url;
    }
    NSLog(@"ImageViewURl~~~~~~~~~~~~~~~~~~: %@", string);
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:string]];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - webview代理方法
- (void)webViewDidStartLoad:(UIWebView *)webView { //网页开始加载的时候调用
    
    [self.preloadView removeFromSuperview]; //先remove是确保只创建一个对象，防止多次被addsubview;
    [self.preloadView setReloadBlock:nil];
    self.preloadView = nil;
    
    self.preloadView = [DCPreloadingView loadViewWithNib:@"DCPreloadingView"];
    NSDictionary *paramDic = NSDictionaryOfVariableBindings(_preloadView);
    [self.preloadView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.preloadView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_preloadView]|" options:0 metrics:0 views:paramDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_preloadView]|" options:0 metrics:0 views:paramDic]];
    [self.preloadView setMode:PreLoadViewModeLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView { // 网页加载完成的时候调用
    [self.preloadView removeFromSuperview];
    [self.preloadView setReloadBlock:nil];
    self.preloadView = nil;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error { //网页加载错误的时候调用
    [self.preloadView setMode:PreLoadViewModeLoadFailed];
    
    typeof(self) __weak weakSelf = self;
    [self.preloadView setReloadBlock:^{
        [weakSelf webViewLoadRequest];
    } ];
}

@end
