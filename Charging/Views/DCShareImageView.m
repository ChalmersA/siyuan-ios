//
//  DCShareImageView.m
//  Charging
//
//  Created by kufufu on 16/5/7.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCShareImageView.h"
#import "UIImageView+HSSYSDWebImageCategory.h"
#import "DCSiteApi.h"

@implementation DCShareImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = [UIScreen mainScreen].bounds;
    [self layoutIfNeeded];
}

- (instancetype)initShareImageViewWith:(UIImage *)mapImage station:(DCStation *)station withBlock:(void (^)(BOOL))block {
    DCShareImageView *view = [DCShareImageView loadViewWithNib:@"DCShareImageView"];
    view.mapImageView.image = mapImage;
    [view initStationView:station withBlock:block];
    return view;
}

- (void)initStationView:(DCStation *)station withBlock:(void (^)(BOOL success))block {
    
    [self.stationIconImageView hssy_sd_setImageWithURL:[NSURL URLWithImagePath:station.coverImageUrl] placeholderImage:[UIImage imageNamed:@"default_pile_image_short"]];
    
    self.stationNameLabel.text = station.stationName;
    if (station.stationType == DCStationTypePublic) {
        self.stationTypeLabel.text = @"公共桩群";
    } else if (station.stationType == DCStationTypeSpecial) {
        self.stationTypeLabel.text = @"专用桩群";
    } else {
        self.stationTypeLabel.text = @"其他";
    }
    
    self.starView.starRateView.scorePercent = station.commentAvgScore;
    
    self.stationAddressLabel.text = station.addr;
    [DCSiteApi getUpdateMessageWithCompletion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            block(NO);
            return;
        }
        
        NSDictionary *dict = webResponse.result;
        NSString *imageURL = [dict objectForKey:@"appQrcode"];
        if (imageURL) {
//            [self.qrCodeImageView hssy_sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"share_qrcode"]];
//            block(YES);
            [self.qrCodeImageView hssy_sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"share_qrcode"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                NSLog(@"#######识别二维码回掉########");
                if (error != nil) {
                    block(NO);
                    return;
                }
                block(YES);
            }];
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
