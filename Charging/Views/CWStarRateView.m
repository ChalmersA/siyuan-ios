//
//  CWStarRateView.m
//  StarRateDemo
//
//  Created by WANGCHAO on 14/11/4.
//  Copyright (c) 2014年 wangchao. All rights reserved.
//

#import "CWStarRateView.h"

#define FOREGROUND_STAR_IMAGE_NAME @"star_small_yellow_fg"
#define BACKGROUND_STAR_IMAGE_NAME @"star_small_yellow_bg"
#define DEFALUT_STAR_NUMBER 5
#define ANIMATION_TIME_INTERVAL 0.2

@interface CWStarRateView (){
    BOOL hasLayout; //标记已经调整布局
}
@property (strong, nonatomic) UIView *referenceView;
@property (nonatomic, strong) UIView *foregroundStarView;
@property (nonatomic, strong) UIView *backgroundStarView;

@property (nonatomic, assign) NSInteger numberOfStars;

@end

@implementation CWStarRateView

#pragma mark - Init Methods
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (!_referenceView) {
        _referenceView = self.superview;
    }
}

- (instancetype)init {
    NSAssert(NO, @"You should never call this method in this class. Use initWithFrame: instead!");
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame numberOfStars:DEFALUT_STAR_NUMBER referView:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _numberOfStars = DEFALUT_STAR_NUMBER;
        [self buildDataAndUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars referView:(UIView *)referView{
    if (self = [super initWithFrame:frame]) {
        _numberOfStars = numberOfStars;
        _referenceView = referView;
        [self buildDataAndUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars referView:(UIView *)referView backgroundImageName:(NSString *)backgroundImageName foregroundImageName:(NSString *)foregroundImageName {
    if (self = [super initWithFrame:frame]) {
        _numberOfStars = numberOfStars;
        _referenceView = referView;
        _backgroundImageName = backgroundImageName;
        _foregroundImageName = foregroundImageName;
        [self buildDataAndUI];
    }
    return self;
}

- (void)dealloc {

}

#pragma mark - Private Methods

- (void)buildDataAndUI {
    _scorePercent = 1;//默认为1
    _hasAnimation = NO;//默认为NO
    _allowIncompleteStar = NO;//默认为NO

    self.foregroundStarView = [self createStarViewWithImage:self.foregroundImageName?:FOREGROUND_STAR_IMAGE_NAME];
    self.backgroundStarView = [self createStarViewWithImage:self.backgroundImageName?:BACKGROUND_STAR_IMAGE_NAME];
    
    [self addSubview:self.backgroundStarView];
    [self addSubview:self.foregroundStarView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapRateView:)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

- (void)userTapRateView:(UITapGestureRecognizer *)gesture {
    CGPoint tapPoint = [gesture locationInView:self];
    CGFloat offset = tapPoint.x;
    CGFloat realStarScore = offset / (self.bounds.size.width / self.numberOfStars);
    CGFloat starScore = self.allowIncompleteStar ? realStarScore : ceilf(realStarScore);
    self.scorePercent = starScore / self.numberOfStars;
}

- (UIView *)createStarViewWithImage:(NSString *)imageName {
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor clearColor];
    for (NSInteger i = 0; i < self.numberOfStars; i ++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame = CGRectMake(i * self.bounds.size.width / self.numberOfStars, 0, self.bounds.size.width / self.numberOfStars, self.bounds.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [view addSubview:imageView];
    }
    return view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundStarView.frame = self.bounds;//fix layout bug
    self.foregroundStarView.frame = self.bounds;//fix layout bug
    
    __weak CWStarRateView *weakSelf = self;
    CGFloat animationTimeInterval = self.hasAnimation ? ANIMATION_TIME_INTERVAL : 0;
    [UIView animateWithDuration:animationTimeInterval animations:^{
       weakSelf.foregroundStarView.frame = CGRectMake(0, 0, weakSelf.bounds.size.width * weakSelf.scorePercent, weakSelf.bounds.size.height);
    }];
    
    if (!hasLayout) {
        //以下为重新布局
        self.frame = CGRectMake(0, 0, self.referenceView.bounds.size.width, self.referenceView.bounds.size.height);

        self.foregroundStarView.frame = CGRectMake(0, 0, weakSelf.bounds.size.width * weakSelf.scorePercent, weakSelf.bounds.size.height);

        NSArray *foregroupImgs = self.foregroundStarView.subviews;
        for (NSInteger i = 0; i < foregroupImgs.count; i ++) {
            UIImageView *imageView = [foregroupImgs objectAtIndex:i];
            if (self.needAppositeColor) {
                [imageView setImage:[UIImage imageNamed:self.backgroundImageName?:BACKGROUND_STAR_IMAGE_NAME]];
            }
            [imageView setFrame:CGRectMake(i * self.bounds.size.width / self.numberOfStars, 0, self.bounds.size.width / self.numberOfStars, self.bounds.size.height)];
        }
        NSArray *backgroupImgs = self.backgroundStarView.subviews;
        for (NSInteger i = 0; i < backgroupImgs.count; i ++) {
            UIImageView *imageView = [backgroupImgs objectAtIndex:i];
            if (self.needAppositeColor) {
                [imageView setImage:[UIImage imageNamed:self.foregroundImageName?:FOREGROUND_STAR_IMAGE_NAME]];
            }
            [imageView setFrame:CGRectMake(i * self.bounds.size.width / self.numberOfStars, 0, self.bounds.size.width / self.numberOfStars, self.bounds.size.height)];
        }
//        hasLayout = YES;
    }
}

#pragma mark - Get and Set Methods

- (void)setScorePercent:(CGFloat)scroePercent {
    if (_scorePercent == scroePercent) {
        return;
    }
    
    if (scroePercent < 0) {
        _scorePercent = 0;
    } else if (scroePercent > 1) {
        _scorePercent = 1;
    } else {
        _scorePercent = scroePercent;
    }
    
    if ([self.delegate respondsToSelector:@selector(starRateView:scroePercentDidChange:)]) {
        [self.delegate starRateView:self scroePercentDidChange:scroePercent * 5];
    }
    
    [self setNeedsLayout];
}

@end
