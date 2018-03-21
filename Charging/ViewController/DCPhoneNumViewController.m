//
//  HSSYPhoneNumViewController.m
//  Charging
//
//  Created by Ben on 14/12/23.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCPhoneNumViewController.h"
#import "DCSiteApi.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DCRegistInfoViewController.h"
#import "DCHTTPSessionManager.h"
#import "DCTwoButtonView.h"
#import "DCPopupView.h"
#import "DCPhoneNumForResetNumViewController.h"

static const NSInteger MAX_COUNTDOWN_TIMES = 60;

@interface DCPhoneNumViewController () <UITextFieldDelegate, DCTwoButtonViewDelegate> {
    NSString *_verifyPhone;
    NSString *_verifyCode;
}
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextFeild;
@property (weak, nonatomic) IBOutlet UIImageView *phoneNumBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *verifyNumBackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *verificationTextFeild;
@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (retain, nonatomic) NSTimer *countDownTimer;
@property (assign, nonatomic) NSInteger timesForCountdown;

@property (strong, nonatomic) DCPopupView *popUpView;

@end

@implementation DCPhoneNumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self drawBorderAndRoundCorner:self.phoneNumBackgroundImageView];
    [self drawBorderAndRoundCorner:self.verifyNumBackgroundImageView];
    [self.verifyBtn setCornerRadius:3];
    
    [self.phoneNumTextFeild addTarget:self action:@selector(textFeildDidchange:) forControlEvents:UIControlEventEditingChanged];
    [self.verificationTextFeild addTarget:self action:@selector(textFeildDidchange:) forControlEvents:UIControlEventEditingChanged];
    self.nextStepBtn.backgroundColor = [UIColor paletteButtonBackgroundColor];
    
    [self.nextStepBtn setCornerRadius:4];
    self.phoneNumTextFeild.text = self.phoneNumber;
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
    if ([segue.identifier isEqual:@"ToRegistInfoController"]) {
        DCRegistInfoViewController *vc = segue.destinationViewController;
        vc.verificationString = _verifyCode;
        vc.phoneNumString = _verifyPhone;
    }
    else if ([segue.identifier isEqualToString:@"DCPhoneNumForResetNumViewController"]) {
        DCPhoneNumForResetNumViewController *vc = segue.destinationViewController;
        vc.phoneNum = self.phoneNumTextFeild.text;
    }
    else  {
        DCRegistInfoViewController *vc = segue.destinationViewController;
        vc.verificationString = _verifyCode;
        vc.phoneNumString = _verifyPhone;
        vc.thirdUid = self.thirdUid;
        vc.thirdAccToken = self.thirdAccToken;
        vc.thirdAccType = self.thirdAccType;
        vc.thirdNickName = self.thirdNickName;
        vc.thirdGender = self.thirdGender;
        vc.thirdAvatarUrl = self.thirdAvatarUrl;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)verifyCode:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.phoneNumTextFeild.text.length != 11) {
        [self hideHUD:hud withText:@"请输入正确的手机号"];
        return;
    }
    
    [self.view endEditing:YES];
    hud.labelText = @"正在申请验证码...";
    
    typeof(self) __weak weakSelf = self;
    [DCSiteApi postSendSms:self.phoneNumTextFeild.text type:DCSmsTypeRegister completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {  //请求失败
            if (webResponse.code == RESPONSE_CODE_PHONE_EXISTS) {
                [hud hide:YES];
                DCTwoButtonView *view = [DCTwoButtonView loadTwoButtonViewWithType:DCTwoButtonTypeLogin];
                view.delegate = self;
                self.popUpView = [DCPopupView popUpWithTitle:@"该手机号码已经注册" contentView:view withController:self];
                return;
            }
            
            [weakSelf hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        [weakSelf.verificationTextFeild becomeFirstResponder];
        [weakSelf startCountDown];
        [hud hide:YES];
    }];
}

#pragma mark - Countdown
- (void)startCountDown {
    if (!self.countDownTimer) {
        self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerCounted) userInfo:nil repeats:YES];
    }
    self.timesForCountdown = MAX_COUNTDOWN_TIMES;
    [self.verifyBtn setTitle:[NSString stringWithFormat:@"%lds后重新发送", (long)self.timesForCountdown] forState:UIControlStateDisabled];
    [self.verifyBtn setBackgroundColor:[UIColor lightGrayColor]];
    self.verifyBtn.enabled = NO;
}
- (void)stopCountDown {
    if (self.countDownTimer) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
    self.timesForCountdown = 0;
    [self.verifyBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.verifyBtn setBackgroundColor:[UIColor paletteDCMainColor]];
    self.verifyBtn.enabled = YES;
}

- (void)timerCounted {
    if (self.timesForCountdown <= 1) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
        
        [self.verifyBtn setTitle:@"重新获取验证码" forState:UIControlStateNormal];
        [self.verifyBtn setBackgroundColor:[UIColor paletteDCMainColor]];
        self.verifyBtn.enabled = YES;
        
    }
    else {
        //TODO: show countdown
        self.timesForCountdown -= 1;
        [self.verifyBtn setTitle:[NSString stringWithFormat:@"%lds后重新发送", (long)self.timesForCountdown] forState:UIControlStateDisabled];
//        [self.verifyBtn setBackgroundColor:[UIColor grayColor]];
//        self.verifyBtn.enabled = NO;
    }
}

#pragma mark - Action
- (IBAction)navigateNext:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.phoneNumTextFeild.text.length != 11) {
        [self hideHUD:hud withText:@"请输入正确的手机号"];
        return;
    }
    if (self.verificationTextFeild.text.length == 0) {
        [self hideHUD:hud withText:@"请输入正确的验证码"];
        return;
    }

    _verifyPhone = [self.phoneNumTextFeild.text copy];
    _verifyCode = [self.verificationTextFeild.text copy];
    [self.view endEditing:YES];
    
    typeof(self) __weak weakSelf = self;
    [DCSiteApi postExamineVerification:_verifyPhone captcha:_verifyCode completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {  //请求失败
            if (webResponse.code == 30005) { //30005为非法操作提示，未获取验证码
                [weakSelf hideHUD:hud withText:@"请获取验证码"];
            } else {
                [weakSelf hideHUD:hud withText:[webResponse message]];
            }
            return;
        }
        
        [hud hide:YES];
        if (self.thirdUid != nil) {
            [self performSegueWithIdentifier:@"setPasswordVC" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"ToRegistInfoController" sender:nil];
        }
        // 取消验证码倒计时
        [self stopCountDown];
        [self.verificationTextFeild resignFirstResponder];
        [self.phoneNumTextFeild resignFirstResponder];
        [self.verificationTextFeild setText:@""];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location >= 11) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([textField isEqual:self.phoneNumTextFeild]) {
        [self.phoneNumTextFeild resignFirstResponder];
    }
    else if([textField isEqual:self.verificationTextFeild]) {
        [self navigateNext:nil];
    }
    return YES;
}

- (void)textFeildDidchange:(id)sender {
    if (self.phoneNumTextFeild.text.length == 0) {
        self.verificationTextFeild.text = nil;
    }
    self.nextStepBtn.enabled = (self.phoneNumTextFeild.text.length > 0) && (self.verificationTextFeild.text.length > 0);
    if (self.nextStepBtn.enabled) {
        self.nextStepBtn.backgroundColor = [UIColor paletteButtonRedColor];
    } else {
        self.nextStepBtn.backgroundColor = [UIColor paletteButtonBackgroundColor];
    }
}

#pragma mark - DCTwoButtonView
- (void)clickTheReturnButton {
    [self.popUpView dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickTheForgetButton {
    [self.popUpView dismiss];
    DCPhoneNumForResetNumViewController *vc = [DCPhoneNumForResetNumViewController storyboardInstantiateWithIdentifierInLogin:@"DCPhoneNumForResetNumViewController"];
//    [self performSegueWithIdentifier:@"DCPhoneNumForResetNumViewController" sender:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
