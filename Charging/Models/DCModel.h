//
//  HSSYModel.h
//  Charging
//
//  Created by xpg on 14/12/17.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+Model.h"
#import "NSObject+Model.h"
#import "NSDate+HSSYDate.h"
#import "NSURL+HSSYImage.h"

@interface DCModel : NSObject
- (instancetype)initWithDict:(NSDictionary *)dict;
+ (NSArray *)loadArrayFromPlist:(NSString *)plist;
@end
