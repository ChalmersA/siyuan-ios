//
//  HSSYDynamicDetailsViewController.h
//  Charging
//
//  Created by xpg on 15/9/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCViewController.h"

@interface DCDynamicDetailsViewController : DCViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (assign, nonatomic) NSInteger soucrceType;
@property (copy, nonatomic) NSString *url;

@end
