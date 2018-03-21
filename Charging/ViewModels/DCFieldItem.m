//
//  HSSYFieldItem.m
//  Charging
//
//  Created by xpg on 14/12/20.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCFieldItem.h"

@implementation DCFieldItem

- (instancetype)initWithField:(NSString *)field content:(NSString *)content {
    self = [super init];
    if (self) {
        self.field = field;
        self.content = content;
    }
    return self;
}

@end

@implementation DCFieldCell (HSSYFieldItem)

- (void)configureForItem:(DCFieldItem *)item {
    self.fieldLabel.text = item.field;
    self.contentLabel.text = item.content;
}

@end
