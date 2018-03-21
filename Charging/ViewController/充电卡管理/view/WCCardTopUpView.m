//
//  WCCardTopUpView.m
//  aaa
//
//  Created by 钞王 on 2018/3/1.
//  Copyright © 2018年 钞王. All rights reserved.
//

#import "WCCardTopUpView.h"
#import "WCCardInputView.h"

@interface WCCardTopUpView ()<UITextFieldDelegate>
{
    int selectIndex;
}

@property (nonatomic, strong) WCCardInputView *inputView1;

@property (nonatomic, strong) WCCardInputView *inputView2;

@property (nonatomic, strong) NSMutableArray *selectButtonA;

@property (nonatomic, strong) UIButton *sureButton;

@end

@implementation WCCardTopUpView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self buildView];
    return self;
}

-(void)buildView
{
    self.inputView1 = [[WCCardInputView alloc] initWithFrame:CGRectMake(0, 5, [UIScreen mainScreen].bounds.size.width, 50)];
    [self.inputView1.iconView setImage:[UIImage imageNamed:@"充值"]];
    [self.inputView1.textField setPlaceholder:@"请输入充值金额(元)"];
    [self.inputView1.textField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.inputView1.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self addSubview:self.inputView1];
    
    CGFloat inpoutView2Top = self.inputView1.frame.origin.y + self.inputView1.frame.size.height + 10;
    
    self.inputView2 = [[WCCardInputView alloc] initWithFrame:CGRectMake(0, inpoutView2Top, [UIScreen mainScreen].bounds.size.width, 50)];
    self.inputView2.textField.delegate = self;
    [self.inputView2.iconView setImage:[UIImage imageNamed:@"menu_icon_card"]];
    [self.inputView2.textField setPlaceholder:@"请输入要充值的充电卡卡号"];
    [self.inputView2.textField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.inputView2.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self addSubview:self.inputView2];
    
    CGFloat titleLableTop = self.inputView2.frame.size.height + self.inputView2.frame.origin.y + 20;
    CGFloat leftSpace = 20;
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, titleLableTop, [UIScreen mainScreen].bounds.size.width - leftSpace * 2, 20)];
    [titleLable setText:@"选择充值方式"];
    [titleLable setFont:[UIFont systemFontOfSize:14]];
    [self addSubview:titleLable];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(leftSpace, titleLable.frame.size.height + titleLableTop + 10, [UIScreen mainScreen].bounds.size.width - leftSpace * 2, 1)];
    [line setBackgroundColor:[UIColor paletteSeparateLineLightGrayColor]];
    [self addSubview:line];
    
    self.selectButtonA = [[NSMutableArray alloc] init];
    NSArray *titleA = @[@"支付宝",@"微信支付"];
    NSArray *imageA = @[@"Icon_Alipay",@"Icon_Wechat"];
    
    CGFloat selectCellH = 60;
    CGFloat sureButtonTop = 0;
    for (int i = 0 ; i < titleA.count ; i ++) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(leftSpace, line.frame.origin.y + line.frame.size.height + selectCellH * i, [UIScreen mainScreen].bounds.size.width - leftSpace * 2, selectCellH)];
        [view setBackgroundColor:[UIColor whiteColor]];
        
        [self addSubview:view];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 30, 30)];
        [imageView setImage:[UIImage imageNamed:imageA[i]]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [view addSubview:imageView];
        
        CGFloat imageViewRight = imageView.frame.origin.x + imageView.frame.size.width;
        
        UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(imageViewRight + 5, 0, 200, imageView.frame.size.height)];
        [titleL setTextAlignment:NSTextAlignmentLeft];
        [titleL setFont:[UIFont systemFontOfSize:14]];
        [titleL setText:titleA[i]];
        [view addSubview:titleL];
        
        [titleL setCenter:CGPointMake(titleL.center.x, imageView.center.y)];
        
        CGFloat selectButtonWH = selectCellH - 40;
        UIButton *selectButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width - selectButtonWH - leftSpace, 0, selectButtonWH, selectButtonWH)];
        [selectButton setImage:[UIImage imageNamed:@"wallet_not-choice"] forState:UIControlStateNormal];
        [selectButton setImage:[UIImage imageNamed:@"wallet_choice"] forState:UIControlStateSelected];
        selectButton.contentMode = UIViewContentModeScaleAspectFit;
        [selectButton setTag:i];
        [selectButton addTarget:self action:@selector(selectButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:selectButton];
        
        [selectButton setCenter:CGPointMake(selectButton.center.x, imageView.center.y)];
        
        [self.selectButtonA addObject:selectButton];
        sureButtonTop = view.frame.size.height + view.frame.origin.y;
        
        if (i == 0) {
            //默认选中
            selectButton.selected = YES;
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 1, [UIScreen mainScreen].bounds.size.width - 20 * 2, 1)];
        [line setBackgroundColor:[UIColor paletteSeparateLineLightGrayColor]];
        [view addSubview:line];
    }
    
    self.sureButton = [[UIButton alloc] initWithFrame:CGRectMake(leftSpace * 2, sureButtonTop + 20, [UIScreen mainScreen].bounds.size.width - leftSpace * 4, 40)];
    self.sureButton.layer.masksToBounds = YES;
    self.sureButton.layer.cornerRadius = 5;
    [self.sureButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.sureButton setBackgroundColor:[UIColor paletteDCMainColor]];
    [self.sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sureButton addTarget:self action:@selector(sureButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sureButton];
    
    
}

-(void)selectButtonClickAction:(UIButton *)sender
{
    for (int i = 0; i < self.selectButtonA.count; i ++) {
        UIButton *button = self.selectButtonA[i];
        if (i == (int)sender.tag) {
            button.selected = YES;
            [button setBackgroundImage:[UIImage imageNamed:@"wallet_not-choice"] forState:UIControlStateNormal];
        }else{
            button.selected = NO;
            [button setBackgroundImage:[UIImage imageNamed:@"wallet_choice"] forState:UIControlStateNormal];

        }
    }
    selectIndex = (int)sender.tag;
}

-(void)sureButtonClickAction:(UIButton *)sureButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardTopUpViewClickWithtitle1:title2:selectIndex:)]) {
        if (self.inputView2.textField.text.length == 14) {
            self.inputView2.textField.text = [self.inputView2.textField.text stringByAppendingString:@"00"];
        }
        [self.delegate cardTopUpViewClickWithtitle1:self.inputView1.textField.text title2:self.inputView2.textField.text selectIndex:selectIndex];
    }
}
//限制卡号位数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger limitLenght = textField.text.length - range.length + string.length;
    if (textField == self.inputView2.textField && limitLenght > 16) return NO;
    return YES;
}


@end
