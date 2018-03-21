//
//  HSSYPwdForResetViewController.m
//  Charging
//
//  Created by Ben on 14/12/23.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCPwdForResetViewController.h"
#import "DCSiteApi.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface DCPwdForResetViewController ()
@property(nonatomic) IBOutlet UITextField *pwdTextFeild;
@property (weak, nonatomic) IBOutlet UIImageView *passwordBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *confrimPwdBackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *confrimPwdTextFeild;
@property (weak, nonatomic) IBOutlet UIButton *confirmToResetPwd;
@end

@implementation DCPwdForResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.pwdTextFeild addTarget:self action:@selector(textFeildDidchange:) forControlEvents:UIControlEventEditingChanged];
//    [self.confrimPwdTextFeild addTarget:self action:@selector(textFeildDidchange:) forControlEvents:UIControlEventEditingChanged];
    
    self.confirmToResetPwd.backgroundColor = [UIColor paletteButtonBackgroundColor];
    
    self.pwdTextFeild.secureTextEntry = YES;
    [self drawBorderAndRoundCorner:self.passwordBackgroundImageView];
    [self drawBorderAndRoundCorner:self.confrimPwdBackgroundImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - TextField Action
- (void)textFeildDidchange:(id)sender {
//    if (self.pwdTextFeild.text.length == 0) {
//        self.confrimPwdTextFeild.text = nil;
//    }
//    self.confirmToResetPwd.enabled = (self.pwdTextFeild.text.length > 0) && (self.confrimPwdTextFeild.text.length > 0);
//    if (self.confirmToResetPwd.enabled) {
//        self.confirmToResetPwd.backgroundColor = [UIColor paletteButtonRedColor];
//    } else {
//        self.confirmToResetPwd.backgroundColor = [UIColor paletteButtonBackgroundColor];
//    }
    self.confirmToResetPwd.enabled = self.pwdTextFeild.text.length > 0;
    if (self.confirmToResetPwd.enabled) {
        self.confirmToResetPwd.backgroundColor = [UIColor paletteButtonRedColor];
    } else {
        self.confirmToResetPwd.backgroundColor = [UIColor paletteButtonBackgroundColor];
    }
}

#pragma mark - Action
- (IBAction)confirmToReset:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    if (![self.pwdTextFeild.text isEqualToString:self.confrimPwdTextFeild.text]) {
//        hud.mode = MBProgressHUDModeText;
//        hud.labelText = @"新密码与确认密码不一致";
//        [hud hide:YES afterDelay:2];
//        return;
//    }
    if (self.pwdTextFeild.text.length > 0) {
        hud.labelText = @"正在重置...";
        [DCSiteApi postReSetPassword:self.phoneNum
                            password:self.pwdTextFeild.text
                             captcha:self.captcha
                          completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                              if (![webResponse isSuccess]) {
                                  [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                                  return;
                              }
                              
                              [self performSegueWithIdentifier:@"resetPassword" sender:nil];
                              [hud hide:YES];
                          }];
    }else { //textField空了
        [hud setLabelText:@"密码不能为空"];
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
