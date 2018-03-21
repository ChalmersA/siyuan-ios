//
//  HSSYAuthMember.m
//  Charging
//
//  Created by xpg on 15/1/12.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCAuthMember.h"
#import "NSDateFormatter+HSSYCategory.h"

@implementation DCAuthMember

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"createTime"]) {
        key = @"authTime";
        value = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
    }
    [super setValue:value forKey:key];
}

@end

@implementation DCAuthorizedUserTableViewCell (HSSYAuthMember)

- (void)configureForItem:(DCAuthMember *)item {
    self.userInfo = item;
    self.phoneLabel.text = item.phone;
    self.nameLabel.text = item.name;
    if (item.authTime) {
        NSString *timeString = [[NSDateFormatter authDateFormatter] stringFromDate:item.authTime];
        self.timeLabel.text = [NSString stringWithFormat:@"添加于 %@", timeString];
    }
}

@end
