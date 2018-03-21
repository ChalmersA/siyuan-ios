//
//  HSSYManagePoleCell.m
//  Charging
//
//  Created by xpg on 15/5/19.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCManagePoleCell.h"
#import "UIImageView+HSSYSDWebImageCategory.h"

@implementation DCManagePoleCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.poleImage.isLoad = @(NO);
    [self.poleImage setCornerRadius:4];
    [self.shareLabel setCornerRadius:CGRectGetMidY(self.shareLabel.bounds)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Pulbic
- (void)configForPole:(DCPole *)pole user:(NSString *)userId {
    self.pole = pole;
    
    [self.poleImage hssy_sd_setImageWithURL:[NSURL URLWithImagePath:pole.coverCropImg] placeholderImage:[UIImage imageNamed:@"default_pile_image_short"]];
    
    self.addressLabel.text = pole.location;
    self.nameLabel.text = pole.pileName;
    
    BOOL isShared = (pole.shareState == HSSYShareStateShared);
    self.shareLabel.backgroundColor = isShared?[UIColor digitalColorWithRed:40 green:181 blue:174]:[UIColor digitalColorWithRed:250 green:133 blue:59];
    self.shareTextLabel.text = isShared?@"已发布":@"未发布";
    
    BOOL isOwner = [userId isEqualToString:pole.userId];
    self.orderButton.enabled = isOwner;
    self.settingButton.enabled = isOwner;
}

#pragma mark - Action
- (IBAction)clickedButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cellDidClickedButton:withPole:)]) {
        [self.delegate cellDidClickedButton:sender.tag withPole:self.pole];
    }
}

@end
