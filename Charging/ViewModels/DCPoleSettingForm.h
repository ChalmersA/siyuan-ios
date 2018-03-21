//
//  HSSYPoleSettingForm.h
//  Charging
//
//  Created by xpg on 14/12/22.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCModel.h"
#import "DCPoleSettingCell.h"
typedef NS_ENUM(NSInteger, HSSYPoleSettingFormItemType)  {
    HSSYPoleSettingFormItemTypeNone,                // 无
    HSSYPoleSettingFormItemTypePoleName,            // 电桩名
    HSSYPoleSettingFormItemTypePoleShare,         // 电桩发布
    HSSYPoleSettingFormItemTypePoleAuthorization,   // 电桩授权（家人管理）
    HSSYPoleSettingFormItemTypePoleInfo,            // 电桩信息
    HSSYPoleSettingFormItemTypeCurrentTime,         // 电桩时间
    HSSYPoleSettingFormItemTypeLight,               // 灯
    HSSYPoleSettingFormItemTypeDoorControl,         // 门禁
    HSSYPoleSettingFormItemTypeLoad,                // 负荷
};

@interface DCPoleSettingItem : DCModel
@property (assign, nonatomic) HSSYPoleSettingFormItemType type;
@end
@interface DCPoleSettingNormalItem : DCPoleSettingItem
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *contentImgName;
@end

@interface DCPoleSettingSwitchItem : DCPoleSettingItem
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL switchState;
@end

@interface DCPoleSettingForm : DCModel
@property (copy, nonatomic) NSArray *settingItems;
@property (copy, nonatomic) NSString *poleName;
@property (assign, nonatomic) BOOL lightState;
@property (assign, nonatomic) BOOL guardState;
@property (assign, nonatomic) BOOL loadState;
@property (assign, nonatomic) NSInteger authCount;
@property (assign, nonatomic) BOOL shareState;
@end

@interface DCPoleSettingCell (HSSYPoleSettingForm)
+ (NSString *)identifierForItem:(id)item;
- (void)configureForItem:(id)item;
- (HSSYPoleSettingFormItemType)itemTypeOfCell;
@end
