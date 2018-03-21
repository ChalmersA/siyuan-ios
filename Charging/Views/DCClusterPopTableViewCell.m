//
//  HSSYClusterPopTableViewCell.m
//  Charging
//
//  Created by  Blade on 6/18/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCClusterPopTableViewCell.h"

@implementation DCClusterPopTableViewCell
+ (NSString *)identifierForItem:(id)item {
    if ([item isKindOfClass:[DCClusterPopTableViewCell class]]) {
        return @"DCClusterPopTableViewCell";
    }
    return nil;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
