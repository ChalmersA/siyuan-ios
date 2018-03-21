//
//  DCBindAccountViewController.m
//  Charging
//
//  Created by kufufu on 15/9/29.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCBindAccountViewController.h"
#import "DCSiteApi.h"
#import "DCApp.h"
#import "DCUser.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface DCBindAccountViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *weiXinButton;
@property (weak, nonatomic) IBOutlet UIButton *qqButton;

@property (strong, nonatomic) NSURLSessionDataTask *bindThirdpartyTask;
@property (strong, nonatomic) NSURLSessionDataTask *unbindThirdpartyTask;

@property (strong, nonatomic) DCUser *user;

@end

@implementation DCBindAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.weiXinButton.backgroundColor = [UIColor paletteDCMainColor];
    self.weiXinButton.adjustsImageWhenHighlighted = NO;
    self.qqButton.backgroundColor = [UIColor paletteDCMainColor];
    self.qqButton.adjustsImageWhenHighlighted = NO;
    self.user = [DCApp sharedApp].user;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickToBindWeChatId:(id)sender {
    if (self.user.bindType == DCBindTypeWeChat) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"您已经绑定了微信账号";
        [hud hide:YES afterDelay:3];
    }else if (self.user.bindType == DCBindTypeQQ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已经绑定了QQ账号，如需绑定微信账号，请点击解绑按钮，然后再重新绑定" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"解绑", nil];
        alertView.tag = 1;
        alertView.delegate = self;
        [alertView show];
    }else if ([self isBindThirdpartyLogin] == 0) {
        SSDKPlatformType type = SSDKPlatformTypeWechat;
        [self goToThirdpartyLogin:type];
    }
}
- (IBAction)clickToBindQQId:(id)sender {
    if (self.user.bindType == DCBindTypeQQ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"您已经绑定了QQ账号";
        [hud hide:YES afterDelay:3];
    }else if (self.user.bindType == DCBindTypeWeChat) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已经绑定了微信账号，如需绑定微信账号，请点击解绑按钮，然后再重新绑定" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"解绑", nil];
        alertView.tag = 2;
        alertView.delegate = self;
        [alertView show];
    }else if ([self isBindThirdpartyLogin] == 0) {
        SSDKPlatformType type = SSDKPlatformTypeQQ;
        [self goToThirdpartyLogin:type];
    }
}

#pragma mark UIAlertView代理方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DCUser *user = [DCApp sharedApp].user;
    NSString *bindType = [NSString stringWithFormat:@"%ld", (long)user.bindType];
    switch (alertView.tag) {
        case 1: {
            if (buttonIndex == 1) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                self.unbindThirdpartyTask = [DCSiteApi postUnbindUserId:user.userId thirdAccType:bindType completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                    if ([webResponse isSuccess]) {
                        [ShareSDK cancelAuthorize:SSDKPlatformTypeQQ];
                        user.bindType = 0;
                        [DCApp sharedApp].user = user;
                        hud.mode = MBProgressHUDModeText;
                        hud.labelText = @"解绑成功";
                        [hud hide:YES afterDelay:3];
                    }else {
                        hud.mode = MBProgressHUDModeText;
                        hud.labelText = @"解绑不成功，请重新尝试";
                        [hud hide:YES afterDelay:3];
                    }
                }];
            }
        }
            break;
        case 2: {
            if (buttonIndex == 1) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                self.unbindThirdpartyTask = [DCSiteApi postUnbindUserId:user.userId thirdAccType:bindType completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                    if ([webResponse isSuccess]) {
                        [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
                        user.bindType = 0;
                        [DCApp sharedApp].user = user;
                        hud.mode = MBProgressHUDModeText;
                        hud.labelText = @"解绑成功";
                        [hud hide:YES afterDelay:3];
                    }else {
                        hud.mode = MBProgressHUDModeText;
                        hud.labelText = @"解绑不成功，请重新尝试";
                        [hud hide:YES afterDelay:3];
                    }
                }];
            }
        }
            break;
        default:
            break;
    }
}

-(NSInteger)isBindThirdpartyLogin
{
    DCUser *user = [DCApp sharedApp].user;
    if (user.bindType  == DCBindTypeWeChat || user.bindType == DCBindTypeQQ) {
        return user.bindType;
    }
    else return 0;
}

-(void)goToThirdpartyLogin:(SSDKPlatformType)shareType
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    DCUser *userAPP = [DCApp sharedApp].user;
    
    [ShareSDK getUserInfo:shareType onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateFail) {
            [self showHUDText:@"授权失败，请重试"];
            return;
        }
        
        if (state == SSDKResponseStateCancel) {
            [self showHUDText:@"取消授权"];
            return;
        }
        
        
        NSString *thirdUid = user.uid;
        NSString *thirdAccToken = user.credential.token;
        if (shareType == SSDKPlatformTypeWechat) {  //微信
            self.bindThirdpartyTask = [DCSiteApi postBindUserId:userAPP.userId thirdAccUid:thirdUid thirdAccToken:thirdAccToken thirdAccType:@"3" completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if ([webResponse.message isEqualToString:@"成功"]) {
                    userAPP.bindType = DCBindTypeWeChat;
                    [DCApp sharedApp].user = userAPP;
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"绑定成功";
                    [hud hide:YES afterDelay:3];
                }else {
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"绑定不成功";
                    [hud hide:YES afterDelay:3];
                }
            }];
        }else {  //QQ
            self.bindThirdpartyTask = [DCSiteApi postBindUserId:userAPP.userId thirdAccUid:thirdUid thirdAccToken:thirdAccToken thirdAccType:@"4" completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if ([webResponse.message isEqualToString:@"成功"]) {
                    userAPP.bindType = DCBindTypeQQ;
                    [DCApp sharedApp].user = userAPP;
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"绑定成功";
                    [hud hide:YES afterDelay:3];
                }else {
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"绑定不成功";
                    [hud hide:YES afterDelay:3];
                }
            }];
        }
    }];
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
