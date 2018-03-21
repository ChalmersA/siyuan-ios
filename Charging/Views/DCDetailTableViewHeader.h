//
//  HSSYDetailTableViewHeader.h
//  Charging
//
//  Created by Pp on 15/10/13.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCDetailTableViewHeaderDelegate <NSObject>

- (void)touchedHeader;

@end

@interface DCDetailTableViewHeader : UIView

@property (weak, nonatomic) IBOutlet UIImageView *arrow;

@property (weak, nonatomic) IBOutlet UILabel *dcNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *acNumLabel;

@property (nonatomic, assign)id<DCDetailTableViewHeaderDelegate>myDelegate;

@end
