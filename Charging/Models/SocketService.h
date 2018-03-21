//
//  SocketService.h
//  Charging
//
//  Created by Ben on 14/12/12.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "Service.h"

enum SOCKET_SERVICE_STATUS {
    SOCKET_SERVICE_STATUS_UNKNOWN = -1,
    SOCKET_SERVICE_STATUS_DISCONNECTED = 0,
    SOCKET_SERVICE_STATUS_CONNECTED = 1
} SOCKET_SERVICE_STATUS;

enum SOCKET_SWITCH_STATE {
    SOCKET_SWITCH_STATE_UNKNOWN = -1,
    SOCKET_SWITCH_STATE_ON = 1,
    SOCKET_SWITCH_STATE_OFF = 2
} SOCKET_SWITCH_STATE;

@interface SocketService : Service

@property (nonatomic) NSUInteger voltage;
@property (nonatomic) NSUInteger current;
@property (nonatomic) NSUInteger frequency;
@property (nonatomic) NSUInteger switchState;

@end
