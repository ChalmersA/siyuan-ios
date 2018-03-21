//
//  WCTopTagView.m
//  aaa
//
//  Created by 钞王 on 2018/3/1.
//  Copyright © 2018年 钞王. All rights reserved.
//

#import "WCTopTagView.h"

@interface WCTopTagView ()

@property (nonatomic, strong) NSMutableArray *buttonA;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation WCTopTagView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self setBackgroundColor:[UIColor paletteDCMainColor]];
    
    return self;
}

-(NSMutableArray *)buttonA
{
    if (_buttonA == nil) {
        _buttonA = [[NSMutableArray alloc] init];
    }
    return _buttonA;
}

-(UIView *)lineView
{
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        [self addSubview:_lineView];
    }
    return _lineView;
}

-(void)updateViewWith:(NSArray *)titleA normalColor:(UIColor *)normalColr selectedColor:(UIColor *)selectedColor;
{
    self.buttonA = [[NSMutableArray alloc] init];
    CGFloat buttonW = [UIScreen mainScreen].bounds.size.width / titleA.count;
    for (int i = 0; i < titleA.count; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonW * i, 0, buttonW, self.frame.size.height)];
        [button setContentMode:UIViewContentModeCenter];
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [button setTitle:titleA[i] forState:UIControlStateNormal];
        [button setTitleColor:normalColr forState:UIControlStateNormal];
        [button setTitleColor:selectedColor forState:UIControlStateSelected];
        [button setBackgroundColor:self.backgroundColor];
        [button setTag:i];
        [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttonA addObject:button];
    }
    
    [self.lineView setBackgroundColor:selectedColor];
    [self.lineView setFrame:CGRectMake(0, 0, buttonW, 2)];
    [self.lineView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, self.frame.size.height - 2)];
    
}

-(void)buttonClickAction:(UIButton *)sender
{
    for (UIButton *button in self.buttonA) {
        if ([button isEqual:sender]) {
            button.selected = YES;
        }else{
            button.selected = NO;
        }
    }
    [self.lineView setCenter:CGPointMake(sender.center.x, self.lineView.center.y)];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(topTagViewClickAction:)]) {
        [self.delegate topTagViewClickAction:(int)sender.tag];
    }
}

-(void)updateViewWith:(int)index
{
    for (int i  = 0; i < self.buttonA.count; i ++) {
        UIButton *button = _buttonA[i];
        if (i == index) {
            button.selected = YES;
            [self.lineView setCenter:CGPointMake(button.center.x, self.lineView.center.y)];
        }else{
            button.selected = NO;
        }
    }
}



@end
