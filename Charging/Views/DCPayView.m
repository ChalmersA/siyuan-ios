//
//  HSSYPayView.m
//  Charging
//
//  Created by xpg on 15/1/20.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPayView.h"

@interface DCPayView () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *passwordBox;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *number0;
@property (weak, nonatomic) IBOutlet UITextField *number1;
@property (weak, nonatomic) IBOutlet UITextField *number2;
@property (weak, nonatomic) IBOutlet UITextField *number3;
@property (weak, nonatomic) IBOutlet UITextField *number4;
@property (weak, nonatomic) IBOutlet UITextField *number5;
@property (strong, nonatomic) NSArray *numbers;
@end

@implementation DCPayView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    self.passwordBox.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.passwordBox.layer.borderWidth = 1;
    [self.passwordField becomeFirstResponder];
    self.numbers = @[self.number0, self.number1, self.number2, self.number3, self.number4, self.number5];
}

- (IBAction)dismissView:(id)sender {
    [self.passwordField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(payViewDidCancel:)]) {
        [self.delegate payViewDidCancel:self];
    }
}

- (IBAction)passwordChanged:(id)sender {
    self.password = self.passwordField.text;
    if ([self.password length] > [self.numbers count]) {
        return;
    }
    for (UITextField *textField in self.numbers) {
        NSInteger index = [self.numbers indexOfObject:textField];
        if (index < [self.password length]) {
            textField.text = [self.password substringWithRange:NSMakeRange(index, 1)];
        } else {
            textField.text = nil;
        }
    }
    if ([self.password length] == [self.numbers count]) {
        [self.passwordField resignFirstResponder];
        if ([self.delegate respondsToSelector:@selector(payView:didInputPassword:)]) {
            [self.delegate payView:self didInputPassword:self.password];
        }
    }
}

@end
