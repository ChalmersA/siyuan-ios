//
//  HSSYUnitedValue.h
//  Charging
//
//  Created by Blade on 15/12/18.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCUnitedValue : NSObject <NSCopying>  {
    NSInteger max_Mantissa; //最大的小数位数
    double UV_Value;
}

//@property (nonatomic, assign) NSInteger max_Mantissa; //最大的小数位数
//@property (nonatomic, assign) double UV_Value; //值
@end
