//
//  DCChargingAnimationView.h
//  Charging
//
//  Created by kufufu on 16/4/15.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCChargingCurrentData.h"

@protocol DCChargingAnimationViewDeletage <NSObject>

@end

@interface DCChargingAnimationView : UIView

@property (weak, nonatomic) id <DCChargingAnimationViewDeletage> delegate;

- (void)startAnimation;
- (void)stopAnimation;
@end
