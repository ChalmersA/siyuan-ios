//
//  MapSearchFliterView.h
//  Charging
//
//  Created by Ben on 4/29/16.
//  Copyright © 2016 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFilterItemButton.h"
#import "DCSearchParameters.h"
#import "DCApp.h"

@protocol MapSearchFliterViewDelegate <NSObject>

- (void)clickTheSearchView;

@end

typedef void (^FilterResultBlock)();
@interface MapSearchFliterView : UIView<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet UISwitch *searchSwitch;
@property (weak, nonatomic) IBOutlet DCFilterItemButton *chargeTypeAllButton;
@property (weak, nonatomic) IBOutlet DCFilterItemButton *chargeTypeQuickButton;
@property (weak, nonatomic) IBOutlet DCFilterItemButton *chargeTypeSlowButton;
@property (weak, nonatomic) IBOutlet DCFilterItemButton *poleTypeAllButton;
@property (weak, nonatomic) IBOutlet DCFilterItemButton *poleTypePublicButton;
@property (weak, nonatomic) IBOutlet DCFilterItemButton *poleTypeSpecialButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIImageView *searchKeyWordBackgroudView;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DCSearchParameters *mySearchParameters;
@property (copy, nonatomic) FilterResultBlock filterBlock;

@property (weak, nonatomic) id <MapSearchFliterViewDelegate> delegate;

+ (instancetype)showFilterViewWithBlock:(FilterResultBlock)block;
@end
