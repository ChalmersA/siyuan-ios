//
//  WCTopTagView.h
//  aaa
//
//  Created by 钞王 on 2018/3/1.
//  Copyright © 2018年 钞王. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WCTopTagViewDelegate <NSObject>

-(void)topTagViewClickAction:(int)tag;

@end

@interface WCTopTagView : UIView

@property (nonatomic, weak) id<WCTopTagViewDelegate>delegate;

-(void)updateViewWith:(NSArray *)titleA normalColor:(UIColor *)normalColr selectedColor:(UIColor *)selectedColor;

-(void)updateViewWith:(int)index;

@end
