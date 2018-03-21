//
//  City.m
//  Charging
//
//  Created by xpg on 14/12/29.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "City.h"

@interface City ()
@property (nonatomic, readwrite) NSString *pinyin;
@end

@implementation City

- (instancetype)initWithCityId:(NSString *)cityId name:(NSString *)name {
    self = [super init];
    if (self) {
        _cityId = [cityId copy];
        _name = [name copy];
    }
    return self;
}

- (NSString *)pinyin {
    if (_pinyin == nil) {
        _pinyin = [self.name pinyin];
    }
    return _pinyin;
}

#pragma mark - Equal
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[City class]]) {
        City *city = object;
        return [self.cityId isEqualToString:city.cityId];
    }
    return NO;
}

- (NSUInteger)hash {
    return self.cityId.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.cityId, self.name];
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cityId forKey:@"cityid"];
    [aCoder encodeObject:self.name forKey:@"cityname"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _cityId = [aDecoder decodeObjectForKey:@"cityid"];
        _name = [aDecoder decodeObjectForKey:@"cityname"];
    }
    return self;
}

@end
