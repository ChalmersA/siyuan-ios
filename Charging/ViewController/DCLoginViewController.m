//
//  DCLoginViewController.m
//  Charging
//
//  Created by Ben on 14/12/22.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCLoginViewController.h"
#import "DCSiteApi.h"
#import "DCHTTPSessionManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "JPUSHService.h"
#import "DCColorButton.h"
#import "DCPhoneNumViewController.h"
#import "DCChargingViewController.h"

const NSInteger DCErrorCodeAccountExist = 10002;//账户已存在
const NSInteger DCErrorCodeAccountNotExist = 10003;//账户不存在
const NSInteger DCErrorCodeAccountLocked = 10004;//账户已被锁定
const NSInteger DCErrorCodeAccountLoginLimit = 10005;//登录尝试失败次数过多

@interface DCLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextFeild;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFeild;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgetPwdButton;
@property (weak, nonatomic) IBOutlet UIButton *creatCountButton;
@property (weak, nonatomic) IBOutlet UIImageView *userNameBackgroupImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordBackgroupImageView;

@property (strong, nonatomic) NSURLSessionDataTask *loginTask;
@property (strong, nonatomic) NSURLSessionDataTask *thirdLoginTask;

@property (copy, nonatomic) NSString *thirdUid;
@property (copy, nonatomic) NSString *thirdAccToken;
@property (nonatomic) NSInteger thirdAccType;
@property (copy, nonatomic) NSString *thirdNickName;
@property (nonatomic) DCUserGender thirdGender;
@property (copy, nonatomic) NSString *thirdAvatarUrl;

-(IBAction)loginClick:(id)sender;
-(IBAction)forgetPwdClick:(id)sender;
-(IBAction)creatCountClick:(id)sender;
@end

@implementation DCLoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.userNameTextFeild addTarget:self action:@selector(textFeildDidchange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextFeild addTarget:self action:@selector(textFeildDidchange:) forControlEvents:UIControlEventEditingChanged];
    self.loginButton.backgroundColor = [UIColor paletteButtonRedColor];
    [self.loginButton setCornerRadius:4];
    [self.userNameBackgroupImageView setCornerRadius:4];
    [self.passwordBackgroupImageView setCornerRadius:4];
    
    // load last user's phone
    NSString* lastLoginedUserPhoneNum = [DCDefault loadLastLoginUserPhoneNum];
    if(lastLoginedUserPhoneNum) {
        [self.userNameTextFeild setText:lastLoginedUserPhoneNum];
    }
    self.loginButton.enabled = (self.userNameTextFeild.text.length > 0) && (self.passwordTextFeild.text.length > 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //TODO: post out the this message, login view is presenting: 1. for dismissing some child view in windows
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGINVIEW_WILL_SHOW object:nil userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"bindPhoneNumberVC"]) {
        DCPhoneNumViewController *vc = segue.destinationViewController;
        vc.thirdUid = self.thirdUid;
        vc.thirdAccToken = self.thirdAccToken;
        vc.thirdAccType = self.thirdAccType;
        vc.thirdNickName = self.thirdNickName;
        vc.thirdGender = self.thirdGender;
        vc.thirdAvatarUrl = self.thirdAvatarUrl;
        if ([sender isEqualToString:self.userNameTextFeild.text]) {
            vc.phoneNumber = self.userNameTextFeild.text;
        }
    } else if ([segue.identifier isEqualToString:@"phoneNumViewController"]) {
        DCPhoneNumViewController *vc = segue.destinationViewController;
        if ([sender isEqualToString:self.userNameTextFeild.text]) {
            vc.phoneNumber = self.userNameTextFeild.text;
        }
    }
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Action
- (IBAction)dismiss:(id)sender {
    [self.loginTask cancel];
    [self.view endEditing:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)pushIdForLogin {
    NSString *pushId = [JPUSHService registrationID];
    if (pushId.length == 0) {
        return @"";
    }
    NSLog(@"JPush_registrationID: %@", pushId);
    return pushId;
}

#pragma mark 登录
- (void)loginClick:(id)sender {
    [self.view endEditing:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.userNameTextFeild.text.length != 11) {
        [self hideHUD:hud withText:@"请输入正确的手机号"];
        return;
    }
    
    if (self.passwordTextFeild.text.length < 6) {
        [self hideHUD:hud withText:@"密码应该由6-16位字母或数字组成"];
        return;
    }
        hud.labelText = @"正在登录，请稍候";

    self.loginTask = [DCSiteApi postLoginWithAccount:self.userNameTextFeild.text
                                            password:self.passwordTextFeild.text
                                             accType:1
                                              pushId:[self pushIdForLogin]
                                          completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                                              if (![webResponse isSuccess]) {
                                                  if (webResponse.code == DCErrorCodeAccountNotExist) {// "message" : "账户不存在", "code" : 10003
                                                      [hud hide:YES];
                                                      UIAlertView *alert = [UIAlertView showAlertMessage:@"该手机号尚未注册，是否注册易卫充？" buttonTitles:@[@"取消", @"立即注册"]];
                                                      [alert setClickedButtonHandler:^(NSInteger buttonIndex) {
                                                          self.passwordTextFeild.text = nil;
                                                          if (buttonIndex == 1) {
                                                              [self performSegueWithIdentifier:@"phoneNumViewController" sender:self.userNameTextFeild.text];
                                                          }
                                                      }];
                                                  } else {
                                                      [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                                                  }
                                                  return;
                                              }
                                              
                                              DCUser *user = [[DCUser alloc] initWithLoginResponse:webResponse.result];
                                              [DCApp sharedApp].user = user;
                                              [DCDefault saveLoginedUser:user];
                                              
                                              NSLog(@"%@", user.avatarUrl);
                                              
                                              //                                                  [[DCApp sharedApp] fetchUserKeysCompletion:^(BOOL success) {}];
                                              
                                              [DCSiteApi getUserChargingStatus:user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                                                  if ([webResponse isSuccess]) {
                                                      if ([[webResponse.result objectForKey:@"charging"] boolValue] == YES) {
                                                          [hud hide:YES];
                                                          [DCApp sharedApp].rootTabBarController.selectedIndex = 0;
                                                      }
                                                  }
                                              }];
                                              [self dismiss:sender];
                                              [hud hide:YES];
                                              
                                          }];
}

#pragma mark 第三方登录
// 微信登录
- (IBAction)weiXinLoginClick:(id)sender {
    [self thirdLoginType:SSDKPlatformTypeWechat accType:DCBindTypeWeChat sender:sender];
}

// QQ登录
- (IBAction)qqLoginClick:(id)sender {
    [self thirdLoginType:SSDKPlatformTypeQQ accType:DCBindTypeQQ sender:sender];
}

// 第三方登录
- (void)thirdLoginType:(SSDKPlatformType)shareType accType:(DCUserBindType)accType sender:(id)sender{
    UIButton *button = (UIButton *)sender;
    
    [ShareSDK cancelAuthorize:shareType];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [ShareSDK getUserInfo:shareType onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateFail) {
            [self hideHUD:hud withText:@"用户第三方登录失败"];
            return;
        }
        
        if (state == SSDKResponseStateCancel) {
            [self hideHUD:hud withText:@"用户取消第三方登录"];
            return;
        }
        
        //uid和第三方登录类型上传到服务器
        self.thirdLoginTask = [DCSiteApi postLoginWithAccount:user.uid password:user.credential.token accType:accType pushId:[self pushIdForLogin] completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            // 判断是否与服务器中的userID绑定
            if ([webResponse isSuccess]) {
                DCUser *user = [[DCUser alloc] initWithLoginResponse:webResponse.result];
                [DCApp sharedApp].user = user;
                [DCDefault saveLoginedUser:user];
                //                    [[DCApp sharedApp] fetchUserKeysCompletion:^(BOOL success) {}];
                
                
                //用户登录后是否正在充电中
                [DCSiteApi getUserChargingStatus:user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                    if ([[webResponse.result objectForKey:@"charging"] boolValue] == YES) {
                        [DCApp sharedApp].rootTabBarController.selectedIndex = 0;
                    }
                    [self dismiss:button];
                    [hud hide:YES];
                }];
            }
            
            else if (webResponse.code == DCErrorCodeAccountNotExist) {
                //获取用户的第三方登录的信息后取消授权
                [ShareSDK cancelAuthorize:shareType];
                //没有就跳转到注册页面
                [self postThirdInfoToPhoneNumVC:user thirdAccType:accType];
                [self performSegueWithIdentifier:@"bindPhoneNumberVC" sender:nil];
                [hud hide:YES];
            }
            
            else {
                [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            }
        }];
    }];
}

     
     // 把第三方登录资料传到PhoneNumVC
-(void)postThirdInfoToPhoneNumVC:(SSDKUser *)user thirdAccType:(NSInteger)thirdAccType {
    self.thirdUid = user.uid;
    self.thirdAccToken = user.credential.token;
    self.thirdAccType = thirdAccType;
    self.thirdNickName = user.nickname;
    if (user.gender == 0) {
        _thirdGender = DCUserGenderMale;
    }else if (user.gender == 1) {
        _thirdGender = DCUserGenderFemale;
    }
    self.thirdAvatarUrl = user.icon;
}

#pragma mark 忘记密码
-(void)forgetPwdClick:(id)sender{
    [self performSegueWithIdentifier:@"phoneNumForResetPwd" sender:nil];
}

#pragma mark 创建新用户
-(void)creatCountClick:(id)sender{
    [self performSegueWithIdentifier:@"phoneNumViewController" sender:nil];
}

#pragma mark - TextField Action
- (void)textFeildDidchange:(id)sender {
    if (self.userNameTextFeild.text.length == 0) {
        self.passwordTextFeild.text = nil;
    }
    self.loginButton.enabled = (self.userNameTextFeild.text.length > 0) && (self.passwordTextFeild.text.length > 0);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userNameTextFeild) {
        [self.passwordTextFeild becomeFirstResponder];
    } else if (textField == self.passwordTextFeild) {
        [textField resignFirstResponder];
        [self loginClick:nil];
    }
    return YES;
}

@end
