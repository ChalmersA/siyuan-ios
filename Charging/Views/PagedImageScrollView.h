//
//  PagedImageScrollView.h
//  Test
//
//  Created by jianpx on 7/11/13.
//  Copyright (c) 2013 PS. All rights reserved.
//

#import <UIKit/UIKit.h>

enum PageControlPosition {
    PageControlPositionRightCorner = 0,
    PageControlPositionCenterBottom = 1,
    PageControlPositionLeftCorner = 2,
};

typedef NS_ENUM(NSInteger, ImageClickHandleType) { // 1点击显示处理   2 点击跳转
    ImageShow = 1,
    ImageTouchPush = 2,
    
};

@interface PagedImageScrollView : UIView
@property (nonatomic, weak) IBOutlet UILabel *labelHint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraitImagePageViewRatio;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, retain) NSLayoutConstraint *scrollViewHeightConstraint;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) enum PageControlPosition pageControlPos; //default is PageControlPositionRightCorner

@property (nonatomic, assign) ImageClickHandleType imageTouchHandle;
@property (nonatomic, strong) NSString * SegueWithIdentifier;
@property (nonatomic, strong) id pushVC;

- (void)setScrollViewContents: (NSArray *)images;
- (void)setImageScrollViewHeight:(CGFloat)height;
@end
