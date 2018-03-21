//
//  DCAccountManagementControll.m
//  Charging
//
//  Created by Pp on 15/12/29.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCAccountManagementControll.h"
#import "DCBaiduPayWebViewController.h"

@interface DCAccountManagementControll ()<HSSYBaiduPayWebViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bindingView;
@property (weak, nonatomic) IBOutlet UIButton *bingButton;
@property (weak, nonatomic) IBOutlet UITextField *alipyaAccountTF;
@property (weak, nonatomic) IBOutlet UITextField *alipayNameTF;
@property (weak, nonatomic) IBOutlet UITextField *alipayTF;

@end

@implementation DCAccountManagementControll

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.alipyaAccountTF.text = [DCApp sharedApp].user.alipayAccount;
    self.alipayNameTF.text = [DCApp sharedApp].user.alipayName;
    self.alipayTF.text = [DCApp sharedApp].user.alipay;
    
    self.alipayTF.delegate = self;
    self.alipayNameTF.delegate = self;
    self.alipyaAccountTF.delegate = self;
    
    [self getBaiduBindingStatus];
    
}

#pragma mark - getBaiduBindingStatus
- (void)getBaiduBindingStatus{
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [DCSiteApi getBaidubingWithUserId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [hub hide:YES];
            [self initView];
            return;
        }
        if ([(NSNumber*)webResponse.result boolValue]) {
            [DCApp sharedApp].user.contractFlag = DCUserContractFlagYES;
        }
        else {
            [DCApp sharedApp].user.contractFlag = DCUserContractFlagNO;
        }
        [DCDefault saveLoginedUser:[DCApp sharedApp].user];
        [hub hide:YES];
        [self initView];
    }];
}

#pragma mark - initView
- (void)initView{
    [self bindingStatus:[DCApp sharedApp].user.contractFlag == DCUserContractFlagYES ? YES : NO];
}

#pragma mark - bindingStatus
- (void)bindingStatus:(BOOL)isBinding{
    NSString *titleStr = isBinding ? @"解绑账号" : @"绑定账号";
    
    [self.bindingView setHidden:!isBinding];
    self.bingButton.backgroundColor = isBinding ? [UIColor paletteOrangeColor] : [UIColor paletteGreenColor];
    [self.bingButton setTitle:titleStr forState:UIControlStateNormal];
}

#pragma mark - bindingButtonClick
- (IBAction)bindingButtonClick:(id)sender {
    if ([DCApp sharedApp].user.contractFlag == DCUserContractFlagYES) {// 已绑定，走解绑
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否确定解绑？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        alert.tag = 0;
    }
    else{//未绑定，走绑定
        MBProgressHUD *hud = [self showHUDIndicator];
        [DCSiteApi getBaiduSignWithUserId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (![webResponse isSuccess]) {
                if (webResponse.message) {
                    hud.mode = MBProgressHUDModeText;
                    hud.detailsLabelFont = hud.labelFont;
                    hud.detailsLabelText = webResponse.message;
                    [hud hide:YES afterDelay:3];
                }
                else {
                    [self hideHUD:hud withText:@"获取绑定信息失败"];
                }
                return;
            }
            NSString *secret = [webResponse.result objectForKey:@"secret"];
            DCBaiduPayWebViewController *baiduPayVC = [[DCBaiduPayWebViewController alloc]init];
            baiduPayVC.baidupayUrl = [self getBaiduUrl:secret];
            baiduPayVC.myDelegate = self;
            [self.navigationController pushViewController:baiduPayVC animated:YES];
            [hud hide:YES];
        }];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0 && buttonIndex == 1) {
        MBProgressHUD *hud = [self showHUDIndicator];
        [DCSiteApi getCancleBindingWithUserId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (![webResponse isSuccess]) {
                if (webResponse.message) {
                    hud.mode = MBProgressHUDModeText;
                    hud.detailsLabelFont = hud.labelFont;
                    hud.detailsLabelText = webResponse.message;
                    [hud hide:YES afterDelay:3];
                }
                else {
                    [self hideHUD:hud withText:@"解绑失败"];
                }
                return;
            }
            [self hideHUD:hud withText:@"解绑成功"];
            
            [DCApp sharedApp].user.contractFlag = DCUserContractFlagNO;
            [DCDefault saveLoginedUser:[DCApp sharedApp].user];
            
            [self bindingStatus:NO];
        }];
    }
    else if (alertView.tag == 1 && buttonIndex == 1) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"正在保存...";
        
        DCUser *user = [[DCUser alloc] init];
        user.userId = [DCApp sharedApp].user.userId;
        user.alipayAccount = self.alipyaAccountTF.text;
        user.alipayName = self.alipayNameTF.text;
        user.alipay = self.alipayTF.text;
        
        [DCSiteApi postUpdateUserInfo:user completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (![webResponse isSuccess]) {
                [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            } else {
                [self hideHUD:hud withText:@"保存成功"];
                
                DCUser *user = [[DCUser alloc] initWithDict:webResponse.result];
                user.token = [DCApp sharedApp].user.token;
                user.refreshToken = [DCApp sharedApp].user.refreshToken;
                [DCApp sharedApp].user = user;
                [DCDefault saveLoginedUser:user];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

#pragma mark - HSSYBaiduPayWebViewDelegate
- (void)baiduPayBingingSuccessBack {
    [self showHUDText:@"绑定成功"];
    [self bindingStatus:YES];
}

- (void)baiduPayBingingFailureBack {
}


#pragma mark - 获取百度钱包绑定Url
- (NSString *)getBaiduUrl:(NSString *)secret
{
    NSString *BaiduPayUrl = @"https://www.baifubao.com/wap/0/contract_sign/0?";
    return [BaiduPayUrl stringByAppendingString:secret];
}

#pragma mark - rightButtonClick
- (IBAction)rightButtonClick:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否保存您的收支账号？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
    [alert show];
    alert.tag = 1;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
