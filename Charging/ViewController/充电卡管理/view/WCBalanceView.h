//
//  WCBalanceView.h
//  aaa
//
//  Created by 钞王 on 2018/3/2.
//  Copyright © 2018年 钞王. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WCCardInputView;

@protocol WCBalanceViewDelegate <NSObject>

-(void)balanceViewClick;

@end

@interface WCBalanceView : UIView

@property (nonatomic, weak) id<WCBalanceViewDelegate>delegate;


@property (nonatomic, strong) WCCardInputView *inPutView;

@end
