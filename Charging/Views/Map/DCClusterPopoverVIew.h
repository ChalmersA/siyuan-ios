//
//  DCClusterPopoverVIew.h
//  Charging
//
//  Created by  Blade on 6/18/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCStation.h"

typedef void(^ClusterItemSelctedBlcok)(id item);
@interface DCClusterPopoverVIew : UIView
@property (copy, nonatomic) ClusterItemSelctedBlcok itemSelectedBlock;
@property (nonatomic, retain) NSArray* pileArr;

-(instancetype)initWithPoles:(NSArray*)poles andFrame:(CGRect)frame itemSelectBlock:(ClusterItemSelctedBlcok)block;
- (DCStation*)selectStation:(DCStation*)station;
- (CGFloat)adjustViewMaxHeight:(CGFloat)height;
@end
