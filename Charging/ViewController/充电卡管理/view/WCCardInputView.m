//
//  WCCardInputView.m
//  aaa
//
//  Created by 钞王 on 2018/3/1.
//  Copyright © 2018年 钞王. All rights reserved.
//

#import "WCCardInputView.h"

@interface WCCardInputView ()



@end

@implementation WCCardInputView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self buildView];
    [self setBackgroundColor:[UIColor paletteSeparateLineLightGrayColor]];
    return self;
}

-(void)buildView
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
    [_iconView setImage:[UIImage imageNamed:@"menu_icon_card"]];
    [backView addSubview:_iconView];
   
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, [UIScreen mainScreen].bounds.size.width, 30)];
    _textField.leftView = backView;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.font = [UIFont systemFontOfSize:15];
//    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addSubview:_textField];
}



@end
