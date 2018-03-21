//
//  HSSYShareDate.h
//  CollectionViewTest
//
//  Created by  Blade on 5/5/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCSharePeriod.h"

@interface DCShareDate : UICollectionViewCell
@property (retain, nonatomic) NSDate *dateOfShare;
@property (retain, nonatomic) NSMutableArray *sharePeriodObjArr;

- (instancetype)initWithDict:(NSDictionary*)dic;
- (NSString*) shareDateTimestampStr;
// 是否可以选择这一天
- (BOOL)canSelectThisDay;
// TODO: 根据nsdate 返回可选的shareperiod对象

@end
