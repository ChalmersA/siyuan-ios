//
//  chargePortView.m
//  Charging
//
//  Created by kufufu on 16/3/8.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "ChargePortView.h"
#import "DCChargePort.h"

@interface ChargePortView ()
{
    BOOL isSelected;
    NSMutableArray *buttonArray;
    NSMutableArray *viewArray;
}
@end

@implementation ChargePortView

+ (instancetype)chargePortViewWithChargePorts:(NSArray *)chargePorts chooseIndex:(NSInteger)chooseIndex{
    ChargePortView *view = [ChargePortView new];
    for (int i = 1; i <= 4; i++) {
        if (i == chargePorts.count) {
            view = [[[NSBundle mainBundle] loadNibNamed:@"ChargePortView" owner:nil options:nil] objectAtIndex:(i - 1)];
        }
    }
    [view viewWithChargePorts:chargePorts chooseIndex:chooseIndex];
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    isSelected = NO;
    
}

- (void)viewWithChargePorts:(NSArray *)chargePorts chooseIndex:(NSInteger)chooseIndex{
    buttonArray = [NSMutableArray arrayWithObjects:self.chargePortA, self.chargePortB, self.chargePortC, self.chargePortD, nil];
    if (chooseIndex) {
        isSelected = YES;
    }
    for (int i = 0; i < chargePorts.count; i++) {
        DCChargePort *cp = [[DCChargePort alloc] initChargePortWithDictionary:[chargePorts objectAtIndex:i]];
        for (int j = 0; j < buttonArray.count; j++) {
            UIButton *button = [buttonArray objectAtIndex:j];
            button.layer.cornerRadius = 10;
            button.layer.masksToBounds = YES;
            [button setBorderColor:[UIColor paletteButtonBoradColor] width:1];
            if ([cp.index integerValue] == (j+1)) {
                if (cp.runStatus == DCRunStatusSpare || cp.runStatus == DCRunStatusConnectNotCharge) {
                    button.enabled = YES;
                    button.tag = j;
                    [button setBackgroundColor:[UIColor whiteColor]];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    
                    if (isSelected == NO || [cp.index integerValue] == chooseIndex) {
                        button.selected = YES;
                        isSelected = YES;
                        [button setBackgroundColor:[UIColor paletteDCMainColor]];
                        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [button setBorderColor:[UIColor paletteDCMainColor] width:1];
                    }
                }
            }
        }
    }
}

- (IBAction)clickChargePortAButton:(id)sender {
    if ([self respondsToSelector:@selector(clickChargePortAButton:)]) {
        [self.delegate clickChargePortButton:DCChargePortButtonA];
    }
}

- (IBAction)clickChargePortBButton:(id)sender {
    if ([self respondsToSelector:@selector(clickChargePortAButton:)]) {
        [self.delegate clickChargePortButton:DCChargePortButtonB];
    }
}

- (IBAction)clickChargePortCButton:(id)sender {
    if ([self respondsToSelector:@selector(clickChargePortAButton:)]) {
        [self.delegate clickChargePortButton:DCChargePortButtonC];
    }
}

- (IBAction)clickChargePortDButton:(id)sender {
    if ([self respondsToSelector:@selector(clickChargePortAButton:)]) {
        [self.delegate clickChargePortButton:DCChargePortButtonD];
    }
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    NSLog(@"ChargePortView %@", NSStringFromCGRect(self.frame));
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
