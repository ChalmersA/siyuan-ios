//
//  DCOrderViewController.h
//  Charging
//
//  Created by xpg on 14/12/18.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "DCBookEditableCell.h"
#import "DCBookNormalCell.h"
#import "DCChargeEditableCell.h"
#import "DCChargeNormalCell.h"

typedef NS_ENUM(NSInteger, DCReserveOrderTab) {
    DCReserveOrderTabBook,
    DCReserveOrderTabCharge,
    DCReserveOrderTabBookDelete = 10,
    DCReserveOrderTabChargeDelete,
    DCReserveOrderTabUnknow = 999
};

@protocol MyOrderRefreshDelegate <NSObject>

-(void)myOrderRefresh:(id)sender;

@end

@interface DCOrderViewController : DCViewController <DCChargeEditableCellDelegate, DCBookNormalCellDelegate>
@property (weak, nonatomic) id <MyOrderRefreshDelegate> delegate;
@property (nonatomic) DCReserveOrderTab initialTab; //初始化的页面
@end


