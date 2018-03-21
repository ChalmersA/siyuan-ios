//
//  UIColor+HSSYColor.m
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "UIColor+HSSYColor.h"

// Template colors
#define COLOR_MAINTHEME [UIColor colorWithRed:0.11 green:0.70 blue:0.68 alpha:1.000]
#define COLOR_MAINTHEME_DISABLE [UIColor colorWithWhite:0.769 alpha:1.000]

@implementation UIColor (HSSYColor)

+ (UIColor *)digitalColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [UIColor colorWithRed:red/255 green:green/255 blue:blue/255 alpha:1];
}

+ (UIColor *)tabBarColorForTheme:(HSSYTheme)theme {
    switch (theme) {
        case HSSYThemeLight: {
            return [UIColor whiteColor];
        }
            
        default: {
            return [UIColor paletteDCMainColor];
        }
    }
}

+ (UIColor *)highlightGreen {
    return [UIColor colorWithRed:0.18 green:0.95 blue:0.65 alpha:1];
}

+ (UIColor *)selectedTabColor {
    return [UIColor whiteColor];
}

+ (UIColor *)unselectedTabColor {
    return [UIColor digitalColorWithRed:45 green:112 blue:113];
}

+ (UIColor *)timeFilterTintColor {
    return [UIColor digitalColorWithRed:56 green:241 blue:231];
}


/////// 订单 \\\\\\\
//订单：联系业主
+ (UIColor *)orderContactOwnerButtonColor {
    return [UIColor paletteDCMainColor];
}
//订单：取消订单
+ (UIColor *)orderCancelButtonColor {
    return [UIColor digitalColorWithRed:230 green:92 blue:77];
}
//订单：拒绝
+ (UIColor *)orderRefuseButtonColor {
    return [UIColor digitalColorWithRed:230 green:92 blue:77];
}
//订单：同意
+ (UIColor *)orderConfirmButtonColor {
    return [UIColor paletteDCMainColor];
}
//订单：联系车主
+ (UIColor *)orderContactTenantButtonColor {
    return [UIColor paletteDCMainColor];
}
//订单：导航
+ (UIColor *)orderNaviButtonColor {
    return [UIColor digitalColorWithRed:59 green:143 blue:253];
}
//订单：付款
+ (UIColor *)orderPayButtonColor {
    return [UIColor paletteDCMainColor];
}
//订单：评价分享
+ (UIColor *)orderEvaluateButtonColor {
    return [UIColor paletteDCMainColor];
}
//订单：重新预约
+ (UIColor *)orderReorderButtonColor {
    return [UIColor digitalColorWithRed:230 green:92 blue:77];
}


// =======================
//我的预约：绿色按钮颜色
+ (UIColor *)mainthemeColor {
    return COLOR_MAINTHEME;
}

+ (UIColor *)mainthemeDisableColor {
    return COLOR_MAINTHEME_DISABLE;
}


#pragma mark - App Palette Colors


//## 主要颜色
// 主色 (鼎充蓝)：#0c82e4
+ (UIColor *)paletteDCMainColor {
    UIColor *color = UIColorFromRGB(0x0c82e4);
    return color;
}

// 按钮色 (蓝)：#1B3681
+ (UIColor *)paletteButtonBlueColor {
    UIColor *color = UIColorFromRGB(0x1B3681);
    return color;
}

// 按钮色 (红)：#EE2441
+ (UIColor *)paletteButtonRedColor {
    UIColor *color = UIColorFromRGB(0xEE2441);
    return color;
}

// 按钮色 (浅蓝色)：#00A8FF
+ (UIColor *)paletteButtonLightBlueColor {
    UIColor *color = UIColorFromRGB(0x00A8FF);
    return color;
}

// 按钮色 (黄色)：#EDBE30
+ (UIColor *)paletteButtonYellowColor {
    UIColor *color = UIColorFromRGB(0xEDBE30);
    return color;
}

// 价格, 警告语字体颜色 (红色): #EF0D0D
+ (UIColor *)palettePriceRedColor {
    UIColor *color = UIColorFromRGB(0xEF0D0D);
    return color;
}

// 字体颜色(灰色): #000000
+ (UIColor *)paletterFontGreyColor {
    UIColor *color = UIColorFromRGBWithAlpha(0x000000, 0.6);
    return color;
}

// 按钮边框颜色 (灰色): #B0AEAF
+ (UIColor *)paletteButtonBoradColor {
    UIColor *color = UIColorFromRGB(0xB0AEAF);
    return color;
}

// 按钮背景颜色 (灰色): #E7E7E7
+ (UIColor *)paletteButtonBackgroundColor {
    UIColor *color = UIColorFromRGB(0xE7E7E7);
    return color;
}




// 辅色 (橙色)：#F8891D
+ (UIColor *)paletteOrangeColor {
    UIColor *color = UIColorFromRGB(0xF8891D);
    return color;
}

// 辅色 (字深灰)：#999999
+ (UIColor *)paletteFontDarkGrayColor {
    UIColor *color = UIColorFromRGB(0x999999);
    return color;
}

// 辅色 (底部按钮浅灰)：#F7F8F8
+ (UIColor *)paletteBottomBtnLightGrayColor {
    UIColor *color = UIColorFromRGB(0xF7F8F8);
    return color;
}

// 辅色 (间隔线浅灰)：#EEEEEE
+ (UIColor *)paletteSeparateLineLightGrayColor {
    UIColor *color = UIColorFromRGB(0xEEEEEE);
    return color;
}

// 辅色 (导航背景灰)：#BBBBBB
+ (UIColor *)paletteNaviBgGrayColor {
    UIColor *color = UIColorFromRGB(0xBBBBBB);
    return color;
}

// 辅色 (字黑)：#0F0F0F
+ (UIColor *)paletteFontBlack {
    UIColor *color = UIColorFromRGB(0x0F0F0F);
    return color;
}

// 辅色 (显示块阴影灰)：#D9D9D9D
+ (UIColor *)paletteBlockGray {
    UIColor *color = UIColorFromRGB(0xD9D9D9D);
    return color;
}

// 辅色 (字体浅黑)：#666666
+ (UIColor *)paletteTextLightBlack {
    UIColor *color = UIColorFromRGB(0x666666);
    return color;
}

// 辅色 (订单状态：启动充电)：#39b1e9
+ (UIColor *)paletteChargingBlue {
    UIColor *color = UIColorFromRGB(0x39b1e9);
    return color;
}
@end
