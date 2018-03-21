//
//  CarouselView.h
//  循环播图
//
//  Created by lanou on 15/7/23.
//  Copyright (c) 2015年 lanou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CarouselViewDelegate <NSObject>

- (void)clickTheTopOfImageViewWithUrl:(NSString *)url sourceType:(NSInteger)sourceType;

@end

@interface CarouselView : UIView

// 图片数据
@property (nonatomic, strong) NSArray *array;
@property (weak, nonatomic) id <CarouselViewDelegate> delegate;

@end
