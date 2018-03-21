//
//  UIActionSheet+HSSYCategory.m
//  Charging
//
//  Created by xpg on 15/4/21.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "UIActionSheet+HSSYCategory.h"
#import <objc/runtime.h>

@implementation UIActionSheet (HSSYCategory)

NSString * const UIActionSheetClickedButtonHandler = @"UIActionSheetClickedButtonHandler";
- (void)setClickedButtonHandler:(void(^)(NSString *buttonTitle))handler {
    self.delegate = self;
    objc_setAssociatedObject(self, (__bridge const void *)(UIActionSheetClickedButtonHandler), handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^handler)(NSString *) = objc_getAssociatedObject(self, (__bridge const void *)(UIActionSheetClickedButtonHandler));
    if (handler) {
        handler([self buttonTitleAtIndex:buttonIndex]);
    }
}

@end
