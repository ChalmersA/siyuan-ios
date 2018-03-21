//
//  DCPopupView.m
//  Charging
//
//  Created by kufufu on 16/4/5.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCPopupView.h"
#import "DCApp.h"

@implementation DCPopupView

+ (instancetype)popUpWithTitle:(NSString *)title contentView:(UIView *)contentView {
    return [self popUpWithTitle:title contentView:contentView withController:nil];
}

+ (instancetype)popUpWithTitle:(NSString *)title contentView:(UIView *)contentView withController:(id<DCPopupViewDelegate>)controller {
    DCPopupView *view = [DCPopupView loadViewWithNib:@"DCPopupView"];
    view.titleLabel.text = title;
    [view popUp:contentView];
    view.delegate = controller;
    return view;
}

- (void)popUp:(UIView *)contentView {
    self.frame = [DCApp appDelegate].window.bounds;
    [[DCApp appDelegate].window addSubview:self];
    
    _backgroundDismissEnable = YES;

    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackground:)];
    [self.backgroundView addGestureRecognizer:touch];
    
    //算出添加进来的contentView的高度
    CGSize size = [contentView systemLayoutSizeFittingSize:contentView.frame.size];
    _realityHeight = size.height;
    //把xib中replaceView的宽度记录下来
    _realityWidth = self.replaceView.frame.size.width;
    //把宽度赋给contentView
    size.width = _realityWidth;
    CGRect contentViewFrame = contentView.frame;
    contentViewFrame.size = size;
    contentView.frame = contentViewFrame;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.replaceView addSubview:contentView];
    [self.replaceView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:@{@"contentView":contentView}]];
    [self.replaceView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:@{@"contentView":contentView}]];
    
    //self.contentView的高度约束
    self.height.constant = _realityHeight + 40;
    
    _contentView.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _backgroundView.userInteractionEnabled = YES;
    }];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //TODO: 因为contentView是外面传进来add在self.replaceView里面的, 它们之间没有约束所以修改frame没影响, 不过最好还是写在autolayout上用NSLayoutConstraint代码写出来
//    UIView *contentView = self.replaceView.subviews.firstObject;
//    contentView.frame = self.replaceView.bounds;
//    NSLog(@"layoutsubviews %@", NSStringFromCGRect(contentView.frame));
}

#pragma mark - Action
- (void)tappedBackground:(id)sender {
    if (self.backgroundDismissEnable) {
        [self cancel:sender];
    } else {
        /*
         *  FOR textField resignFirstResponse
         */
        if ([self.delegate respondsToSelector:@selector(clickForResignFirstResponse)]) {
            [self.delegate clickForResignFirstResponse];
        }
    }
}
- (IBAction)cancel:(id)sender {
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(popUpViewDismiss:)]) {
        [self.delegate popUpViewDismiss:self];
    }
}

@end
