//
//  HSSYPoleSettingForm.m
//  Charging
//
//  Created by xpg on 14/12/22.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCPoleSettingForm.h"

@interface DCPoleSettingForm ()
@property (strong, nonatomic) DCPoleSettingNormalItem *nameItem;//名称
@property (strong, nonatomic) DCPoleSettingSwitchItem *lightItem;//灯光
@property (strong, nonatomic) DCPoleSettingSwitchItem *guardItem;//门禁
@property (strong, nonatomic) DCPoleSettingSwitchItem *loadItem;//负荷
@property (strong, nonatomic) DCPoleSettingNormalItem *authItem;//授权用户
@property (strong, nonatomic) DCPoleSettingNormalItem *infoItem;//电桩信息
@property (strong, nonatomic) DCPoleSettingNormalItem *shareItem;//电桩发布
@property (strong, nonatomic) DCPoleSettingNormalItem *curTimeItem;//电桩当前时间

@end

@implementation DCPoleSettingForm
- (instancetype)init {
    self = [super init];
    if (self) {
        _nameItem = [[DCPoleSettingNormalItem alloc] init];
        _nameItem.title = @"名称";
        _nameItem.type = HSSYPoleSettingFormItemTypePoleName;
        
        _lightItem = [[DCPoleSettingSwitchItem alloc] init];
        _lightItem.title = @"灯光";
        _lightItem.type = HSSYPoleSettingFormItemTypeLight;
        
        _guardItem = [[DCPoleSettingSwitchItem alloc] init];
        _guardItem.title = @"门禁";
        _guardItem.type = HSSYPoleSettingFormItemTypeDoorControl;
        
        _loadItem = [[DCPoleSettingSwitchItem alloc] init];
        _loadItem.title = @"负荷";
        _loadItem.type = HSSYPoleSettingFormItemTypeLoad;
        
        _authItem = [[DCPoleSettingNormalItem alloc] init];
        _authItem.title = @"授权用户";
        _authItem.content = [NSString stringWithFormat:@"%ld人", (long)_authCount];
        _authItem.type = HSSYPoleSettingFormItemTypePoleAuthorization;
        
        _infoItem = [[DCPoleSettingNormalItem alloc] init];
        _infoItem.title = @"电桩信息";
        _infoItem.contentImgName = @"pole_manage_icon_qr";
        _infoItem.type = HSSYPoleSettingFormItemTypePoleInfo;
        
        _shareItem = [[DCPoleSettingNormalItem alloc] init];
        _shareItem.title = @"电桩发布";
        _shareItem.type = HSSYPoleSettingFormItemTypePoleShare;
        
        _curTimeItem = [[DCPoleSettingNormalItem alloc] init];
        _curTimeItem.title = @"电桩当前时间";
        _curTimeItem.type = HSSYPoleSettingFormItemTypeCurrentTime;
        
        
        _settingItems = @[_nameItem
                          ,_shareItem
//                          , _lightItem
//                          , _guardItem
//                          , _loadItem
                          ,_authItem
                          ,_infoItem
                          ,_curTimeItem
                          ];
    }
    return self;
}

- (void)setPoleName:(NSString *)poleName {
    _poleName = [poleName copy];
    self.nameItem.content = poleName;
}

- (void)setLightState:(BOOL)lightState {
    _lightState = lightState;
    self.lightItem.switchState = lightState;
}

- (void)setGuardState:(BOOL)guardState {
    _guardState = guardState;
    self.guardState = guardState;
}

- (void)setLoadState:(BOOL)loadState {
    _loadState = loadState;
    self.loadState = loadState;
}

- (void)setAuthCount:(NSInteger)authCount {
    _authCount = authCount;
    self.authItem.content = [NSString stringWithFormat:@"%ld人", (long)_authCount];
}

- (void)setShareState:(BOOL)shareState {
    _shareState = shareState;
    self.shareItem.content = [NSString stringWithFormat:shareState? @"已发布" : @"未发布"];
}

@end

@implementation DCPoleSettingItem
@end

@implementation DCPoleSettingNormalItem
@end

@implementation DCPoleSettingSwitchItem
@end

@implementation DCPoleSettingCell (HSSYPoleSettingForm)

+ (NSString *)identifierForItem:(id)item {
    if ([item isKindOfClass:[DCPoleSettingNormalItem class]]) {
        return @"DCPoleSettingCell";
    } else if ([item isKindOfClass:[DCPoleSettingSwitchItem class]]) {
        return @"HSSYPoleSettingCell-Switch";
    }
    return nil;
}

- (void)configureForItem:(id)item {
    self.item = item;
    if ([item isKindOfClass:[DCPoleSettingNormalItem class]]) {
        DCPoleSettingNormalItem *settingItem = item;
        self.titleLabel.text = settingItem.title;
        self.settingLabel.text = settingItem.content;
        if (settingItem.contentImgName) {
            self.contentImage.image = [UIImage imageNamed:settingItem.contentImgName];
            self.contentImage.hidden = NO;
        }
        else {
            self.contentImage.hidden = YES;
        }
    } else if ([item isKindOfClass:[DCPoleSettingSwitchItem class]]) {
        DCPoleSettingSwitchItem *settingItem = item;
        self.titleLabel.text = settingItem.title;
        self.settingSwitch.on = settingItem.switchState;
        if ([settingItem.title isEqualToString:@"灯光"]) {
            self.settingSwitch.tag = HSSYPoleSettingCellLightButtonTag;
        }else if ([settingItem.title isEqualToString:@"门禁"]) {
            self.settingSwitch.tag = HSSYPoleSettingCellDoorcontrolButtonTag;
        }else if ([settingItem.title isEqualToString:@"负荷"]) {
            self.settingSwitch.tag = HSSYPoleSettingCellLoadButtonTag;
        }
    }
}
- (HSSYPoleSettingFormItemType)itemTypeOfCell {
    if (self.item && [self.item isKindOfClass:[DCPoleSettingItem class]]) {
        DCPoleSettingItem *settingItem = self.item;
        return settingItem.type;
    }
    return HSSYPoleSettingFormItemTypeNone;
}

@end
