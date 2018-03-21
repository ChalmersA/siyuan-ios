//
//  HSSYDetailTableViewHeader.m
//  Charging
//
//  Created by Pp on 15/10/13.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCDetailTableViewHeader.h"

@implementation DCDetailTableViewHeader

- (IBAction)touchButton {
    if (self.arrow.hidden) {
        return;
    }
    [self.myDelegate touchedHeader];
}

@end
