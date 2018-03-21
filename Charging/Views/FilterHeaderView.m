//
//  FilterHeaderView.m
//  PiFuKeYiSheng
//
//  Created by 喻平 on 14-7-9.
//  Copyright (c) 2014年 com.pifukeyisheng. All rights reserved.
//

#import "FilterHeaderView.h"
#define kTitleButtonWidth 250.f
#define kMoreButtonWidth  36*2
#define kCureOfLineHight  0.5
#define kCureOfLineOffX   16

float CYLFilterHeaderViewHeigt = 38;
@interface FilterHeaderView()

@end
@implementation FilterHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}
- (id)initWithCoder: (NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)sharedInit {
//    UIView *cureOfLine = [[UIView alloc] initWithFrame:CGRectMake(kCureOfLineOffX, CYLFilterHeaderViewHeigt-kCureOfLineHight, [UIScreen mainScreen].bounds.size.width - 2*kCureOfLineOffX, kCureOfLineHight)];
//    cureOfLine.backgroundColor = [UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0];
//    [self addSubview:cureOfLine];
//    self.backgroundColor = [UIColor whiteColor];
//    //仅修改self.titleButton的宽度,xyh值不变
//    self.titleButton = [[CYLIndexPathButton alloc] init];
//    self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
//    self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//    self.titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    self.titleButton.frame = CGRectMake(16, 0, kTitleButtonWidth,  self.frame.size.height);
//    self.titleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
//    [self.titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
//    [self addSubview:self.titleButton];
//    CGRect  moreBtnFrame = CGRectMake(self.moreButton.frame.origin.x, 0, kMoreButtonWidth, self.frame.size.height);
//    self.moreButton = [[CYLRightImageButton alloc] initWithFrame:moreBtnFrame];
//    //仅修改self.moreButton的x,ywh值不变
//    self.moreButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 12 - self.moreButton.frame.size.width, self.moreButton.frame.origin.y, self.moreButton.frame.size.width, self.moreButton.frame.size.height);
//    [self.moreButton setImage:[UIImage imageNamed:@"home_btn_more_normal"] forState:UIControlStateNormal];
//    [self.moreButton setImage:[UIImage imageNamed:@"home_btn_more_selected"] forState:UIControlStateSelected];
//    [self.moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
//    [self.moreButton setTitle:@"更多" forState:UIControlStateNormal];
//    [self.moreButton setTitle:@"收起" forState:UIControlStateSelected];
//    self.moreButton.titleLabel.textAlignment = NSTextAlignmentRight;
//    self.moreButton.hidden = YES;
//    [self.moreButton addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.moreButton];
    
    self.backgroundColor = [UIColor whiteColor];
    self.sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    self.sectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.sectionLabel.textAlignment = NSTextAlignmentCenter;
    self.sectionLabel.textColor = [UIColor colorWithRed:0.086 green:0.651 blue:0.620 alpha:1.000];
    [self addSubview:self.sectionLabel];
    // add constraints
    // Add vertical space
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.sectionLabel
                                                                              attribute:NSLayoutAttributeLeading
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeLeading
                                                                             multiplier:1.0f
                                                                               constant:0.f];
    // Add central Y
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.sectionLabel
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0f
                                                                           constant:0.0f];
    // Add equal top
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.sectionLabel
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:0.0f];
    // Add equal bottom
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.sectionLabel
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0f
                                                                            constant:0.f];
    
    [self addConstraints:@[
                           leadingConstraint
                           ,trailingConstraint
                           ,topConstraint
                           ,bottomConstraint
                           ]];
    
    
    return self;
}
@end
