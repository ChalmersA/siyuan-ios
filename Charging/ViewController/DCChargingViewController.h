//
//  HSSYChargingViewController.h
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "DCPopupView.h"
//#import "DCOneButtonAlertView.h"
#import "DCChargeDoneViewController.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, DCChargingState) {
//    DCChargingStateHomePage,
    DCChargingStateScaning,
    DCChargingStateCharging,
};

@interface DCChargingViewController : DCViewController <UITableViewDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, UIAlertViewDelegate>

@property (assign, nonatomic) DCChargingState chargingState;
@end
