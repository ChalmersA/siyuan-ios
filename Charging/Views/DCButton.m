//
//  HSSYButton.m
//  Charging
//
//  Created by xpg on 14/12/12.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCButton.h"

@interface DCButton ()
@end

@implementation DCButton

- (void)awakeFromNib {
    [self traverseSubviewsWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[UIControl class]]) {
            UIControl *control = (UIControl *)view;
            control.userInteractionEnabled = NO;
        }
    }];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self traverseSubviewsWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.highlighted = highlighted;
        }
    }];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self traverseSubviewsWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.selected = selected;
        }
    }];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self traverseSubviewsWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.enabled = enabled;
        }
    }];
}

@end
