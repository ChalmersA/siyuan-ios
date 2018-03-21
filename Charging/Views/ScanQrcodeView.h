//
//  ScanQrcodeView.h
//  ScanQrcode
//
//  Created by chenzhibin on 15/10/29.
//  Copyright © 2015年 chenzhibin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScanQrcodeViewDelegate <NSObject>
- (void)scanSuccess:(NSString *)text;
- (void)scanError:(NSError *)error;
@end

@interface ScanQrcodeView : UIView
@property (weak, nonatomic) id <ScanQrcodeViewDelegate> delegate;
@property (nonatomic) BOOL isScan;
- (void)startScan;
- (void)stopScan;
@end
