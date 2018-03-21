//
//  HSSPreloadingView.m
//  Charging
//
//  Created by  Blade on 9/1/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCPreloadingView.h"
@interface DCPreloadingView()
@property (nonatomic, weak) IBOutlet UIView* viewLoadFailed;
@property (nonatomic, weak) IBOutlet UIView* viewLoading;
@property (nonatomic, assign) PreLoadViewMode curMode;
@property (nonatomic, copy) PreLoadReloadBlock reLoadBlock;
@end

@implementation DCPreloadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)reloadBtnClick:(id)sender {
    if (self.reLoadBlock) {
        self.reLoadBlock();
        self.reLoadBlock = nil;
    }
    [self setMode:PreLoadViewModeLoading];
}

-(void)setMode:(PreLoadViewMode)mode {
    switch (mode) {
        case PreLoadViewModeLoading:
        {
            [self.viewLoading setHidden:NO];
            [self.viewLoadFailed setHidden:YES];
        }
            break;
            
        case PreLoadViewModeLoadFailed:
        {
            [self.viewLoading setHidden:YES];
            [self.viewLoadFailed setHidden:NO];
        }
            break;
            
        default:
            break;
    }
    self.curMode = mode;
}

-(void)setReloadBlock:(PreLoadReloadBlock)block {
    self.reLoadBlock = block;
}
@end
