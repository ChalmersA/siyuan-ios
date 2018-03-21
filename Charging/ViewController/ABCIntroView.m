//
//  IntroView.m
//  DrawPad
//
//  Created by Adam Cooper on 2/4/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

#import "ABCIntroView.h"

@interface ABCIntroView () <UIScrollViewDelegate>
@property (strong, nonatomic)  UIScrollView *scrollView;
//@property (strong, nonatomic)  UIPageControl *pageControl;
@property UIView *holeView;
@property UIView *circleView;
@property UIButton *doneButton;

@end

@implementation ABCIntroView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
//        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
//        backgroundImageView.image = [UIImage imageNamed:@"Intro_Screen_Background"];
//        [self addSubview:backgroundImageView];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        self.scrollView.bounces = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        
//        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.8, self.frame.size.width, 10)];
//        self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.153 green:0.533 blue:0.796 alpha:1.000];
////        [self addSubview:self.pageControl];
    
        [self createViewOne];
        [self createViewTwo];
        [self createViewThree];
        
        
        
            
        
//        self.pageControl.numberOfPages = 3;
        self.scrollView.contentSize = CGSizeMake(self.frame.size.width*3, self.scrollView.frame.size.height);
        
        //This is the starting point of the ScrollView
        CGPoint scrollPoint = CGPointMake(0, 0);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
    return self;
}

- (void)onFinishedIntroButtonPressed:(id)sender {
    [self.delegate onDoneButtonPressed];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    CGFloat pageWidth = CGRectGetWidth(self.bounds);
//    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
//    self.pageControl.currentPage = roundf(pageFraction);
    
}


-(void)createViewOne{
    
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
//    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
//    titleLabel.text = [NSString stringWithFormat:@"Pixifly"];
//    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.textAlignment =  NSTextAlignmentCenter;
//    titleLabel.numberOfLines = 0;
//    [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    imageview.image = [UIImage imageNamed:@"intro_1"];
    if (screenSize() == Screen_iPhone) {
        imageview.image = [UIImage imageNamed:@"intro_1_i4"];
    }
    
    [view addSubview:imageview];
    [view setClipsToBounds:YES];
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}


-(void)createViewTwo{
    
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth, 0, originWidth, originHeight)];
    
    //    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
    //    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    //    titleLabel.text = [NSString stringWithFormat:@"Pixifly"];
    //    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
    //    titleLabel.textColor = [UIColor whiteColor];
    //    titleLabel.textAlignment =  NSTextAlignmentCenter;
    //    titleLabel.numberOfLines = 0;
    //    [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    imageview.image = [UIImage imageNamed:@"intro_2"];
    if (screenSize() == Screen_iPhone) {
        imageview.image = [UIImage imageNamed:@"intro_2_i4"];
    }
    
    [view addSubview:imageview];
    [view setClipsToBounds:YES];
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}

-(void)createViewThree{
    
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth*2, 0, originWidth, originHeight)];
    
    //    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
    //    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    //    titleLabel.text = [NSString stringWithFormat:@"Pixifly"];
    //    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
    //    titleLabel.textColor = [UIColor whiteColor];
    //    titleLabel.textAlignment =  NSTextAlignmentCenter;
    //    titleLabel.numberOfLines = 0;
    //    [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    imageview.image = [UIImage imageNamed:@"intro_3"];
    if (screenSize() == Screen_iPhone) {
        imageview.image = [UIImage imageNamed:@"intro_3_i4"];
    }
    
    [view addSubview:imageview];
    [view setClipsToBounds:YES];
    
//    //Done Button
//    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.85, self.frame.size.width*.8, 60)];
//    [self.doneButton setTintColor:[UIColor whiteColor]];
//    [self.doneButton setTitle:@"Let's Go!" forState:UIControlStateNormal];
//    [self.doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0]];
//    self.doneButton.backgroundColor = [UIColor colorWithRed:0.153 green:0.533 blue:0.796 alpha:1.000];
//    self.doneButton.layer.borderColor = [UIColor colorWithRed:0.153 green:0.533 blue:0.796 alpha:1.000].CGColor;
//    [self.doneButton addTarget:self action:@selector(onFinishedIntroButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    self.doneButton.layer.borderWidth =.5;
//    self.doneButton.layer.cornerRadius = 15;
//    [view addSubview:self.doneButton];
    
    //Done Button
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    [self.doneButton setBackgroundImage:[UIImage imageNamed:@"intro_button"] forState:UIControlStateNormal];
//    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.doneButton setTitle:@"马上体验" forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(onFinishedIntroButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.doneButton];
    
    self.doneButton.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetHeight(view.bounds) - 88);
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
}


-(void)createViewFour{
    
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth*3, 0, originWidth, originHeight)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    titleLabel.text = [NSString stringWithFormat:@"Punctual"];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.1, self.frame.size.width*.8, self.frame.size.width)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:@"Intro_Screen_Two"];
    [view addSubview:imageview];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:@"Intro_Screen_Four"];
    [view addSubview:imageview];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.7, self.frame.size.width*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Description for Fourth Screen."];
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    [view addSubview:descriptionLabel];
    
    CGPoint labelCenter = CGPointMake(self.center.x, self.frame.size.height*.7);
    descriptionLabel.center = labelCenter;
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}

@end