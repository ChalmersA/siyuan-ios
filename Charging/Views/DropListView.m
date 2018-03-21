//
//  DropListView.m
//  Charging
//
//  Created by xpg on 15/4/1.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DropListView.h"
#import "UIView+HSSYView.h"
#import "DCApp.h"

@interface DropListView ()
@property (strong, nonatomic) UIControl *backgroundView;
@property (strong, nonatomic) UIView *listView;
@property (copy, nonatomic) void (^dismissAnimation)(void);
@end

@implementation DropListView

- (instancetype)initWithListView:(UIView *)listView {
    self = [super initWithFrame:[DCApp appDelegate].window.bounds];
    if (self) {
        _backgroundView = [[UIControl alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        _backgroundView.userInteractionEnabled = NO;
        [self addSubview:_backgroundView];
        [_backgroundView addTarget:self action:@selector(tappedBackground:) forControlEvents:UIControlEventTouchDown];
        
        _listView = listView;
        [self addSubview:listView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentingLoginView) name:NOTIFICATION_USER_LOGINVIEW_WILL_SHOW object:nil];
    }
    return self;
}

- (void)dropListAtPoint:(CGPoint)point {
    self.backgroundView.backgroundColor = [UIColor clearColor];
    
    UIWindow *window = [DCApp appDelegate].window;
    self.frame = window.bounds;
    CGFloat contentHeight = self.listView.intrinsicContentSize.height;
    self.listView.frame = CGRectMake(point.x, point.y, CGRectGetWidth(self.bounds) - point.x, 0);
    [window addSubview:self];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.listView.frameHeight = contentHeight;
    } completion:^(BOOL finished) {
        self.backgroundView.userInteractionEnabled = YES;
    }];
    
    typeof(self) __weak weakSelf = self;
    [self setDismissAnimation:^{
        weakSelf.listView.frameHeight = 0;
    }];
}

- (void)dropListAlignRightOnView:(UIView *)view topSpace:(CGFloat)topSpace {
    self.backgroundView.alpha = 0;
    
    CGFloat width = self.listView.intrinsicContentSize.width;
    CGFloat height = self.listView.intrinsicContentSize.height;
    self.listView.frame = CGRectMake(CGRectGetWidth(self.bounds) - width, -height + topSpace, width, height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.listView.frame;
        frame.origin.y += frame.size.height;
        self.listView.frame = frame;
        self.backgroundView.alpha = 0.618;
    } completion:^(BOOL finished) {
        self.backgroundView.userInteractionEnabled = YES;
    }];

    typeof(self) __weak weakSelf = self;
    [self setDismissAnimation:^{
        CGRect frame = weakSelf.listView.frame;
        frame.origin.y -= frame.size.height;
        weakSelf.listView.frame = frame;
        weakSelf.backgroundView.alpha = 0;
    }];
}

- (void)presentingLoginView {
    [self dismissWithDuration:0];
}

- (void)dismiss {
    [self dismissWithDuration:0.3];
}
- (void)dismissWithDuration:(float)duration {
    self.backgroundView.userInteractionEnabled = NO;
    if (self.willDismiss) {
        self.willDismiss(self);
    }
    
    if (self.dismissAnimation) {
        [UIView animateWithDuration:duration animations:^{
            self.dismissAnimation();
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
}

#pragma mark - Action
- (void)tappedBackground:(id)sender {
    [self dismiss];
}

@end
