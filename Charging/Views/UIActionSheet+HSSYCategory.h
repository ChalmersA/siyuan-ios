//
//  UIActionSheet+HSSYCategory.h
//  Charging
//
//  Created by xpg on 15/4/21.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (HSSYCategory) <UIActionSheetDelegate>
- (void)setClickedButtonHandler:(void(^)(NSString *buttonTitle))handler;
@end
