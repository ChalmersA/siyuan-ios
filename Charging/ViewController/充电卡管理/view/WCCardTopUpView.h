//
//  WCCardTopUpView.h
//  aaa
//
//  Created by 钞王 on 2018/3/1.
//  Copyright © 2018年 钞王. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WCCardTopUpViewDelegate <NSObject>

-(void)cardTopUpViewClickWithtitle1:(NSString *)title1 title2:(NSString *)title2 selectIndex:(int)selectIndex;

@end

@interface WCCardTopUpView : UIView

@property (nonatomic, weak) id<WCCardTopUpViewDelegate>delegate;

@end
