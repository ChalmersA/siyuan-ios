//
//  HSSYTitleButton.m
//  Charging
//
//  Created by xpg on 15/4/2.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCTitleButton.h"

@implementation DCTitleButton

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.textLabel.highlighted = selected;
}

@end
