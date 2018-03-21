//
//  HSSYMessage.m
//  Charging
//
//  Created by xpg on 15/3/19.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCMessage.h"

@implementation DCMessage

- (instancetype)initWithNotificationInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        _messageId = [info stringForKey:@"noticeId"];
        _type = [info integerForKey:@"type"];
        _typeId = [info stringForKey:@"orderId"];
        
        //aps
        NSDictionary *aps = info[@"aps"];
        _content = aps[@"alert"];
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonModelKeyMap = [self jsonModelKeyMap];
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (obj == [NSNull null]) {
                    return;
                }
                
                //key
                if (jsonModelKeyMap[key]) {
                    key = jsonModelKeyMap[key];
                }
                
                //obj
                obj = [self convertObject:obj forKey:key];
                if (obj) {
                    [self setValue:obj forKey:key];
                }
            }];
        }
    }
    return self;
}

- (NSDictionary *)jsonModelKeyMap {
    return @{@"id": @"messageId"};
}

- (id)convertObject:(id)obj forKey:(NSString *)key {
    if ([key isEqualToString:@"createTime"]) {
        obj = [self dateFromTimestamp:obj];
    }
    return obj;
}

- (id)dateFromTimestamp:(id)obj {
    if ([obj respondsToSelector:@selector(doubleValue)]) {
        return [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]/1000];
    }
    return nil;
}

#pragma mark - Equal
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[DCMessage class]]) {
        DCMessage *message = object;
        return [self.messageId isEqualToString:message.messageId];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.messageId hash];
}

#if DEBUG
+ (instancetype)debugMessage {
    DCMessage *msg = [[DCMessage alloc] init];
    msg.messageId = [NSUUID UUID].UUIDString;
    msg.userId = [NSUUID UUID].UUIDString;
    msg.type = 1;
    msg.typeId = [NSUUID UUID].UUIDString;
    msg.createTime = [NSDate date];
    msg.status = DCMessageStatusUnread;
    msg.title = @"title";
    msg.content = @"content";
    return msg;
}
#endif

@end
