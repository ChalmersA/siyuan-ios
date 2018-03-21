//
//  HSSYDetailTableView.h
//  Charging
//
//  Created by Pp on 15/10/12.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCDetailTableView : UIView

@property (nonatomic, strong) NSString *stationId;
@property (nonatomic) BOOL headerArrowHidden;

- (void)createTableView:(UITableView *)table andHeight:(NSLayoutConstraint *)height dcGunIdleNum:(NSInteger)dcGunIdleNum dcGunBookableNum:(NSInteger)dcGunBookableNum acGunIdleNum:(NSInteger)acGunIdleNum acGunBookableNum:(NSInteger)acGunBookableNum stationId:(NSString *)stationId;

@end
