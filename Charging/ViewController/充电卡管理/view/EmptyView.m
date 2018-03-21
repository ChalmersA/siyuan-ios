//
//  EmptyView.m
//  Charging
//
//  Created by 陈志强 on 2018/3/11.
//  Copyright © 2018年 xpg. All rights reserved.
//

#import "EmptyView.h"

@interface EmptyView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *label;

@end

@implementation EmptyView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    return self;
}

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.center = self.center;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)label
{
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:14];
        _label.textColor = [UIColor paletteTextLightBlack];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.numberOfLines = 0;
        [self addSubview:_label];
    }
    return _label;
}

- (void)layoutSubviews {

    self.imageView.frame = CGRectMake(self.frameWidth/2 - 50, self.frameHeight/2 - 150, 100, 100);

    self.label.frame = CGRectMake(15, self.imageView.frame.origin.y + self.imageView.frameHeight, self.frameWidth - 30, 60);


}

- (void)showEmptyViewWithImage:(UIImage *)img title:(NSString *)str
{

    [self.imageView setImage:img];

    if (str == nil) {
        [self.label setHidden:YES];
    } else {
        [self.label setText:str];
    }
    
}

@end
