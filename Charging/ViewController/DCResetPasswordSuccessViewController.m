//
//  DCResetPasswordSuccessViewController.m
//  Charging
//
//  Created by kufufu on 16/2/29.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCResetPasswordSuccessViewController.h"

@interface DCResetPasswordSuccessViewController ()
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation DCResetPasswordSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:YES];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(backToLoginViewController:) userInfo:nil repeats:NO];
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backToLoginViewController:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
