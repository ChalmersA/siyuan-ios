//
//  ButtonBar.m
//  Charging
//
//  Created by Ben on 14/12/23.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "ButtonBar.h"

static float BUTTOM_LINE_HEIGHT = 2.0;
static float RED_TAG_WIDTH_HEIGHT = 20.0;
static float RED_TAG_INTERVAL_X = 10.0;
static float RED_TAG_INTERVAL_Y = 5.0;

@interface ButtonBar (){
    UIButton *selectedBtn;
}
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSMutableArray *tags;
@property (strong, nonatomic) UILabel *lineLabel;

@end

@implementation ButtonBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor paletteDCMainColor];
        
        _buttons = [NSMutableArray array];
        _tags = [NSMutableArray array];
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
                [_buttons addObject:view];
            }
        }
        selectedBtn = [_buttons firstObject];
        selectedBtn.selected = YES;
        
        self.lineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lineLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.lineLabel];
        
        for (UIButton *button in _buttons) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_icon"]];
            imageView.hidden = YES;
            [button addSubview:imageView];
            [_tags addObject:imageView];
        }
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutBottomLine];
    
    for (UIImageView *imageView in _tags) {
        UIButton *button = _buttons[[_tags indexOfObject:imageView]];
        imageView.frame = CGRectMake(button.frame.size.width - RED_TAG_WIDTH_HEIGHT - RED_TAG_INTERVAL_X, 0.0 + RED_TAG_INTERVAL_Y, RED_TAG_WIDTH_HEIGHT, RED_TAG_WIDTH_HEIGHT);
    }
}

- (void)layoutBottomLine {
    CGRect lineFrame, remainder;
    CGRectDivide(selectedBtn.frame, &lineFrame, &remainder, BUTTOM_LINE_HEIGHT + 4, CGRectMaxYEdge);
    lineFrame = CGRectInset(lineFrame, 8, 2);
    self.lineLabel.frame = lineFrame;
}

#pragma mark 设置第几个button有红点
-(void)setTagForItem:(NSArray *)tagArray{
    for (UIImageView *tagView in self.tags) {
        [tagView setHidden:YES];
    }
    
    for (int i = 0 ; i < tagArray.count ; i++) {
       NSInteger tag = [[tagArray objectAtIndex:i] integerValue];
        ((UIImageView *)[_tags objectAtIndex:tag]).hidden = NO;
    }
}

- (void)clickButton:(UIButton *)sender {
    [self selectButtonIndex:[_buttons indexOfObject:sender] animated:YES];
    [self.delegate buttonBarClick:[_buttons indexOfObject:selectedBtn]];
}

- (void)selectButtonIndex:(NSInteger)index animated:(BOOL)animated {
    index = MIN(MAX(0, index), [self.buttons count] - 1);
    if (index == [_buttons indexOfObject:selectedBtn]) {
        return;
    }
    for (UIButton *button in _buttons) {
        button.selected = NO;
    }
    selectedBtn = self.buttons[index];
    selectedBtn.selected = YES;
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutBottomLine];
        }];
    } else {
        [self layoutBottomLine];
    }
}
@end
