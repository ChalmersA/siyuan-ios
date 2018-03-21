//
//  PopUpView.m
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "PopUpView.h"
#import "DCApp.h"

@interface PopUpView ()
@property (strong, nonatomic) UIControl *backgroundView;
@property (strong, nonatomic) UIView *contentView;
@end

@implementation PopUpView

- (instancetype)initWithContentView:(UIView *)contentView {
    self = [super initWithFrame:[DCApp appDelegate].window.bounds];
    if (self) {
        _backgroundView = [[UIControl alloc] initWithFrame:CGRectZero];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _backgroundView.userInteractionEnabled = NO;
        [self addSubview:_backgroundView];
        _backgroundDismissEnable = YES;
        [_backgroundView addTarget:self action:@selector(tappedBackground:) forControlEvents:UIControlEventTouchDown];
        
        _contentView = contentView;
        [self addSubview:_contentView];
    }
    return self;
}

- (void)popUp {
    [[DCApp appDelegate].window addSubview:self];
    _contentView.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _backgroundView.userInteractionEnabled = YES;
    }];
}

- (void)dismiss {
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(popUpViewDidDismiss:)]) {
        [self.delegate popUpViewDidDismiss:self];
    }
}

+ (instancetype)popUpWithContentView:(UIView *)contentView {
    return [self popUpWithContentView:contentView withController:nil];
}

+ (instancetype)popUpWithContentView:(UIView *)contentView withController:(id<PopUpViewDelegate>)controller{
    PopUpView *view = [[self alloc] initWithContentView:contentView];
    [view popUp];
    view.delegate = controller;
    return view;
}

#pragma mark -
- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.frame = self.bounds;
    self.contentView.center = CGPointMake(CGRectGetMidX(self.bounds) + _contentOffset.x, CGRectGetMidY(self.bounds) + _contentOffset.y);
}

#pragma mark - Action
- (void)tappedBackground:(id)sender {
    if (self.backgroundDismissEnable) {
        [self dismiss];
    }
}

- (void)popUpViewDismissAction {
    [self dismiss];
}

@end
