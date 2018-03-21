//
//  DCOneButtonAlertView.h
//  Charging
//
//  Created by kufufu on 16/4/11.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DCAlertType) {
    DCAlertTypeFault,
    DCAlertTypeBooked,
    DCAlertTypeCharging,
    DCAlertTypeExtract,     //充电枪拔出
    DCAlertTypeError,       //充电桩有异常(没有充电记录)
    DCAlertTypeException,   //充电桩有异常(需要获取充电记录)
    DCAlertTypeNotPay,
    DCAlertTypePayForWithdraw_Success, //在线充值成功
    DCAlertTypePayForChargeFee_Success, //支付充电费用成功
    DCAlertTypeNoChargePort, //没有充电口
    DCAlertTypeUnbindChargeCard, //解除电卡绑定
    DCAlertTypeWithoutFreeChargePort, //充电口非空闲
    DCAlertTypeGunLockOpen, //枪锁已打开
    DCAlertTypeDoorLockOpen, //门锁已打开
    DCAlertTypeUnkown = 999
};

@protocol DCOneButtonAlertViewDelegate <NSObject>

- (void)oneButtonAlertViewConfrimButton:(DCAlertType)alertType;

@end

@interface DCOneButtonAlertView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (assign, nonatomic) DCAlertType alertType;

@property (weak, nonatomic) id <DCOneButtonAlertViewDelegate> delegate;

+ (instancetype)viewWithAlertType:(DCAlertType)alertType;

@end
