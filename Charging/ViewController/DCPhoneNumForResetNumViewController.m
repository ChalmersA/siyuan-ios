//
//  HSSYPhoneNumForResetNumViewController.m
//  Charging
//
//  Created by Ben on 14/12/23.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCPhoneNumForResetNumViewController.h"
#import "DCSiteApi.h"
#import "DCPwdForResetViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

static const NSInteger MAX_COUNTDOWN_TIMES = 60;

@interface DCPhoneNumForResetNumViewController ()
@property(nonatomic) IBOutlet UITextField *phoneNumTextFeild;
@property (weak, nonatomic) IBOutlet UITextField *captchaTextFeild;
@property (weak, nonatomic) IBOutlet UIImageView *phoneNumBackgorundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *captchaBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *captchaButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (retain, nonatomic) NSTimer *countDownTimer;
@property (assign, nonatomic) NSInteger timesForCountdown;

@end

@implementation DCPhoneNumForResetNumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.captchaButton.layer.cornerRadius = 3;
    self.captchaButton.layer.masksToBounds = YES;
    
    if (self.phoneNum) {
        self.phoneNumTextFeild.text = self.phoneNum;
    }
    
    [self.phoneNumTextFeild addTarget:self action:@selector(textFeildDidchange:) forControlEvents:UIControlEventEditingChanged];
    [self.captchaTextFeild addTarget:self action:@selector(textFeildDidchange:) forControlEvents:UIControlEventEditingChanged];
    self.confirmButton.backgroundColor = [UIColor paletteButtonBackgroundColor];
        
    [self drawBorderAndRoundCorner:self.phoneNumBackgorundImageView];
    [self drawBorderAndRoundCorner:self.captchaBackgroundImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getTheCaptcha:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.phoneNumTextFeild.text.length != 11) {
        [self hideHUD:hud withText:@"请输入正确的手机号"];
        return;
    }
    
    [self.view endEditing:YES];
    hud.labelText = @"正在申请验证码...";
    
    typeof(self) __weak weakSelf = self;
    [DCSiteApi postSendSms:self.phoneNumTextFeild.text type:DCSmsTypeResetPassword completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {  //请求失败
            [weakSelf hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        [weakSelf.captchaTextFeild becomeFirstResponder];
        [weakSelf startCountDown];
        [hud hide:YES];
    }];
}

- (IBAction)confirmToResetPassword:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.phoneNumTextFeild.text.length > 0) {
        hud.labelText = @"正在申请验证码...";
        [DCSiteApi postExamineVerification:self.phoneNumTextFeild.text captcha:self.captchaTextFeild.text completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (![webResponse isSuccess]) {
                [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                return;
            }
            [hud hide:YES];
            [self performSegueWithIdentifier:@"newPwdViewController" sender:nil];
        }];
    }else{ //textField空了
        [hud setLabelText:@"手机号不能为空"];
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"newPwdViewController"]) {
        DCPwdForResetViewController *vc = [segue destinationViewController];
        vc.phoneNum = self.phoneNumTextFeild.text;
        vc.captcha = self.captchaTextFeild.text;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - TextField Action
- (void)textFeildDidchange:(id)sender {
    if (self.phoneNumTextFeild.text.length == 0) {
        self.captchaTextFeild.text = nil;
    }
    self.confirmButton.enabled = (self.phoneNumTextFeild.text.length > 0) && (self.captchaTextFeild.text.length > 0);
    if (self.confirmButton.enabled) {
        self.confirmButton.backgroundColor = [UIColor paletteButtonRedColor];
    } else {
        self.confirmButton.backgroundColor = [UIColor paletteButtonBackgroundColor];
    }
}

#pragma mark - Countdown
- (void)startCountDown {
    if (!self.countDownTimer) {
        self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerCounted) userInfo:nil repeats:YES];
    }
    self.timesForCountdown = MAX_COUNTDOWN_TIMES;
    [self.captchaButton setTitle:[NSString stringWithFormat:@"%lds后重新发送", (long)self.timesForCountdown] forState:UIControlStateDisabled];
    [self.captchaButton setBackgroundColor:[UIColor lightGrayColor]];
    self.captchaButton.enabled = NO;
}
- (void)stopCountDown {
    if (self.countDownTimer) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
    self.timesForCountdown = 0;
    [self.captchaButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.captchaButton setBackgroundColor:[UIColor paletteDCMainColor]];
    self.captchaButton.enabled = YES;
}

- (void)timerCounted {
    if (self.timesForCountdown <= 1) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
        
        [self.captchaButton setTitle:@"重新获取验证码" forState:UIControlStateNormal];
        [self.captchaButton setBackgroundColor:[UIColor paletteDCMainColor]];
        self.captchaButton.enabled = YES;
        
    }
    else {
        //TODO: show countdown
        self.timesForCountdown -= 1;
        [self.captchaButton setTitle:[NSString stringWithFormat:@"%lds后重新发送", (long)self.timesForCountdown] forState:UIControlStateDisabled];
    }
}

@end
