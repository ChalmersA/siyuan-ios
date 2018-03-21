//
//  DCBindChargeCardViewController.m
//  Charging
//
//  Created by kufufu on 16/5/10.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCBindChargeCardViewController.h"
#import "DCSiteApi.h"

@interface DCBindChargeCardViewController ()
@property (weak, nonatomic) IBOutlet UITextField *cardTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation DCBindChargeCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tipLabel.text = @"注意：被绑定的账号必须与办卡时预留的手机号一致，否则绑定不成功。\n绑定成功后，您将可以通过“易卫充”APP获得电卡的余额、电卡状态、充电记录及电卡启动后的充电情况。";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)bindCardButton:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (_cardTextField.text.length <= 0) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入正确的充电卡号";
        [hud hide:YES afterDelay:2];
        return;
    }
    
    [DCSiteApi postBindChargeCardWithCardId:self.cardTextField.text userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withDetailsText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        
        [self hideHUD:hud withDetailsText:@"充电卡绑定成功" completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.cardTextField resignFirstResponder];
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
