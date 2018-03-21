//
//  MyCenterView.h
//  SPAlertController
//
//  Created by Libo on 2017/11/5.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^seletedRow)(NSString *);

@interface MyCenterView : UIView

@property (copy , nonatomic)seletedRow seletedRowBlock;

@end
