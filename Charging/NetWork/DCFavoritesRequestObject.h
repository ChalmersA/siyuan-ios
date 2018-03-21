//
//  HSSYFavoritesRequestObject.h
//  Charging
//
//  Created by chenshuxian on 15/5/25.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

//favor 1：收藏 ；2：取消收藏
typedef NS_ENUM(NSInteger, HSSYFavorState) {
    HSSYFavorStateFavor = 1,
    HSSYFavorStateNotFavor = 2,
};

@interface DCFavoritesRequestObject : NSObject
@property (copy, nonatomic) NSString *pileId;
@property (copy, nonatomic) NSString *userid;
@property (assign, nonatomic) HSSYFavorState favor;
+ (NSDictionary *)jsonObjectWithArray:(NSArray *)array;
@end
