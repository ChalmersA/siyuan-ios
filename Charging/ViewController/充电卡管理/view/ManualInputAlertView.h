//
//  ManualInputAlertView.h
//  aaa
//
//  Created by gaoml on 2018/3/7.
//  Copyright © 2018年 钞王. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^cancel)(void);
typedef void (^sure)(void);

@interface ManualInputAlertView : UIView
/**卡号*/
@property (nonatomic, copy) NSString *cardNum;

@property (copy , nonatomic)cancel clickCancelButtonBlock;
@property (copy , nonatomic)sure clickSureButtonBlock;

@end
