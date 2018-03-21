//
//  BindingCardVC.m
//  
//
//  Created by 陈志强 on 2018/3/7.
//
//

#import "BindingCardVC.h"

static const NSInteger MAX_COUNTDOWN_TIMES = 60;


@interface BindingCardVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumTF;//手机号
@property (weak, nonatomic) IBOutlet UITextField *cardNumTF;//卡号
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTF;//验证码

@property (weak, nonatomic) IBOutlet UIButton *getVerificationCodeBtn;//获取验证码
@property (weak, nonatomic) IBOutlet UIButton *bindingButton;//绑定

@property (nonatomic, strong) NSString *verificationCode;//验证码

@property (retain, nonatomic) NSTimer *countDownTimer;
@property (assign, nonatomic) NSInteger timesForCountdown;
@end

@implementation BindingCardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"绑定充电卡";
    
    [self setupUI];
}

- (void)setupUI {
    
    self.view1.layer.borderWidth = 1;
    self.view1.layer.borderColor = [UIColor paletteDCMainColor].CGColor;
    self.view1.layer.cornerRadius = 5;
    
    self.view2.layer.borderWidth = 1;
    self.view2.layer.borderColor = [UIColor paletteDCMainColor].CGColor;
    self.view2.layer.cornerRadius = 5;
    
    self.view3.layer.borderWidth = 1;
    self.view3.layer.borderColor = [UIColor paletteDCMainColor].CGColor;
    self.view3.layer.cornerRadius = 5;
    
    self.getVerificationCodeBtn.layer.cornerRadius = 5;
    
    self.phoneNumTF.delegate = self;
    self.cardNumTF.delegate = self;
    self.verificationCodeTF.delegate = self;
    
    self.bindingButton.layer.cornerRadius = 5;
//    self.bindingButton.backgroundColor = [UIColor paletteButtonBackgroundColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Countdown
- (void)startCountDown {
    if (!self.countDownTimer) {
        self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerCounted) userInfo:nil repeats:YES];
    }
    self.timesForCountdown = MAX_COUNTDOWN_TIMES;
    [self.getVerificationCodeBtn setTitle:[NSString stringWithFormat:@"%lds后重新发送", (long)self.timesForCountdown] forState:UIControlStateDisabled];
    [self.getVerificationCodeBtn setBackgroundColor:[UIColor lightGrayColor]];
    self.getVerificationCodeBtn.enabled = NO;
}
- (void)stopCountDown {
    if (self.countDownTimer) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
    self.timesForCountdown = 0;
    [self.getVerificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.getVerificationCodeBtn setBackgroundColor:[UIColor paletteDCMainColor]];
    self.getVerificationCodeBtn.enabled = YES;
}

- (void)timerCounted {
    if (self.timesForCountdown <= 1) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
        
        [self.getVerificationCodeBtn setTitle:@"重新获取验证码" forState:UIControlStateNormal];
        [self.getVerificationCodeBtn setBackgroundColor:[UIColor paletteDCMainColor]];
        self.getVerificationCodeBtn.enabled = YES;
        
    }
    else {
        //TODO: show countdown
        self.timesForCountdown -= 1;
        [self.getVerificationCodeBtn setTitle:[NSString stringWithFormat:@"%lds后重新发送", (long)self.timesForCountdown] forState:UIControlStateDisabled];
        //        [self.verifyBtn setBackgroundColor:[UIColor grayColor]];
        //        self.verifyBtn.enabled = NO;
    }
}


//获取验证码
- (IBAction)getVerificationCodeAction:(UIButton *)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.phoneNumTF.text.length != 11) {
        [self hideHUD:hud withText:@"请输入正确的手机号"];
        return;
    }
    
    [self.view endEditing:YES];
    hud.labelText = @"正在申请验证码...";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"cardId"] = self.cardNumTF.text;
    parameters[@"phone"] = self.phoneNumTF.text;

    typeof(self) __weak weakSelf = self;
    [[DCHTTPSessionManager shareManager] GET:@"api/iccard/card/codesend" parameters:parameters completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        [hud hide:YES];
        if (![webResponse isSuccess]) {

            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:webResponse.message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        self.verificationCode = webResponse.result[@"captcha"];
        
        [weakSelf.verificationCodeTF becomeFirstResponder];
        [weakSelf startCountDown];
        [hud hide:YES];
    }];

}

//绑定
- (IBAction)buindingAction:(UIButton *)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if (self.phoneNumTF.text.length == 0) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入手机号";
        [hud hide:YES afterDelay:2];
        return;
    }
    if (self.cardNumTF.text.length == 0) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入卡号";
        [hud hide:YES afterDelay:2];
        return;
    }
    if (self.verificationCodeTF.text.length == 0) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入验证码";
        [hud hide:YES afterDelay:2];
        return;
    }

    if ((self.cardNumTF.text.length == 0) || (self.cardNumTF.text.length < 14)) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入正确的卡号";
        [hud hide:YES afterDelay:2];
        return;
    }
    //补全卡号位数
    if (self.cardNumTF.text.length == 14) self.cardNumTF.text = [self.cardNumTF.text stringByAppendingString:@"00"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"captcha"] = self.verificationCode;
    parameters[@"cardId"] = self.cardNumTF.text;
    parameters[@"userId"] = [DCApp sharedApp].user.userId;
    parameters[@"phone"] = self.phoneNumTF.text;

 //   MBProgressHUD *loadingHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
 //   hud.mode = MBProgressHUDModeIndeterminate;
    [[DCHTTPSessionManager shareManager] POST:@"api/iccard/card/iccardbind" parameters:parameters completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
     //   [loadingHud hide:YES];
        
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withDetailsText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        
        [self hideHUD:hud withDetailsText:@"充电卡绑定成功" completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.phoneNumTF]) {
        if (range.location >= 11) {
            return NO;
        }
    }
    else if([textField isEqual:self.cardNumTF]) {
        if (range.location >= 16) {
            return NO;
        }
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([textField isEqual:self.phoneNumTF]) {
        [self.phoneNumTF resignFirstResponder];
    }
    else if([textField isEqual:self.verificationCodeTF]) {
     //   [self navigateNext:nil];
    }
    return YES;
}


- (void)textFeildDidchange:(id)sender {
    if (self.phoneNumTF.text.length == 0) {
        self.verificationCodeTF.text = nil;
    }
    self.bindingButton.enabled = (self.cardNumTF.text.length > 0) && (self.verificationCodeTF.text.length > 0);
    if (self.bindingButton.enabled) {
        self.bindingButton.backgroundColor = [UIColor paletteDCMainColor];
    } else {
        self.bindingButton.backgroundColor = [UIColor paletteButtonBackgroundColor];
    }
}
@end
