//
//  DCUIImageVIew.m
//  Charging
//
//  Created by  Blade on 11/30/15.
//  Copyright © 2015 xpg. All rights reserved.
//

#import "DCUIImageVIew.h"

#pragma mark - Helpers

@interface UIView (HSSYUIImageViewHelpers) // From Marqueenlabel
- (UIViewController *)firstAvailableViewController;
- (id)traverseResponderChainForFirstViewController;
@end


@implementation UIView (HSSYUIImageViewHelpers) // From Marqueenlabel
// Thanks to Phil M
// http://stackoverflow.com/questions/1340434/get-to-uiviewcontroller-from-uiview-on-iphone

- (id)firstAvailableViewController
{
    // convenience function for casting and to "mask" the recursive function
    return [self traverseResponderChainForFirstViewController];
}

- (id)traverseResponderChainForFirstViewController
{
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForFirstViewController];
    } else {
        return nil;
    }
}

@end

@interface DCUIImageVIew () {
    
}
@property (assign, atomic) BOOL isAnimating;
@property (retain, nonatomic) CAAnimation* animation;
@property (copy, nonatomic) NSString* animationKey;
@end

@implementation DCUIImageVIew
#pragma mark - Life cycle
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observedViewControllerChange:) name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
    
}
- (void)setUpAnimate:(CAAnimation*)animation withKey:(NSString*)key {
    self.animation = animation;
    self.animationKey = key;
    self.animation.delegate = self;
    [self.animation setRemovedOnCompletion:NO];
    [self.layer removeAllAnimations];
    [self.layer addAnimation:self.animation forKey:self.animationKey];
    [self stopLayer:self.layer];
    self.isAnimating = NO;
}

- (void)startAnimate {
    self.isAnimating = YES;
    [self pauseLayer:self.layer]; // TODO: 是否必须要先停止再开始？目前
    [self resumeLayer:self.layer];
}

- (void)stopAnimate {
    self.isAnimating = NO;
    [self stopLayer:self.layer];
}


#pragma mark - Notification
- (void)observedViewControllerChange:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    id fromController = [userInfo objectForKey:@"UINavigationControllerLastVisibleViewController"];
    id toController = [userInfo objectForKey:@"UINavigationControllerNextVisibleViewController"];
    
    id ownController = [self firstAvailableViewController];
    if ([fromController isEqual:ownController]) {
        //
    }
    else if ([toController isEqual:ownController]) {
        if (self.isAnimating) {
            [self resumeLayer:self.layer];
        }
    }
}

#pragma mark - Animation Delegate
- (void)animationDidStart:(CAAnimation *)anim {
    //
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self pauseLayer:self.layer];
}

@end
