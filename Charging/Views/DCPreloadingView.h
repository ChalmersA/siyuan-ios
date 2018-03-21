//
//  HSSPreloadingView.h
//  Charging
//
//  Created by  Blade on 9/1/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, PreLoadViewMode) {
    PreLoadViewModeLoading,
    PreLoadViewModeLoadFailed
};
typedef void(^PreLoadReloadBlock)(void);

@interface DCPreloadingView : UIView

-(void)setMode:(PreLoadViewMode)mode;
-(void)setReloadBlock:(PreLoadReloadBlock)block;
@end
