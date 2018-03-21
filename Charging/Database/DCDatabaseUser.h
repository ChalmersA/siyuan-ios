//
//  DCDatabaseUser.h
//  Charging
//
//  Created by xpg on 15/1/5.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDatabaseUser : NSObject
@property (copy, nonatomic)     NSString    *user_id;
@property (strong, nonatomic)   NSData      *user_portrait;
@property (copy, nonatomic)     NSString    *user_thirdUuid;
@property (copy, nonatomic)     NSString    *user_phone;
@property (assign, nonatomic)   int8_t      user_gender;
@property (copy, nonatomic)     NSString    *user_nickName;
@property (assign, nonatomic)   int8_t      user_bindType;
@property (assign, nonatomic)   int64_t     user_createAt;
@property (copy, nonatomic)     NSString    *user_pushId;
@property (assign, nonatomic)   int8_t      user_pushType;

+ (instancetype)userWithId:(int64_t)user_id;
/**
 *  清空用户
 */
+ (void)cleanAllUsersInDataBase;
- (void)saveToDatabase;
- (BOOL)isSameAs:(DCDatabaseUser *)user;
@end
