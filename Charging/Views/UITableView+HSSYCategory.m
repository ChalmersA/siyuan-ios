//
//  UITableView+HSSYCategory.m
//  Charging
//
//  Created by xpg on 15/1/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "UITableView+HSSYCategory.h"

@implementation UITableView (HSSYCategory)
- (ArrayDataSource *)arrayDataSource {
    if ([self.dataSource isKindOfClass:[ArrayDataSource class]]) {
        return self.dataSource;
    }
    return nil;
}
@end
