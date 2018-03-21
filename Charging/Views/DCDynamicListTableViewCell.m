//
//  DCDynamicListTableViewCell.m
//  Charging
//
//  Created by xpg on 15/9/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDynamicListTableViewCell.h"
#import "UIImageView+HSSYSDWebImageCategory.h"

@implementation DCDynamicListTableViewCell

- (void)awakeFromNib {
    // Initialization codeself.dynamicImageView
    self.dynamicImageView.backgroundColor = [UIColor clearColor];
    self.dynamicImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.dynamicImageView.clipsToBounds = YES;
    self.dynamicImageView.isLoad = @(NO);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureForDynamicDetailsList:(DCDynamicDetailsList *)dynamicDetailsList {

    self.dynamicTitleLabel.text = dynamicDetailsList.title;
    self.dynamicTextLabel.text = dynamicDetailsList.summary;
    self.dynamicTimeLabel.text = [[NSDateFormatter pileEvaluateDateFormatter] stringFromDate:dynamicDetailsList.updateTime];
    self.checkNumber.text = [NSString stringWithFormat:@"%ld",(long)dynamicDetailsList.viewCount];
    //当coverImg这个字段是一个完整的网址的时候
    if ([dynamicDetailsList.coverImg containsString:@"http:"]) {
        [self.dynamicImageView hssy_sd_setImageWithURL:[NSURL URLWithString:dynamicDetailsList.coverImg] placeholderImage:[UIImage imageNamed:@"default_pile_image_short"]];
    } else {
        [self.dynamicImageView hssy_sd_setImageWithURL:[NSURL URLWithString:[SERVER_URL stringByAppendingPathComponent:dynamicDetailsList.coverImg]] placeholderImage:[UIImage imageNamed:@"default_pile_image_short"]];
    }
}
@end
