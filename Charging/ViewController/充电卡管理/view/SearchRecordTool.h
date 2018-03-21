//
//  SearchRecordTool.h
//  aaa
//
//  Created by gaoml on 2018/3/13.
//  Copyright © 2018年 钞王. All rights reserved.
//  搜索记录管理工具

#import <Foundation/Foundation.h>

@interface SearchRecordTool : NSObject

/**获取所有历史记录*/
+ (NSArray *)getAllRecords;
/**插入一条记录*/
+ (void)insertRecord:(NSString *)record;
/**删除一条记录*/
+ (void)deleteRecord:(NSString *)record;
/**修改一条记录*/
+ (void)updateRecord:(NSString *)record withRecord:(NSString *)newRecord;
/**清除所有记录*/
+ (void)clearRecords;

@end
