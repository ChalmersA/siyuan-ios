//
//  DCOrderDetailSectionHeader.m
//  Charging
//
//  Created by kufufu on 16/4/21.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCOrderDetailSectionHeader.h"

@implementation DCOrderDetailSectionHeader

+ (instancetype)loadView {
    DCOrderDetailSectionHeader *view = [DCOrderDetailSectionHeader loadViewWithNib:@"DCOrderDetailSectionHeader"];
    return view;
}

- (void)imageViewForTitle:(NSString *)title {
    if ([title isEqualToString:@"电桩信息"]) {
        self.sectionTitleLabel.text = @"电桩信息";
        self.sectionImageView.image = [UIImage imageNamed:@"order_detail_station"];
    }
    else if ([title isEqualToString:@"预约信息"]) {
        self.sectionTitleLabel.text = @"预约信息";
        self.sectionImageView.image = [UIImage imageNamed:@"order_detail_book"];
    }
    else if ([title isEqualToString:@"充电信息"]) {
        self.sectionTitleLabel.text = @"充电信息";
        self.sectionImageView.image = [UIImage imageNamed:@"order_detail_charge"];
    }
    else if ([title isEqualToString:@"付款信息"]) {
        self.sectionTitleLabel.text = @"付款信息";
        self.sectionImageView.image = [UIImage imageNamed:@"order_detail_pay"];
    }
    else if ([title isEqualToString:@"订单评价"]) {
        self.sectionTitleLabel.text = @"订单评价";
        self.sectionImageView.image = [UIImage imageNamed:@"order_detail_evaluation"];
    }
}

@end
