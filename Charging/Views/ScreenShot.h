//
//  ScreenShot.h
//  MyShowCase
//
//  Created by kufufu on 15/7/28.
//  Copyright (c) 2015年 Wikky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ScreenShot : NSObject
@property (strong, nonatomic) UIImage *screenImage;
// 截屏方法
-(UIImage*)screenShot:(id)view;
// 图片传到sandBox中
- (NSString *)savePictureToDocument;

@end
