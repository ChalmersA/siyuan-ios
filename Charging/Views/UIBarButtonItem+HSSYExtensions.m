//
//  UIBarButtonItem+HSSYExtensions.m
//  Charging
//
//  Created by xpg on 14/12/18.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "UIBarButtonItem+HSSYExtensions.h"
#import "DCButton.h"

@implementation UIBarButtonItem (HSSYExtensions)

- (UIButton *)customViewButton {
    if ([self.customView isKindOfClass:[UIButton class]]) {
        return (UIButton *)self.customView;
    }
    return nil;
}

- (void)setSelected:(BOOL)selected {
    [self customViewButton].selected = selected;
}

- (BOOL)selected {
    return [self customViewButton].selected;
}

//+ (instancetype)logoBarItem {
//    UIImage *logo = [UIImage imageNamed:@"bar_logo"];
//    UIImageView *logoImage = [[UIImageView alloc] initWithImage:logo];
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:logoImage];
//    return item;
//}

+ (instancetype)backBarItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
}

+ (instancetype)buttonBarItemWithTarget:(id)target action:(SEL)action icon:(UIImage *)icon {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [button setImage:icon forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}

+ (instancetype)buttonBarItemWithTarget:(id)target action:(SEL)action {
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:barButton];
    return item;
}

+ (instancetype)backBarItemWithTarget:(id)target action:(SEL)action {
    UIBarButtonItem *item = [self buttonBarItemWithTarget:target action:action];
    [item customViewButton].frame = CGRectMake(0, 0, 22, 22);
    [[item customViewButton] setImage:[UIImage imageNamed:@"bar_back_button"] forState:UIControlStateNormal];
    return item;
}

+ (instancetype)menuBarItemWithTarget:(id)target action:(SEL)action {
    UIBarButtonItem *item = [self buttonBarItemWithTarget:target action:action];
    [item customViewButton].frame = CGRectMake(0, 0, 22, 22);
    [[item customViewButton] setImage:[UIImage imageNamed:@"menu_bar_button"] forState:UIControlStateNormal];
    return item;
}

+ (instancetype)bluetoothBarItemWithTarget:(id)target action:(SEL)action {
    UIBarButtonItem *item = [self buttonBarItemWithTarget:target action:action];
    [item customViewButton].frame = CGRectMake(0, 0, 22, 22);
    [[item customViewButton] setImage:[UIImage imageNamed:@"bluetooth_not_connected"] forState:UIControlStateNormal];
    [[item customViewButton] setImage:[UIImage imageNamed:@"bluetooth_connected"] forState:UIControlStateSelected];
    [item customViewButton].userInteractionEnabled = NO;
    return item;
}

+ (instancetype)alarmBarItemWithTarget:(id)target action:(SEL)action {
    UIBarButtonItem *item = [self buttonBarItemWithTarget:target action:action];
    [item customViewButton].frame = CGRectMake(0, 0, 22, 22);
    [[item customViewButton] setImage:[UIImage imageNamed:@"icon_time"] forState:UIControlStateNormal];
    [[item customViewButton] setImage:[UIImage imageNamed:@"icon_time"] forState:UIControlStateSelected];
    return item;
}

+ (instancetype)searchBarItemWithTarget:(id)target action:(SEL)action {
    DCButton *barButton = [DCButton buttonWithType:UIButtonTypeCustom];
    [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:barButton];
    [item customViewButton].frame = CGRectMake(0, 0, 36, 28);
    UIButton *subButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, 28, 28)];
    [subButton setImage:[UIImage imageNamed:@"search_button_map"] forState:UIControlStateNormal];
    [subButton setImage:[UIImage imageNamed:@"search_button_list"] forState:UIControlStateSelected];
    subButton.userInteractionEnabled = NO;
    [[item customViewButton] addSubview:subButton];
    return item;
}

// 收藏按钮
+ (instancetype)favoBarItemWithTarget:(id)target action:(SEL)action {
    UIBarButtonItem *item = [self buttonBarItemWithTarget:target action:action];
    [item customViewButton].frame = CGRectMake(0, 0, 22, 22);
    [[item customViewButton] setImage:[UIImage imageNamed:@"find_collect03"] forState:UIControlStateNormal];
    [[item customViewButton] setImage:[UIImage imageNamed:@"collect_icon_on"] forState:UIControlStateSelected];
    return item;
}
//分享按钮
+ (instancetype)shareBarItemWithTarget:(id)target action:(SEL)action {
    UIBarButtonItem *item = [self buttonBarItemWithTarget:target action:action];
    [item customViewButton].frame = CGRectMake(0, 0, 22, 22);
    [[item customViewButton] setImage:[UIImage imageNamed:@"search_share"] forState:UIControlStateNormal];
    [[item customViewButton] setImage:[UIImage imageNamed:@"search_share"] forState:UIControlStateSelected];
    return item;
}

@end
