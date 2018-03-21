//
//  HSSYFieldItem.h
//  Charging
//
//  Created by xpg on 14/12/20.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCModel.h"
#import "DCFieldCell.h"

@interface DCFieldItem : DCModel
@property (copy, nonatomic) NSString *field;
@property (copy, nonatomic) NSString *content;
- (instancetype)initWithField:(NSString *)field content:(NSString *)content;
@end

@interface DCFieldCell (HSSYFieldItem)
- (void)configureForItem:(DCFieldItem *)item;
@end
