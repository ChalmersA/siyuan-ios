//
//  ButtonBar.h
//  Charging
//
//  Created by Ben on 14/12/23.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+HSSYView.h"

@protocol ButtonBarDelegate <NSObject>
- (void)buttonBarClick:(NSInteger)tag;
@end

@interface ButtonBar : UIView
@property (weak, nonatomic) id <ButtonBarDelegate> delegate;
- (void)selectButtonIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setTagForItem:(NSArray *)tagArray;
@end


