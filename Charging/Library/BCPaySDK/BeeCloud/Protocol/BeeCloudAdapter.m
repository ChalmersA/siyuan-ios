//
//  BeeCloudAdapaterProtocol.m
//  BeeCloud
//
//  Created by Ewenlong03 on 15/9/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BeeCloudAdapter.h"
#import "BeeCloudAdapterProtocol.h"
#import "BCPayCache.h"

@implementation BeeCloudAdapter

+ (BOOL)beeCloudRegisterWeChat:(NSString *)appid {
    id adapter = [[NSClassFromString(kAdapterWXPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(registerWeChat:)]) {
        return [adapter registerWeChat:appid];
    }
    return NO;
}

+ (BOOL)beeCloudIsWXAppInstalled {
    id adapter = [[NSClassFromString(kAdapterWXPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(isWXAppInstalled)]) {
        return [adapter isWXAppInstalled];
    }
    return NO;
}

+ (void)beeCloudRegisterPayPal:(NSString *)clientID secret:(NSString *)secret sanBox:(BOOL)isSandBox {
    id adapter = [[NSClassFromString(kAdapterPayPal) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(registerPayPal:secret:sanBox:)]) {
        [adapter registerPayPal:clientID secret:secret sanBox:isSandBox];
    }
}

+ (BOOL)beeCloud:(NSString *)object handleOpenUrl:(NSURL *)url {
    id adapter = [[NSClassFromString(object) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(handleOpenUrl:)]) {
        return [adapter handleOpenUrl:url];
    }
    return NO;
}

+ (void)beeCloudWXPay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterWXPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(wxPay:)]) {
        [adapter wxPay:dic];
    }
}

+ (void)beeCloudAliPay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterAliPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(aliPay:)]) {
        [adapter aliPay:dic];
    }
}

+ (void)beeCloudUnionPay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterUnionPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(unionPay:)]) {
        [adapter unionPay:dic];
    }
}

+ (void)beeCloudPayPal:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterPayPal) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(payPal:)]) {
        [adapter payPal:dic];
    }
}

+ (void)beeCloudPayPalVerify:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterPayPal) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(payPalVerify:)]) {
        [adapter payPalVerify:dic];
    }
}

+ (void)beeCloudOfflinePay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterOffline) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(offlinePay:)]) {
        [adapter offlinePay:dic];
    }
}

+ (void)beeCloudOfflineStatus:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterOffline) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(offlineStatus:)]) {
        [adapter offlineStatus:dic];
    }
}

+ (void)beeCloudOfflineRevert:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterOffline) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(offlineRevert:)]) {
        [adapter offlineRevert:dic];
    }
}

+(void)beeCloudBaiduPay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterBaidu) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(baiduPay:)]) {
        [adapter baiduPay:dic];
    }
}

@end