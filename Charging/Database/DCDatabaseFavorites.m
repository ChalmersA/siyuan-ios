//
//  HSSYDatabaseFavorites.m
//  Charging
//
//  Created by xpg on 15/1/28.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDatabaseFavorites.h"
#import "DCDatabase.h"

//"user_id INT NULL,"
//"pole_no CHAR(8) NULL,"
//"collection_state INT NULL);

@implementation DCDatabaseFavorites

+ (instancetype)favorWithResultSet:(FMResultSet *)resultSet {
    DCDatabaseFavorites *favor = [[self alloc] init];
    [favor updateWithResultSet:resultSet];
    return favor;
}

- (void)updateWithResultSet:(FMResultSet *)resultSet {
    self.user_id = [resultSet longLongIntForColumn:@"user_id"];
    self.pole_no = [resultSet stringForColumn:@"pole_no"];
    self.collection_state = [resultSet intForColumn:@"collection_state"];
}

- (NSDictionary *)parameterDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"user_id", @"pole_no", @"collection_state"];
    for (NSString *key in keys) {
        id object = [self valueForKey:key];
        [dict setObject:object?:[NSNull null] forKey:key];
    }
    return [dict copy];
}

+ (NSArray *)favoritesWithUserId:(int64_t)userId {
    NSMutableArray *favorites = [NSMutableArray array];
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_Pole_Collection WHERE user_id = ?"
               withArgumentsInArray:@[@(userId)]
                        resultBlock:^(FMResultSet *resultSet) {
                            while ([resultSet next]) {
                                DCDatabaseFavorites *favor = [self favorWithResultSet:resultSet];
                                [favorites addObject:favor];
                            }
                        }];
    return favorites;
}

+ (BOOL)isPole:(NSString *)poleNo favorByUserId:(int64_t)userId {
    BOOL __block result = NO;
    if (!poleNo) {
        return result;
    }
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_Pole_Collection WHERE pole_no = ? AND user_id = ?"
               withArgumentsInArray:@[poleNo, @(userId)]
                        resultBlock:^(FMResultSet *resultSet) {
                            if ([resultSet next]) {
                                DCDatabaseFavorites *favor = [self favorWithResultSet:resultSet];
                                result = favor.collection_state;
                            }
                        }];
    return result;
}

+ (void)favor:(BOOL)favor withPoleNo:(NSString *)poleNo userId:(int64_t)userId {
    if (!poleNo) {
        return;
    }
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM T_Pole_Collection WHERE pole_no = ? AND user_id = ?" withArgumentsInArray:@[poleNo, @(userId)]];
        if (favor) {
            [db executeUpdate:@"INSERT INTO T_Pole_Collection (user_id, pole_no, collection_state) VALUES (?, ?, ?)" withArgumentsInArray:@[@(userId), poleNo, @(favor)]];
        }
    }];
}

@end
