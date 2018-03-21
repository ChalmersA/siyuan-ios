//
//  DCOrderDetailSectionHeader.h
//  Charging
//
//  Created by kufufu on 16/4/21.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCOrderDetailSectionHeader : UIView
@property (weak, nonatomic) IBOutlet UIImageView *sectionImageView;
@property (weak, nonatomic) IBOutlet UILabel *sectionTitleLabel;

+ (instancetype)loadView;
- (void)imageViewForTitle:(NSString *)title;
@end
