//
//  NSURL+HSSYImage.m
//  Charging
//
//  Created by chenzhibin on 15/10/16.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "NSURL+HSSYImage.h"
#import "DCUser.h"
#import "DCSettingViewController.h"

@implementation NSURL (HSSYImage)

+ (instancetype)URLWithImagePath:(NSString *)path {
    
//    NSUserDefaults *saveGPRSMode = [NSUserDefaults standardUserDefaults];
//    
//    Reachabilityx *reach = [Reachabilityx reachabilityWithHostName:@"www.baidu.com"];
//    NetworkStatusx status = [reach currentReachabilityStatus];
//    if (status == ReachableViaWWAN && [[saveGPRSMode objectForKey:@"saveGPRSMode"] isEqualToString:@"On"]) {
//        return nil;
//    }
//    else {
        if (path.length == 0) {
            return nil;
        }
        NSURL *url = [NSURL URLWithString:path];
        if (!url.scheme) {
            url = [NSURL URLWithString:[SERVER_URL stringByAppendingPathComponent:path]];
        }
        return url;
//    }
}
@end
