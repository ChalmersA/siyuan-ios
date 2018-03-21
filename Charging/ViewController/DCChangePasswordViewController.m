//
//  DCChangePasswordViewController.m
//  Charging
//
//  Created by hxcui on 15/7/27.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCChangePasswordViewController.h"
#import "DCColorButton.h"
#import "DCSiteApi.h"

@interface DCChangePasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *currentPassword;
@property (weak, nonatomic) IBOutlet UITextField *theNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;

@property (weak, nonatomic) IBOutlet UIImageView *currentPasswordBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *theNewPasswordBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *confirmPasswordBackgroundImageView;

//@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightButtonLten;

@end

@implementation DCChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self drawBorderAndRoundCorner:self.currentPasswordBackgroundImageView];
    [self drawBorderAndRoundCorner:self.theNewPasswordBackgroundImageView];
    [self drawBorderAndRoundCorner:self.confirmPasswordBackgroundImageView];
    
//    self.navigationItem.rightBarButtonItem = self.rightButtonLten;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.currentPassword) {
        [self.theNewPassword becomeFirstResponder];
    }else if(textField == self.theNewPassword){
        [self.confirmPassword becomeFirstResponder];
    }if (textField == self.confirmPassword) {
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)doneAction:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    typeof(self) __weak weakSelf = self;
    if (self.currentPassword.text.length > 0 && self.theNewPassword.text.length > 0 && self.confirmPassword.text.length > 0) {
        if ([self.theNewPassword.text isEqualToString:self.currentPassword.text] && [self.currentPassword.text isEqualToString:self.confirmPassword.text]) {
            [self hideHUD:hud withText:@"新旧密码重复,请重新设置"];
            
        } else if (![self.theNewPassword.text isEqualToString:self.confirmPassword.text]) {
            [self hideHUD:hud withText:@"新密码两次输入不一致"];
            
        } else {
            [DCSiteApi postChangePasswordUserId:[DCApp sharedApp].user.userId currentPassword:self.currentPassword.text newPassword:self.theNewPassword.text completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if (![webResponse isSuccess]) {
                    [weakSelf hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                } else {
                    [weakSelf hideHUD:hud withText:@"修改成功"];
                    hud.completionBlock = ^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    };
                }
            }];
        }
    }
    else if (self.currentPassword.text.length <= 0) {
        [self hideHUD:hud withText:@"当前密码不能为空"];
    }
    else if (self.theNewPassword.text.length <= 0) {
        [self hideHUD:hud withText:@"新密码不能为空"];
    }
    else if (self.confirmPassword.text.length <= 0) {
        [self hideHUD:hud withText:@"确认密码不能为空"];
    }
}

@end
