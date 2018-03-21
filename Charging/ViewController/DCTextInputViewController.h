//
//  DCTextInputViewController.h
//  Charging
//
//  Created by xpg on 6/3/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCViewController.h"

typedef NS_ENUM(NSInteger, DCTextInputType) {
    DCTextInputTypeUserName,
    DCTextInputTypePileName,
};

@class DCTextInputViewController;
@protocol DCTextInputDelegate <NSObject>
- (void)textInputViewController:(DCTextInputViewController *)vc inputDone:(NSString *)text;
@end

@interface DCTextInputViewController : DCViewController
//@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;

@property (weak, nonatomic) id <DCTextInputDelegate> delegate;
@property (weak, nonatomic) NSURLSessionTask *requestTask;
@property (copy, nonatomic) NSString *text;

@property (assign, nonatomic) DCTextInputType textType;

@property (nonatomic) NSNumber *minLength;
@property (nonatomic) NSNumber *maxLength;
@end
