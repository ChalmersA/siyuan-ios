//
//  HSSYRegistSuccessViewController.m
//  Charging
//
//  Created by Ben on 14/12/23.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCRegistSuccessViewController.h"

@interface DCRegistSuccessViewController ()
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@end

@implementation DCRegistSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.submitButton setCornerRadius:4];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.leftBarButtonItems = nil;
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

#pragma mark - Action
- (IBAction)registerFinish:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [DCApp sharedApp].rootTabBarController.selectedIndex = 0;
        [[DCApp sharedApp].rootTabBarController updateNavigationBar];
    }];
}

@end
