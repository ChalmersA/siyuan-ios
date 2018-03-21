//
//  HSSYPoleGroupAnnotationView.m
//  Charging
//
//  Created by xpg on 15/4/30.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPoleGroupAnnotationView.h"
#import "DCPoleMapAnnotation.h"
#define  Arror_height 6

@interface DCPoleGroupAnnotationView ()
@property (copy, nonatomic) ClusterItemSelctedBlcok itemSelectedBlock;
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) DCClusterPopoverVIew *clusterListView;
@end

@implementation DCPoleGroupAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.canShowCallout = NO;
        self.image = [UIImage imageNamed:@"groupAnnotation"];
        // make it directly "point" to the location
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor blackColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        [self addSubview:textLabel];
        _textLabel = textLabel;
        
        if (self.poleAnnotation) {
            [self configForAnnotation:self.poleAnnotation];
        }
    }
    
    return self;
}


- (void)configureGroupAnnotationViewWithBlock:(ClusterItemSelctedBlcok)block {
    self.itemSelectedBlock = block;
}

- (DCPoleMapAnnotation *)poleAnnotation {
    if ([self.annotation isKindOfClass:[DCPoleMapAnnotation class]]) {
        return self.annotation;
    }
    return nil;
}

- (void)configForAnnotation:(DCPoleMapAnnotation *)annotation {
    self.textLabel.text = [@(annotation.stationsCount) stringValue];
    
    /**
     * 聚合点外面的框框
     */
    if ([annotation isKindOfClass:[DCPoleMapAnnotation class]]) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat width = screenRect.size.width * 4/7;
        CGFloat height = 150;
        
        if (annotation.stations && [annotation.stations count] > 0) {
            if (!self.clusterListView) {
                typeof(self) __weak weakSelf = self;
                DCClusterPopoverVIew *view = [[DCClusterPopoverVIew alloc] initWithPoles:annotation.stations andFrame:CGRectMake((CGRectGetWidth(self.bounds) - width)/2, -height, width, height) itemSelectBlock:^(id item) {
                    
                    DCPoleMapAnnotation* hssyAnnotation =  (DCPoleMapAnnotation*)weakSelf.annotation;
                    hssyAnnotation.selectedStation = (DCStation*)item;
                    if (weakSelf.itemSelectedBlock) {
                        weakSelf.itemSelectedBlock(item);
                    }
                }];
                
                self.clusterListView = view;
                self.clusterListView.backgroundColor = [UIColor clearColor];
                [self.clusterListView selectStation:[annotation.stations objectAtIndex:0]]; // select the first pole by default
            }
            
            self.canShowCallout = YES;
            self.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:self.clusterListView];
            
//            [self addSubview:self.clusterListView];
//        }else{
//            [self hidenClusterListView];
        }
        //        [self.clusterListView setHidden:YES];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    CGFloat width = CGRectGetWidth(self.bounds);
//    CGFloat height = CGRectGetHeight(self.bounds);
    //    self.textLabel.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0.1 * height, 0.1 * width, 0.3 * height, 0.1 * width));
    self.textLabel.frame = self.bounds;//UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0.1 * height, 0.1 * width, 0.1 * height, 0.1 * width));
    //设置圆形，边框
    self.textLabel.layer.mask.masksToBounds = true;
    self.textLabel.layer.cornerRadius = self.textLabel.frame.size.height / 2.0;
    self.textLabel.layer.borderColor = [UIColor paletteButtonBlueColor].CGColor;
    self.textLabel.layer.borderWidth = 2.5f;
}

- (void)hidenClusterListView{
    if (self.clusterListView) {
        [self.clusterListView removeFromSuperview];
        self.clusterListView = nil;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
//    if (self.isSelected) {
//        self.clusterListView.hidden = NO;
//    }
//    else {
//        [self hidenClusterListView];
//    }
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//
//    
//    UIView *view = [super hitTest:point withEvent:event];
//    
//
//    
//    return view;
//}
//
////- (BOOL)isPassthroughView:(UIView *)view
////{
////    if (view == nil)
////    {
////        return NO;
////    }
////    
////    if ([self.passthroughViews containsObject:view])
////    {
////        return YES;
////    }
////    
////    return [self isPassthroughView:view.superview];
////}


- (DCStation *)selectedStation {
    DCPoleMapAnnotation* hssyAnnotation = (DCPoleMapAnnotation *)self.annotation;
    return hssyAnnotation.selectedStation;
}

- (DCStation *)selectStation:(DCStation *)station {
    if (self.clusterListView) {
        return [self.clusterListView selectStation:station];
    }
    return nil;
}
- (void)adjustViewMaxHeight:(CGFloat)height {
    CGRect frame = self.paopaoView.frame;
    CGFloat adjustedHeight = [self.clusterListView adjustViewMaxHeight:height];
    self.paopaoView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, adjustedHeight + 10);
}
@end
