//
//  HSSYDynamicAtlasTableViewCell.h
//  Charging
//
//  Created by xpg on 15/9/16.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCTopic.h"
#import "DCDynamicDetailsList.h"

@protocol HSSYDynamicAtlasTableViewCellDelegate <NSObject> //定义Delegate
- (void)didClickImageView:(NSString *)string sourceType:(NSInteger)sourceType;
@end

@interface DCDynamicAtlasTableViewCell : UITableViewCell 

@property (weak, nonatomic) id<HSSYDynamicAtlasTableViewCellDelegate> delegate;//声明

@property(nonatomic,strong) DCTopic *topic;
@property (weak, nonatomic) IBOutlet UIPageControl *page;

@property (strong, nonatomic) IBOutlet UIView *dynamicImageView;

@property (strong, nonatomic) NSArray *imageArray;

@property (strong, nonatomic) DCDynamicDetailsList *dynamicAtlas;

-(void)configureFordynamicTop:(NSArray*)dynamicTop;
@end
