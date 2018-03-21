//
//  WCBalanceView.m
//  aaa
//
//  Created by 钞王 on 2018/3/2.
//  Copyright © 2018年 钞王. All rights reserved.
//

#import "WCBalanceView.h"
#import "WCCardInputView.h"

@interface WCBalanceView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton *searchButton;

@end

@implementation WCBalanceView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self createView];
    return self;
}

-(void)createView
{
    [self addSubview:self.inPutView];
    [self addSubview:self.searchButton];
}

-(WCCardInputView *)inPutView
{
    if (_inPutView == nil) {
        _inPutView = [[WCCardInputView alloc] initWithFrame:CGRectMake(0, 10, [UIScreen mainScreen].bounds.size.width, 50)];
        _inPutView.textField.delegate = self;
        _inPutView.textField.placeholder = @"请输入查询卡的卡号";
        _inPutView.textField.keyboardType = UIKeyboardTypeNumberPad;
//        _inPutView.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _inPutView;
}

-(UIButton *)searchButton
{
    if (_searchButton == nil) {
        CGFloat buttonTop = self.inPutView.frame.size.height + self.inPutView.frame.origin.y + 10;
        CGFloat leftSpace = 20;
        _searchButton = [[UIButton alloc] initWithFrame:CGRectMake(leftSpace * 2, buttonTop + 20, [UIScreen mainScreen].bounds.size.width - leftSpace * 4, 40)];
        _searchButton.layer.masksToBounds = YES;
        _searchButton.layer.cornerRadius = 5;
        [_searchButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_searchButton setTitle:@"查询" forState:UIControlStateNormal];
        [_searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_searchButton setBackgroundColor:[UIColor paletteDCMainColor]];
        [_searchButton addTarget:self action:@selector(searchButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

-(void)searchButtonClickAction:(UIButton *)sender
{
    [self.delegate balanceViewClick];
}

//限制卡号位数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger limitLenght = textField.text.length - range.length + string.length;
    if (textField == self.inPutView.textField && limitLenght > 16) return NO;
    return YES;
}

@end
