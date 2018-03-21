//
//  DCUIImageVIew.h
//  Charging
//
//  Created by  Blade on 11/30/15.
//  Copyright © 2015 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface DCUIImageVIew : UIImageView
- (void)setUpAnimate:(CAAnimation*)animation withKey:(NSString*)key;

- (void)startAnimate;

- (void)stopAnimate;
@end
