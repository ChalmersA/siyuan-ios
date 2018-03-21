//
//  DCTwoButtonView.h
//  Charging
//
//  Created by kufufu on 16/5/20.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, DCTwoButtonType) {
    DCTwoButtonTypeCancelOrder,
    DCTwoButtonTypeLogin
};

@protocol DCTwoButtonViewDelegate <NSObject>

- (void)clickTheForgetButton;
- (void)clickTheReturnButton;

@end

@interface DCTwoButtonView : UIView
@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) id <DCTwoButtonViewDelegate> delegate;

+ (instancetype)loadTwoButtonViewWithType:(DCTwoButtonType)type;

@end
