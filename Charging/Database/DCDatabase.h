//
//  DCDatabase.h
//  Charging
//
//  Created by xpg on 15/1/3.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface DCDatabase : NSObject
@property (copy, nonatomic) NSString *path;
+ (instancetype)db;
- (BOOL)databaseIsAvailable;
- (void)setupDatabase:(void(^)(NSInteger version))progress completion:(void(^)(BOOL success))completion;
- (void)syncExecute:(void(^)(FMDatabase *db, BOOL *rollback))block;
- (void)asyncExecute:(void(^)(FMDatabase *db, BOOL *rollback))block;
- (void)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments resultBlock:(void(^)(FMResultSet *resultSet))resultBlock;
@end
