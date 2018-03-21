//
//  HSSYViewController.m
//  Charging
//
//  Created by xpg on 14/12/9.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCViewController.h"

@implementation DCViewController

- (void)dealloc {
    DDLogVerbose(@"dealloc %@", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        //the navigation item ignores custom views in the back bar button anyway.
        if (!self.navigationItem.leftBarButtonItem) {
            self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarItemWithTarget:self action:@selector(navigateBack:)];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    DDLogVerbose(@"~~~~~~~ %@", [self class]);
//    [[HSSYApp sharedApp].rootViewController logChildrenWithPrefix:@"* "];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"lastViewController", nil]];
}

#pragma mark - StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation
- (void)navigateBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Theme
- (void)themeDidChange:(HSSYTheme)theme {
    switch (theme) {
        case HSSYThemeLight:
            self.view.backgroundColor = [UIColor whiteColor];
            break;
            
        default:
            self.view.backgroundColor = [UIColor blackColor];
            break;
    }
}

#pragma mark - UI Style
//注册页面的圆角主题色边框
- (void)drawBorderAndRoundCorner:(UIView *)view {
    [view setCornerRadius:3];
    view.layer.borderColor = [UIColor paletteDCMainColor].CGColor;
    view.layer.borderWidth = 0.5f;
}
@end
