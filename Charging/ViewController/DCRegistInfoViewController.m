//
//  HSSYRegistInfoViewController.m
//  Charging
//
//  Created by Ben on 14/12/23.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCRegistInfoViewController.h"
#import "DCSiteApi.h"
#import "DCCommon.h"
#import "JPUSHService.h"
#import "NSString+HSSY.h"

@interface DCRegistInfoViewController (){
    DCUserGender selectedSexType;
}
@property(nonatomic) IBOutlet UITextField *phoneNumTextFeild;
@property(nonatomic) IBOutlet UITextField *pwdTextFeild;
@property(nonatomic) IBOutlet UITextField *userNameTextFeild;
@property (weak, nonatomic) IBOutlet UIImageView *userNameBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneNumBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIImageView *phoneNumIcon;
@property (weak, nonatomic) IBOutlet UIImageView *pwdIcon;
@property (weak, nonatomic) IBOutlet UIImageView *userNameIcon;
@property (weak, nonatomic) IBOutlet UIButton *sexSelected_Male_Btn;
@property (weak, nonatomic) IBOutlet UIButton *sexSelected_Female_Btn;

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (weak, nonatomic) IBOutlet UIButton *argeementBtn;

@property (weak, nonatomic) IBOutlet UILabel *setPwdTipsLabel;
@end

@implementation DCRegistInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.phoneNumTextFeild.text = self.phoneNumString;
    self.phoneNumTextFeild.userInteractionEnabled = NO;
    [self drawBorderAndRoundCorner:self.phoneNumBackgroundImageView];
    [self drawBorderAndRoundCorner:self.passwordBackgroundImageView];
    [self drawBorderAndRoundCorner:self.userNameBackgroundImageView];
    [self drawBorderAndRoundCorner:_sexSelected_Male_Btn];
    [self drawBorderAndRoundCorner:_sexSelected_Female_Btn];
    [self.submitBtn setCornerRadius:4];
    self.argeementBtn.titleLabel.textColor = [UIColor paletteDCMainColor];
    selectedSexType = DCUserGenderMale;
    [self setSexSelectedView];
    
    self.userNameTextFeild.text = self.thirdNickName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Action
- (IBAction)maleClick:(id)sender {
    selectedSexType = DCUserGenderMale;
    [self.sexSelected_Male_Btn setImage:[UIImage imageNamed:@"user_sex_male_off"] forState:UIControlStateNormal];
    [self.sexSelected_Male_Btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sexSelected_Male_Btn.backgroundColor = [UIColor paletteDCMainColor];
    [self.sexSelected_Female_Btn setImage:[UIImage imageNamed:@"user_sex_female_on"] forState:UIControlStateNormal];
    [self.sexSelected_Female_Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.sexSelected_Female_Btn.backgroundColor = [UIColor whiteColor];
    [self setSexSelectedView];
}

- (IBAction)femaleClick:(id)sender {
    selectedSexType = DCUserGenderFemale;
    [self.sexSelected_Female_Btn setImage:[UIImage imageNamed:@"user_sex_female_off"] forState:UIControlStateNormal];
    [self.sexSelected_Female_Btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sexSelected_Female_Btn.backgroundColor = [UIColor paletteDCMainColor];
    [self.sexSelected_Male_Btn setImage:[UIImage imageNamed:@"user_sex_male_on"] forState:UIControlStateNormal];
    [self.sexSelected_Male_Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.sexSelected_Male_Btn.backgroundColor = [UIColor whiteColor];
    [self setSexSelectedView];
}

- (IBAction)registclick:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.pwdTextFeild.text.length == 0) {
        [self hideHUD:hud withText:@"请设置登录密码"];
        return;
    }
    if (![DCCommon judgeStringNotContaintCN:self.pwdTextFeild.text]) {
        [self hideHUD:hud withText:@"密码只能为数字或者字母"];
        return;
    }
    if (self.pwdTextFeild.text.length < 6 || self.pwdTextFeild.text.length > 16) {
        [self hideHUD:hud withText:@"密码必须为6到16位"];
        return;
    }
    if (self.userNameTextFeild.text.length == 0) {
        [self hideHUD:hud withText:@"用户名不能为空"];
        return;
    }
    if ([NSString isStringContainsEmoji:self.userNameTextFeild.text]) {
        [self hideHUD:hud withText:@"用户名不能含有表情"];
        return;
    }

    if (self.thirdUid != nil) { // 第三方注册登录流程
        if (self.pwdTextFeild.text.length >0 && self.thirdNickName != nil) {
            hud.labelText = @"正在注册...";
            
//            NSInteger userType;
//            if (self.thirdAccType == 3) {
//                userType = 3;
//            }else if (self.thirdAccType == 4) {
//                userType = 4;
//            }

            [DCSiteApi postUserRegister:self.phoneNumString password:self.pwdTextFeild.text accType:self.thirdAccType nickName:self.userNameTextFeild.text gender:self.thirdGender captcha:self.verificationString thirdAccUid:self.thirdUid thirdAccToken:self.thirdAccToken pushId:[JPUSHService registrationID] completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if (![webResponse isSuccess]) {
                    [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                    return;
                }
                
                [hud hide:YES];
                NSString *pushId = [JPUSHService registrationID];
                if (pushId.length == 0) { pushId = nil; }
                
                DCUser *user = [[DCUser alloc] initWithLoginResponse:webResponse.result];
                [DCApp sharedApp].user = user;
                [DCDefault saveLoginedUser:user];
                DDLogDebug(@"Login userId %@ pushId %@", user.userId, pushId);
                
                [self performSegueWithIdentifier:@"finishRegist" sender:nil];
                
//                [DCSiteApi postLoginWithAccount:user.thirdUuid
//                                       password:self.pwdTextFeild.text
//                                       accType:self.thirdAccType
//                                         pushId:pushId
//                                     completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//                                         if (![webResponse isSuccess]) {
//                                             [hud hide:YES];
//                                             [self performSegueWithIdentifier:@"finishRegist" sender:nil];
//                                             return;
//                                         }
//                                         
//                                         DCUser *user = [[DCUser alloc] initWithLoginResponse:webResponse.result];
//                                         [DCApp sharedApp].user = user;
//                                         [DCDefault saveLoginedUser:user];
//                                         NSLog(@"%@", self.thirdAvatarUrl);
//                                         
//                                         [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.thirdAvatarUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                                              NSData *avatarData = UIImageJPEGRepresentation(image, 1);
//                                             [DCSiteApi postAvatar:avatarData userId:user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//                                                 if ([webResponse isSuccess]) {
//                                                     NSLog(@"上传头像成功");
//                                                     [hud hide:YES];
//                                                     //不做任何操作
//                                                     DCUser *user = [[DCUser alloc] initWithDict:webResponse.result];
//                                                     user.token = [DCApp sharedApp].user.token;
//                                                     user.refreshToken = [DCApp sharedApp].user.refreshToken;
//                                                     [DCApp sharedApp].user = user;
//                                                     [DCDefault saveLoginedUser:user];
//                                                     [self performSegueWithIdentifier:@"finishRegist" sender:nil];
//
//                                                 } else {
//                                                     NSLog(@"上传头像不成功");
//                                                     [hud hide:YES];
//                                                     [DCApp sharedApp].user = user;
//                                                     [DCDefault saveLoginedUser:user];
//                                                     
//                                                     [self performSegueWithIdentifier:@"finishRegist" sender:nil];
//
//                                                 }
//                                             }];
//                                         }];
//                                         DDLogDebug(@"Login userId %@ pushId %@", user.userId, pushId);
//                                         
//                                     }];
            }];
        }
    } else { // 普通手机注册登录流程
        if (self.phoneNumTextFeild.text.length >0 && self.pwdTextFeild.text.length >0 && self.userNameTextFeild.text.length >0) {
            hud.labelText = @"正在注册...";
            
            [DCSiteApi postUserRegister:self.phoneNumTextFeild.text password:self.pwdTextFeild.text accType:1 nickName:self.userNameTextFeild.text gender:selectedSexType captcha:self.verificationString thirdAccUid:nil thirdAccToken:nil pushId:[JPUSHService registrationID] completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if (![webResponse isSuccess]) {
                    [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                    return;
                }
                
                NSString *pushId = [JPUSHService registrationID];
                if (pushId.length == 0) { pushId = nil; }
                
                [DCSiteApi postLoginWithAccount:self.phoneNumTextFeild.text
                                       password:self.pwdTextFeild.text
                                       accType:1
                                         pushId:pushId
                                     completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                                         if (![webResponse isSuccess]) {
                                             [hud hide:YES];
                                             [self performSegueWithIdentifier:@"finishRegist" sender:nil];
                                             return;
                                         }
                                         [hud hide:YES];
                                         DCUser *user = [[DCUser alloc] initWithLoginResponse:webResponse.result];
                                         [DCApp sharedApp].user = user;
                                         [DCDefault saveLoginedUser:user];
                                         DDLogDebug(@"Login userId %@ pushId %@", user.userId, pushId);
                                         
                                         [self performSegueWithIdentifier:@"finishRegist" sender:nil];
//                                         [[DCApp sharedApp] fetchUserKeysCompletion:^(BOOL success) {
//                                             [hud hide:YES];
//                                             [self performSegueWithIdentifier:@"finishRegist" sender:nil];
//                                         }];
                                     }];
            }];
        } else {//textField空了
            [hud setLabelText:@"信息不能为空"];
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:2];
        }
    }    
}

#pragma mark - Extension
- (void)setSexSelectedView {
    self.sexSelected_Male_Btn.selected = (selectedSexType == DCUserGenderMale);
    self.sexSelected_Female_Btn.selected = (selectedSexType == DCUserGenderFemale);
}

@end
