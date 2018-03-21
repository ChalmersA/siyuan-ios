//
//  HSSYSelectAreaViewController.h
//  Charging
//
//  Created by  Blade on 4/2/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "DCColorButton.h"
#import "BaiduMapKits.h"
#import "DCSelectCityViewController.h"
#import "City.h"
#import "DCArea.h"

@protocol HSSYDoneSetAreaDelegate <NSObject>
-(void)finishSettingArea:(DCArea*) area;
@end

@interface DCSelectAreaViewController : DCViewController <BMKLocationServiceDelegate,SelectCityDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cityBtn;
@property (weak, nonatomic) IBOutlet UIButton *specificBtn;

//@property (retain, nonatomic) City* curSelectedCity;
//@property (assign, nonatomic) CLLocationCoordinate2D curSelectedLocation;
@property (retain, nonatomic) DCArea *curSelectArea;
@property (weak, nonatomic) id <HSSYDoneSetAreaDelegate> delegate;

- (IBAction)curLocationClick:(id)sender;
- (IBAction)cityClick:(id)sender;
- (IBAction)specificLocationBtnClick:(id)sender;

@end
