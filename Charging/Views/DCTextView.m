//
//  HSSYTextView.m
//  Charging
//
//  Created by  Blade on 4/8/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCTextView.h"

@implementation DCTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    // add placeholder
    [self appendPlaceholder];
    
    // Add text changed notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // add placeholder
        [self appendPlaceholder];
        
        // Add text changed notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _placeholderTextView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholderTextView.text = placeholder;
}
- (void)replacePlaceholder:(NSString *)placeholder withFrame:(CGRect)frame {
    _placeholderTextView.text = placeholder;
    _placeholderTextView.frame = frame;
}


- (NSString*)placeholder {
    return _placeholderTextView.text;
}

#pragma mark - Utilies
- (void)appendPlaceholder {
    if (self.placeholder == nil ) {
        CGRect viewFrame = CGRectMake(0, 0, 0, 0);
        _placeholderTextView = [[UITextView alloc] initWithFrame:viewFrame];
        _placeholderTextView.textColor = [UIColor paletteNaviBgGrayColor];
        _placeholderTextView.textAlignment = self.textAlignment;
        _placeholderTextView.font = self.font;
        _placeholderTextView.userInteractionEnabled = NO;
        _placeholderTextView.backgroundColor = [UIColor clearColor];
    }
    if (![self.subviews containsObject:_placeholderTextView]) {
        [self addSubview:_placeholderTextView];
    }
}

#pragma mark - UITextViewTextDidChangeNotification

- (void)textChanged:(NSNotification *)notification {
    _placeholderTextView.hidden = ([self.text length] != 0);
}

@end
