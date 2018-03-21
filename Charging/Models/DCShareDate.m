//
//  HSSYShareDate.m
//  CollectionViewTest
//
//  Created by  Blade on 5/5/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import "DCShareDate.h"

@implementation DCShareDate

- (instancetype)initWithDict:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        double timeStamp = [(NSNumber*)[dic objectForKey:@"date"] doubleValue];
        self.dateOfShare = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000];
        self.sharePeriodObjArr = [NSMutableArray array];
        NSArray *sharePeriodOriArr = [dic objectForKey:@"data"];
        for (NSDictionary *splitedPeriodDic in sharePeriodOriArr) {
            DCSharePeriod* shareperiod = [[DCSharePeriod alloc] initWithDict:splitedPeriodDic dateOfShareDay:self.dateOfShare];
            [self.sharePeriodObjArr addObject:shareperiod];
        }
        
        [self.sharePeriodObjArr sortUsingComparator:^NSComparisonResult(DCSharePeriod* period1, DCSharePeriod* period2) {
            return [period1.timeShareStart compare:period2.timeShareStart];
        }];
    }
    return self;
}

- (NSString*) shareDateTimestampStr {
    NSString* retStr = @"";
    if (self.dateOfShare) {
        retStr = [NSString stringWithFormat:@"%.0f", [self.dateOfShare timeIntervalSince1970] *1000];
    }
    return retStr;
}

- (BOOL)canSelectThisDay {
    BOOL canSelect = NO;
    for (DCSharePeriod *sharePeriod in self.sharePeriodObjArr) {
        if ([sharePeriod canSelectThisPeriod]) {
            canSelect = YES;
            break;
        };
    }
    return canSelect;
}
@end
