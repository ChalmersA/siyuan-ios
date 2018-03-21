//
//  HSSYPayWayModel.h
//  Charging
//
//  Created by Pp on 15/12/14.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCPayWayModel : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, assign) BOOL chosen;

+ (instancetype)payWayWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
