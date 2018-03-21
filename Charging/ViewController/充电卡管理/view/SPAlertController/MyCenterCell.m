//
//  MyCenterCell.m
//  Charging
//
//  Created by gaoml on 2018/3/13.
//  Copyright © 2018年 xpg. All rights reserved.
//

#import "MyCenterCell.h"

@implementation MyCenterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.cardLabel = [[UILabel alloc] init];
        self.cardLabel.text = @"";
        self.cardLabel.textColor = [UIColor grayColor];
        self.cardLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.cardLabel];
        
        self.deletedBtn = [[UIButton alloc] init];
        [self.deletedBtn setImage:[UIImage imageNamed:@"关闭"] forState:UIControlStateNormal];
//        [self.deletedBtn setBackgroundColor:[UIColor redColor]];
        [self.deletedBtn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.deletedBtn];
    }

    return self;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.cardLabel.frame = CGRectMake(20, 0, self.frame.size.width - 70, 50);
    self.deletedBtn.frame = CGRectMake(self.frame.size.width - 15 - 30, 10, 30, 30);
}

- (void)click {
    
    if (self.clickDeletedBtnBlock) {
        self.clickDeletedBtnBlock();
    }
}



@end
