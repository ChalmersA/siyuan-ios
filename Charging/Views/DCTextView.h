//
//  HSSYTextView.h
//  Charging
//
//  Created by  Blade on 4/8/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCTextView : UITextView {
    UITextView* _placeholderTextView;
}

@property(nonatomic, assign)NSString *placeholder;
- (void)replacePlaceholder:(NSString *)placeholder withFrame:(CGRect)frame;
@end
