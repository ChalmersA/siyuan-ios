//
//  BasicInformationCell.h
//  Charging
//
//  Created by 陈志强 on 2018/3/6.
//  Copyright © 2018年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicInformationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *cardNumLb;//卡号
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLb;//手机号
@property (weak, nonatomic) IBOutlet UILabel *failureDateLb;//失效日期
@property (weak, nonatomic) IBOutlet UILabel *addressNameLb;//网点名称
@property (weak, nonatomic) IBOutlet UILabel *openCardDateLb;//开卡日期
@property (weak, nonatomic) IBOutlet UILabel *balanceLb;//余额

@end
