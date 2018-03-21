//
//  DCPayWebViewController.m
//  Charging
//
//  Created by xpg on 15/2/3.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPayWebViewController.h"
#import "PayApiClient.h"

@interface DCPayWebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSURLRequest *payUrlRequest;
@property (strong, nonatomic) MBProgressHUD *webLoadingHud;
@end

@implementation DCPayWebViewController

+ (instancetype)storyboardInstantiate {
    UIStoryboard *payStoryboard = [UIStoryboard storyboardWithName:@"Pay" bundle:nil];
    return [payStoryboard instantiateViewControllerWithIdentifier:@"DCPayWebViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView.delegate = self;
    [self requestPayUrl];
    
    //新的支付方式
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.alipayUrl]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)navigateBack:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Request
- (void)requestPayUrl {
    self.webLoadingHud = [self showHUDIndicator];
    self.webLoadingHud.labelText = @"加载中...";
    
    [[PayApiClient sharedClient] postPayment:self.payment success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"postPayment responseObject %@", responseObject);
        NSString *url = responseObject[@"url"];
        if (url) {
            self.payUrlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [self.webView loadRequest:self.payUrlRequest];
            
            [self.webLoadingHud hide:YES];
        }
        else {
            // TODO: get code map from Alipay
            NSNumber *code = responseObject[@"code"];
            if ([code longValue] == 19) { //(code = 19; message = "the trade no has existed";)
                [self hideHUD:self.webLoadingHud withText:@"交易已存在, 3秒后返回"];
            }
            else {
                [self hideHUD:self.webLoadingHud withText:@"获取支付连接失败, 3秒后返回"];
            }
            [self performSelector:@selector(navigateBack:) withObject:nil afterDelay:3];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self hideHUD:self.webLoadingHud withText:@"加载失败, 3秒后返回"];
        [self performSelector:@selector(navigateBack:) withObject:nil afterDelay:3];
        DDLogDebug(@"postPayment error %@", error);
    }];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    DDLogDebug(@"webView %@", request.URL);
    NSURL *url = request.URL;
    if ([url.host isEqualToString:@"www.example.com"]) {//回调url
        MBProgressHUD *hud = [self showHUDIndicator];
        hud.mode = MBProgressHUDModeText;
        NSString *query = url.query;
        NSArray *params = [query componentsSeparatedByString:@"&"];
        for (NSString *param in params) {
            if ([param isEqualToString:@"result=success"]) {
                hud.labelText = @"支付成功";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ORDER_UPDATE object:nil];
                    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                });
                return NO;
            }
        }
        hud.labelText = @"支付失败";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        });
        return NO;
    }
    return YES;
}

@end
