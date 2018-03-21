//
//  HSSYAuthorizedUserTableViewCell.m
//  Charging
//
//  Created by Ben on 14/12/26.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCAuthorizedUserTableViewCell.h"

@implementation DCAuthorizedUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deleteCell:)]) {
        [self.delegate deleteCell:self];
    }
}
@end
