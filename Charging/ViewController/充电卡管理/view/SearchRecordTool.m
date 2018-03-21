//
//  SearchRecordTool.m
//  aaa
//
//  Created by gaoml on 2018/3/13.
//  Copyright © 2018年 钞王. All rights reserved.
//

#import "SearchRecordTool.h"

@implementation SearchRecordTool

+ (NSArray *)getAllRecords {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"searchRecord"];
}

+ (void)insertRecord:(NSString *)record {
    if (!record) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [defaults objectForKey:@"searchRecord"];
    if (arr) {
        if (arr.count < 20) {
            NSMutableArray *resultArr = [arr mutableCopy];
            __block BOOL has = NO;
            [arr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqualToString:record]) {
                    *stop = YES;
                    has = YES;
                }
            }];
            if (!has) {
                [resultArr insertObject:record atIndex:0];
                [defaults setObject:[resultArr copy] forKey:@"searchRecord"];
                [defaults synchronize];
            }
        }
    } else {
        NSMutableArray *resultArr = [NSMutableArray array];
        [resultArr addObject:record];
        [defaults setObject:[resultArr copy] forKey:@"searchRecord"];
        [defaults synchronize];
    }
}

+ (void)deleteRecord:(NSString *)record {
    if (!record) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [defaults objectForKey:@"searchRecord"];
    if (arr) {
        NSMutableArray *resultArr = [arr mutableCopy];
        [arr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:record]) {
                *stop = YES;
                [resultArr removeObject:obj];
                [defaults setObject:[resultArr copy] forKey:@"searchRecord"];
                [defaults synchronize];
            }
        }];
    }
}

+ (void)updateRecord:(NSString *)record withRecord:(NSString *)newRecord {
    if (!record) {
        return;
    }
    if (!newRecord) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [defaults objectForKey:@"searchRecord"];
    if (arr) {
        NSMutableArray *resultArr = [arr mutableCopy];
        [arr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:record]) {
                *stop = YES;
                [resultArr replaceObjectAtIndex:idx withObject:newRecord];
                [defaults setObject:[resultArr copy] forKey:@"searchRecord"];
                [defaults synchronize];
            }
        }];
    }
}

+ (void)clearRecords {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"searchRecord"];
    [defaults synchronize];
}

@end

