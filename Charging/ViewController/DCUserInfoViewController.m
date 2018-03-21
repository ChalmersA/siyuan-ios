//
//  DCUserInfoViewController.m
//  Charging
//
//  Created by xpg on 14/12/17.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCUserInfoViewController.h"
#import "ArrayDataSource.h"
#import "DCUserInfoTableViewCell.h"
#import "PopUpView.h"
#import "DCPopupView.h"
#import "DCQrcodeView.h"
#import "UIImage+QRCode.h"
#import "DCSiteApi.h"
#import "DCUser.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DCImagePickerController.h"
#import "UIButton+HSSYCategory.h"
#import "UIImage+HSSYCategory.h"
#import "DCTextInputViewController.h"
#import "DCChangePasswordViewController.h"

NSString * const DCSegueIdPushToTextInput = @"PushToTextInput";
NSString * const DCSegueChangePassword    = @"PushToUserPassword";

@implementation UserInfo // TODO: refactor
@end

@interface DCUserInfoViewController () <UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DCTextInputDelegate> {
    UserInfo *_selectedInfo;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) ArrayDataSource *dataSource;
@property (strong, nonatomic) DCUser *user;
@property (strong, nonatomic) UserInfo *userNameInfo;
@property (strong, nonatomic) UserInfo *userPhoneInfo;
@property (strong, nonatomic) UserInfo *userAlipayInfo;
@property (strong, nonatomic) UserInfo *userGenderInfo;
//@property (strong, nonatomic) UserInfo *userQrcodeInfo;

@property (strong, nonatomic) UserInfo *userHeadPhotoInfo;
@property (strong, nonatomic) UserInfo *userPasswordInfo;

@property (assign, nonatomic) NSInteger cellIndex; // TODO: refactor
@end

@implementation DCUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.user = [[DCApp sharedApp].user copy];
    
    [self initTableViewDataSource];
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self reloadUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[DCTextInputViewController class]]) {
        DCTextInputViewController *vc = segue.destinationViewController;
        vc.delegate = self;
//        vc.navigationItem.rightBarButtonItem = vc.doneBarButton;
        if (_selectedInfo == _userNameInfo) {
            vc.title = @"用户名";
            vc.text = self.user.nickName;
            vc.minLength = @(2);
            vc.maxLength = @(12);
            vc.textType = DCTextInputTypeUserName;
        } else {
            NSAssert(NO, @"unknown input text");
        }
    }
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            [self selectImagePickerSource:^(UIImagePickerControllerSourceType source) {
                [self showImagePickerForSourceType:source];
            }];
            break;
        }
        case 1: {//称昵
            _selectedInfo = _userNameInfo;
            [self performSegueWithIdentifier:DCSegueIdPushToTextInput sender:nil];
            break;
        }
        case 2: {//性别(self.user.gender)
//            UIActionSheet *sexActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"男" otherButtonTitles:@"女", nil];
//            sexActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
//            [sexActionSheet showInView:self.view];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertActionStyle manStyle = UIAlertActionStyleDefault;
            UIAlertActionStyle womanStyle = UIAlertActionStyleDefault;
            if (self.user.gender == DCUserGenderMale) {
                manStyle = UIAlertActionStyleDestructive;
            } else{
                womanStyle = UIAlertActionStyleDestructive;
            }
            UIAlertAction *manAction = [UIAlertAction actionWithTitle:@"男" style:manStyle handler:^(UIAlertAction * _Nonnull action) {
                [self didSelectedGenderIndex:0];
            }];
            UIAlertAction *womanAction = [UIAlertAction actionWithTitle:@"女" style:womanStyle handler:^(UIAlertAction * _Nonnull action) {
                 [self didSelectedGenderIndex:1];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:manAction];
            [alertController addAction:womanAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];

            
            break;
        }
        case 3:{//手机号码
             _selectedInfo = _userPhoneInfo;
            break;
        }
        case 4:{//修改密码
            [self performSegueWithIdentifier:DCSegueChangePassword sender:nil];
            break;
        }
//        case 5: {//收支账号管理
//
//            break;
//        }
        case 6: {//二维码
            UIImage *qrcodeImage = [UIImage qrcodeImageForString:self.user.phone withScale:[UIScreen mainScreen].scale * 16];
            DCQrcodeView *qrcodeView = [DCQrcodeView viewWithQrcodeImage:qrcodeImage];
            CGFloat width = CGRectGetWidth(self.view.bounds) - 80;
            qrcodeView.frame = CGRectMake(0, 0, width, width * 5 / 4);
            [DCPopupView popUpWithTitle:@"我的个人二维码" contentView:qrcodeView];
//            [PopUpView popUpWithContentView:qrcodeView];
            break;
        }
        default:
            break;
    }
}


#pragma mark - DCTextInputDelegate
- (void)textInputViewController:(DCTextInputViewController *)vc inputDone:(NSString *)text {    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    hud.labelText = @"正在保存...";
    
    DCUser *user = self.user;
    if (_selectedInfo == _userNameInfo){
        user.nickName = text;
    }
    
    vc.requestTask = [DCSiteApi postUpdateUserInfo:user completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [vc hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
        } else {
            [vc hideHUD:hud withText:@"保存成功"];
            NSDictionary *resultDic = webResponse.result;
            self.user = [[DCUser alloc] initWithDict:resultDic];
            _userNameInfo.userInfoValue = self.user.nickName;
//            _userAlipayInfo.userInfoValue = self.user.alipayName;
            [self.tableView reloadData];
            
            [DCApp sharedApp].user.nickName = self.user.nickName;
//            [DCApp sharedApp].user.alipayName = self.user.alipayName;
            [DCDefault saveLoginedUser:[DCApp sharedApp].user];
            [vc.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}

- (IBAction)saveModify:(id)sender {
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = @"正在保存...";
//
//    [DCSiteApi postUpdateUserInfo:self.user completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//        
//        if (![webResponse isSuccess]) {
//            [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
//        } else {
//            [self hideHUD:hud withText:@"保存成功"];
//            
//            DCUser *user = [[DCUser alloc] initWithDict:webResponse.result];
//            user.token = [DCApp sharedApp].user.token;
//            user.refreshToken = [DCApp sharedApp].user.refreshToken;
//            [DCApp sharedApp].user = user;
//            [DCDefault saveLoginedUser:user];
//        }
//        
//        [self reloadUserInfo];
//    }];
    
    /**
     *  TODO 功能有用
     */
    UIAlertView *logoutAlert = [UIAlertView showAlertMessage:@"您确定要注销当前账号吗？" buttonTitles:@[@"取消", @"确定"]];
    [logoutAlert setClickedButtonHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"正在注销...";
            
            [DCSiteApi postLogOut:self.user.phone completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                [hud hide:YES];
                [DCApp sharedApp].user = nil;
                [DCDefault saveLoginedUser:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_DID_CHANGE object:nil];
                [self presentLoginViewIfNeededCompletion:^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
            }];
        }
    }];
}

- (void)didSelectedGenderIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        self.user.gender = DCUserGenderMale;
        _userGenderInfo.userInfoValue = @"男";
        [self.tableView reloadData];
    } else if (buttonIndex == 1) {
        self.user.gender = DCUserGenderFemale;
        _userGenderInfo.userInfoValue = @"女";
        [self.tableView reloadData];
    } else if (buttonIndex == 2) {
        //取消不做任何东西
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在保存...";
    
    [DCSiteApi postUpdateUserInfo:self.user completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
        } else {
            [self hideHUD:hud withText:@"保存成功"];
            
            DCUser *user = [[DCUser alloc] initWithDict:webResponse.result];
            user.token = [DCApp sharedApp].user.token;
            user.refreshToken = [DCApp sharedApp].user.refreshToken;
            [DCApp sharedApp].user = user;
            [DCDefault saveLoginedUser:user];
        }
        
        [self reloadUserInfo];
    }];
}

#pragma mark - Data
- (void)initTableViewDataSource {
    _userNameInfo = [UserInfo new];
    _userNameInfo.imgName = @"user_icon_name";
    _userNameInfo.userInfoKey = @"用户名";
    _userNameInfo.userInfoValue = self.user.nickName;
    
    _userPhoneInfo = [UserInfo new];
    _userPhoneInfo.imgName = @"user_icon_phone";
    _userPhoneInfo.userInfoKey = @"登录手机号";
    _userPhoneInfo.userInfoValue = self.user.phone;
    
//    _userAlipayInfo = [UserInfo new];
//    _userAlipayInfo.imgName = @"user_icon_bill";
//    _userAlipayInfo.userInfoKey = @"提现账号管理";
//    _userAlipayInfo.userInfoValue = @"";
    
    _userGenderInfo = [UserInfo new];
    _userGenderInfo.imgName = @"user_icon_sex";
    _userGenderInfo.userInfoKey = @"性别";
    _userGenderInfo.userInfoValue = (self.user.gender == DCUserGenderMale ? @"男" : @"女");
    
//    _userQrcodeInfo = [UserInfo new];
//    _userQrcodeInfo.imgName = @"user_icon_qrcode";
//    _userQrcodeInfo.userInfoKey = @"我的二维码";
//    _userQrcodeInfo.userInfoValue = @"";
    
    _userPasswordInfo = [UserInfo new];
    _userPasswordInfo.imgName = @"user_icon_password-1";
    _userPasswordInfo.userInfoKey = @"登录密码";
    _userPasswordInfo.userInfoValue = @"修改";
    
    _userHeadPhotoInfo = [UserInfo new];
    _userHeadPhotoInfo.imgName = @"user_icon_picture";
    _userHeadPhotoInfo.userInfoKey = @"头像";
    _userHeadPhotoInfo.userAvatarURL = [self.user avatarImageURL];
    
    
//    NSArray *dataArray = @[_userHeadPhotoInfo, _userNameInfo, _userGenderInfo, _userPhoneInfo, _userPasswordInfo, _userAlipayInfo, _userQrcodeInfo];
    NSArray *dataArray = @[_userHeadPhotoInfo, _userNameInfo, _userGenderInfo, _userPhoneInfo, _userPasswordInfo];
    self.dataSource = [ArrayDataSource dataSourceWithItems:dataArray
                                            cellIdentifier:@"DCUserInfoCell"
                                        configureCellBlock:^(DCUserInfoTableViewCell *cell, UserInfo *userInfo) {
                                            [cell configureForUseInfo:userInfo];
                                        }];
    _tableView.dataSource = self.dataSource;
    [_tableView reloadData];
}

- (void)reloadUserInfo {
    self.user = [[DCApp sharedApp].user copy];
    _userHeadPhotoInfo.userAvatarURL = [self.user avatarImageURL];
    _userNameInfo.userInfoValue = self.user.nickName;
    _userGenderInfo.userInfoValue = (self.user.gender == DCUserGenderMale ? @"男" : @"女");
//    _userAlipayInfo.userInfoValue = self.user.alipayName;
    [self.tableView reloadData];
}

#pragma mark - Action-HeadPortrait
- (IBAction)changeAvatar:(id)sender {
    [self selectImagePickerSource:^(UIImagePickerControllerSourceType source) {
        [self showImagePickerForSourceType:source];
    }];
}

#pragma mark - UIImagePickerController
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    DCImagePickerController *imagePickerController = [[DCImagePickerController alloc] init];
    imagePickerController.cropMode = @(RSKImageCropModeCircle);
//    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;

    [self presentViewController:imagePickerController animated:YES completion:nil];
    
    typeof(self) __weak weakSelf = self;
    imagePickerController.completion = ^(UIImage *image, UIImage *originalImage) {

        // 1.resize
        CGSize newSize = CGSizeMake(256, 256);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // 2.Compress
        NSData *data = UIImageJPEGRepresentation(newImage, 1);
        data = UIImageJPEGRepresentation(newImage, 1000.0/[data length]);
        newImage = [UIImage imageWithData:data];
        
        // 3.and resize
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [newImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [weakSelf saveAvatarImage:newImage];
    };
}

#pragma mark - Request
- (void)saveAvatarImage:(UIImage *)avatarImage {    
    MBProgressHUD *hud = [self showHUDIndicator];
    hud.labelText = @"正在保存...";
    
    NSData *data = UIImageJPEGRepresentation(avatarImage, 1);
    [DCSiteApi postAvatar:data userId:self.user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
        } else {
            [self hideHUD:hud withText:@"保存成功"];
            
            DCUser *user = [[DCUser alloc] initWithDict:webResponse.result];
            user.token = [DCApp sharedApp].user.token;
            user.refreshToken = [DCApp sharedApp].user.refreshToken;
            [DCApp sharedApp].user = user;
            [DCDefault saveLoginedUser:user];
        }
        
        [self reloadUserInfo];
    }];
}

@end
