//
//  UIAlertView+HSSYCategory.m
//  Charging
//
//  Created by xpg on 15/1/13.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "UIAlertView+HSSYCategory.h"
#import <objc/runtime.h>

@implementation UIAlertView (HSSYCategory)

NSString * const UIAlertViewClickedButtonHandler = @"UIAlertViewClickedButtonHandler";
- (void)setClickedButtonHandler:(void(^)(NSInteger buttonIndex))handler {
    self.delegate = self;
    objc_setAssociatedObject(self, (__bridge const void *)(UIAlertViewClickedButtonHandler), handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^handler)(NSInteger) = objc_getAssociatedObject(self, (__bridge const void *)(UIAlertViewClickedButtonHandler));
    if (handler) {
        handler(buttonIndex);
    }
}

+ (UIAlertView *)showAlertMessage:(NSString *)message buttonTitles:(NSArray *)titles {
    return [self showAlertMessage:message title:nil buttonTitles:titles];
}

+ (UIAlertView *)showAlertMessage:(NSString *)message hideAfter:(NSTimeInterval)delay completion:(void(^)())completion {
    UIAlertView *alert = [self showAlertMessage:message buttonTitles:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        if (completion) {
            completion();
        }
    });
    return alert;
}

+ (UIAlertView *)showAlertMessage:(NSString *)message title:(NSString*)title buttonTitles:(NSArray *)titles {
    if (message.length == 0) {
        return nil;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    for (NSString *title in titles) {
        [alert addButtonWithTitle:title];
    }
    [alert show];
    return alert;
}

@end
