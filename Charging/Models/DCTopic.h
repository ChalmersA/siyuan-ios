//
//  HSSYTopic.h
//  Charging
//
//  Created by xpg on 15/9/17.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HSSYTopicDelegate<NSObject>
-(void)didClick:(id)data;
-(void)currentPage:(int)page total:(NSUInteger)total;
@end
@interface DCTopic : UIScrollView<UIScrollViewDelegate>{
    UIButton * pic;
    bool flag;
    int scrollTopicFlag;
    NSTimer * scrollTimer;
    int currentPage;
    CGSize imageSize;
    UIImage *image;
}
@property(nonatomic,strong)NSArray * pics;
@property (nonatomic,weak) id<HSSYTopicDelegate> topicDelegate;
-(void)releaseTimer;
-(void)upDate;
@end
