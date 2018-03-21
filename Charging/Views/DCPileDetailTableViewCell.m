//
//  DCPileDetailTableViewCell.m
//  Charging
//
//  Created by kufufu on 15/10/13.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCPileDetailTableViewCell.h"

@interface DCPileDetailTableViewCell ()
@property (strong, nonatomic) NSArray *imgArray;
@property (strong, nonatomic) NSArray *indexArray;
@end

@implementation DCPileDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imgArray = @[self.cpImageView4, self.cpImageView3, self.cpImageView2, self.cpImageView1];
    self.indexArray = @[self.cpIndexLabel4, self.cpIndexLabel3, self.cpIndexLabel2, self.cpIndexLabel1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cellWithChargePort:(NSArray *)array{
    for (int i = 0; i < array.count; i++) {
        UIImageView *imageView = self.imgArray[i];
        UILabel *label = self.indexArray[i];
        
        
//        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
//        NSArray *tempArray = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        DCChargePort *cp = array[i];
        
//        switch ([cp.index integerValue]) {
//            case 1:
        if (cp.index) {
            NSString *str = @"枪";
            label.text = [str stringByAppendingString:cp.index];
        }
//                break;
//            case 2:
//                label.text = @"枪2";
//                break;
//            case 3:
//                label.text = @"枪3";
//                break;
//            case 4:
//                label.text = @"枪4";
//                break;
//            default:
//                break;
//        }
        
        switch (cp.runStatus) {
            case DCRunStatusSpare: {
                imageView.image = [UIImage imageNamed:@"station_detail_spare"];
            }
                break;
                
            case DCRunStatusConnectNotCharge: {
                imageView.image = [UIImage imageNamed:@"station_detail_hold"];
            }
                break;
                
            case DCRunStatusCharging: {
                imageView.image = [UIImage imageNamed:@"station_detail_charging"];
            }
                break;
                
            case DCRunStatusBooking: {
                imageView.image = [UIImage imageNamed:@"station_detail_booked"];
            }
                break;
                
            default:
                imageView.image = [UIImage imageNamed:@"station_detail_fault"];
                break;
        }
    }
}
@end
