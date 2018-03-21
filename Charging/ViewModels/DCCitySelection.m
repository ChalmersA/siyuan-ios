//
//  HSSYCitySelection.m
//  Charging
//
//  Created by xpg on 14/12/29.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCCitySelection.h"
#import "DCDefault.h"

@implementation DCCitySelection

+ (instancetype)defaultSelection {
    DCCitySelection *selection = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archiverPath]];
    if (selection == nil) {
        selection = [[self alloc] init];
    }
    return selection;
}

+ (NSArray *)popularCityIds {
    return @[@"110000", @"310000", @"440100", @"440300", @"420100", @"120000", @"610100", @"320100", @"330100", @"510100", @"500001"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSDate *startTime = [NSDate date];
        NSArray *allCities = [self rawCityDataFromFile];
        
        NSArray *popularCityIds = [DCCitySelection popularCityIds];
        NSMutableDictionary *popularCityDict = [NSMutableDictionary dictionary];
        
        NSMutableArray *cities = [NSMutableArray array];
        for (NSString *cityString in allCities) {
            NSArray *cityValues = [cityString componentsSeparatedByString:@","];
            if (cityValues.count >= 2) {
                NSString *cityId = cityValues[0];
                City *city = [[City alloc] initWithCityId:cityId name:cityValues[1]];
                [cities addObject:city];
                
                if ([popularCityIds containsObject:cityId]) {
                    popularCityDict[cityId] = city;
                }
            }
        }
        _cities = [cities copy];
        
        // popular cities
        NSMutableArray *popularCities = [NSMutableArray array];
        for (NSString *cityId in popularCityIds) {
            City *city = popularCityDict[cityId];
            if (city) {
                [popularCities addObject:city];
            }
        }
        _popularCities = [popularCities copy];
        
        // archive
        [NSKeyedArchiver archiveRootObject:self toFile:[DCCitySelection archiverPath]];
        
        DDLogDebug(@"load city list use %.1fs", [[NSDate date] timeIntervalSinceDate:startTime]);
    }
    return self;
}

- (void)initCitySelectionCompletion:(dispatch_block_t)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDate *startTime = [NSDate date];
        NSArray *allCities = [self rawCityDataFromFile];
        
        NSMutableArray *cities = [NSMutableArray array];
        NSMutableDictionary *cityDict = [NSMutableDictionary dictionary];
        
        NSArray *popularCityIds = [DCCitySelection popularCityIds];
        NSMutableDictionary *popularCityDict = [NSMutableDictionary dictionary];
        
        for (NSString *cityString in allCities) {
            NSArray *cityValues = [cityString componentsSeparatedByString:@","];
            if (cityValues.count >= 2) {
                NSString *cityId = cityValues[0];
                City *city = [[City alloc] initWithCityId:cityId name:cityValues[1]];
                [cities addObject:city];
                
                if ([popularCityIds containsObject:cityId]) {
                    popularCityDict[cityId] = city;
                }
                
                NSString *key = (city.pinyin.length > 0)? [city.pinyin substringToIndex:1].uppercaseString: @"";
                NSArray *cityArray = [NSArray arrayWithArray:cityDict[key]];
                cityArray = [cityArray arrayByAddingObject:city];
                [cityDict setObject:cityArray forKey:key];
            }
        }
        self.cities = [cities copy];
        self.cityDict = [cityDict copy];
        self.cityDictKeys = [self.cityDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:(NSCaseInsensitiveSearch)];
        }];
        
        // popular cities
        NSMutableArray *popularCities = [NSMutableArray array];
        for (NSString *cityId in popularCityIds) {
            City *city = popularCityDict[cityId];
            if (city) {
                [popularCities addObject:city];
            }
        }
        self.popularCities = [popularCities copy];
        
        // archive
        [NSKeyedArchiver archiveRootObject:self toFile:[DCCitySelection archiverPath]];
        
        DDLogDebug(@"load city dict use %.1fs", [[NSDate date] timeIntervalSinceDate:startTime]);
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    });
}

- (BOOL)isCityDictLoaded {
    return (self.cityDict.allKeys.count > 0);
}

- (NSArray *)rawCityDataFromFile {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"csv"];
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *allCities = [fileContents componentsSeparatedByString:@"\n"];
    return allCities;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cities forKey:@"cities"];
    [aCoder encodeObject:self.cityDict forKey:@"cityDict"];
    [aCoder encodeObject:self.cityDictKeys forKey:@"cityDictKeys"];
    [aCoder encodeObject:self.popularCities forKey:@"popularCities"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _cities = [coder decodeObjectForKey:@"cities"];
        _cityDict = [coder decodeObjectForKey:@"cityDict"];
        _cityDictKeys = [coder decodeObjectForKey:@"cityDictKeys"];
        _popularCities = [coder decodeObjectForKey:@"popularCities"];
    }
    return self;
}

#pragma mark - Archiver
+ (NSString *)archiverPath {
    NSURL *documentURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *cityListFilePath = [documentURL URLByAppendingPathComponent:@"citySelection"].path;
    return cityListFilePath;
}

@end
