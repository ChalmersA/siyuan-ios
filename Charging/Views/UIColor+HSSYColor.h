//
//  UIColor+HSSYColor.h
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
//RGB color macro
#define UIColorFromRGB(rgbValue)  \
                                    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                                    green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                                                     blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                                                    alpha:1.0]



//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) \
                                            [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                                            green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                                             blue:((float)(rgbValue & 0xFF))/255.0 \
                                                            alpha:a]
typedef NS_ENUM(NSInteger, HSSYTheme) {
    HSSYThemeDefault,
    HSSYThemeLight,
};

@interface UIColor (HSSYColor)

+ (UIColor *)digitalColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

+ (UIColor *)tabBarColorForTheme:(HSSYTheme)theme;

+ (UIColor *)highlightGreen;//高亮绿色
+ (UIColor *)selectedTabColor;//标签栏选中颜色
+ (UIColor *)unselectedTabColor;//标签栏未选中颜色
+ (UIColor *)timeFilterTintColor;//时间筛选主色

//订单：联系业主
+ (UIColor *)orderContactOwnerButtonColor;
//订单：取消订单
+ (UIColor *)orderCancelButtonColor;
//订单：拒绝
+ (UIColor *)orderRefuseButtonColor;
//订单：同意
+ (UIColor *)orderConfirmButtonColor;
//订单：联系车主
+ (UIColor *)orderContactTenantButtonColor;
//订单：导航
+ (UIColor *)orderNaviButtonColor;
//订单：付款
+ (UIColor *)orderPayButtonColor;
//订单：评价分享
+ (UIColor *)orderEvaluateButtonColor;
//订单：重新预约
+ (UIColor *)orderReorderButtonColor;

+ (UIColor *)mainthemeColor;
+ (UIColor *)mainthemeDisableColor;

#pragma mark - App Palette Colors
/**
 *  主色 (鼎充蓝)：#0c82e4
 *
 *
 */
+ (UIColor *)paletteDCMainColor;

/**
 *  按钮色 (蓝)：#1B3681
 *
 *
 */
+ (UIColor *)paletteButtonBlueColor;

/**
 *  按钮色 (红)：#EE2441
 *
 *
 */
+ (UIColor *)paletteButtonRedColor;

/**
 *  按钮色 (浅蓝色)：#00A8FF
 *
 *
 */
+ (UIColor *)paletteButtonLightBlueColor;

/**
 *  按钮色 (黄色)：#EDBE30
 *
 *
 */
+ (UIColor *)paletteButtonYellowColor;

/**
 *
 *  价格, 警告语字体颜色 (红色): #EF0D0D
 *
 */
+ (UIColor *)palettePriceRedColor;

/**
 *
 *  字体颜色(灰色): #000000
 *
 */
+ (UIColor *)paletterFontGreyColor;

/**
 *  按钮边框 (灰色): #B0AEAF
 *
 *
 */
+ (UIColor *)paletteButtonBoradColor;

/**
 *  按钮背景 (灰色): #E7E7E7
 *
 *
 */
+ (UIColor *)paletteButtonBackgroundColor;





//TODO: 暂时留着
/**
 - *  辅色 (橙色)：#F8891D
 *
 *
 */
+ (UIColor *)paletteOrangeColor;

 /**
  *  辅色 (字深灰)：#999999
  *
  *
  */
+ (UIColor *)paletteFontDarkGrayColor;

/**
 *  辅色 (底部按钮浅灰)：#F7F8F8
 *
 *
 */
+ (UIColor *)paletteBottomBtnLightGrayColor;

/**
 *  辅色 (间隔线浅灰)：#EEEEEE
 *
 *
 */
+ (UIColor *)paletteSeparateLineLightGrayColor;

/**
 *  辅色 (导航背景灰)：#BBBBBB
 *
 *
 */
+ (UIColor *)paletteNaviBgGrayColor;

/**
 *  辅色 (字黑)：#0F0F0F
 *
 *
 */
+ (UIColor *)paletteFontBlack;

/**
 *  辅色 (显示块阴影灰)：#D9D9D9D 目前没有包含在色卡内
 *
 *
 */
+ (UIColor *)paletteBlockGray;

/**
 *  辅色 (字体浅黑)：#666666
 *
 *
 */
+ (UIColor *)paletteTextLightBlack;

/*
 *
 * 辅色 (订单状态：启动充电)：#39b1e9
 *
 */
+ (UIColor *)paletteChargingBlue;
@end
