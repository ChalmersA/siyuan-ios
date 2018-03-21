//
//  PagedImageScrollView.m
//  Test
//
//  Created by jianpx on 7/11/13.
//  Copyright (c) 2013 PS. All rights reserved.
//

#import "PagedImageScrollView.h"
#import "UIColor+HSSYColor.h"
#import "UIImage+HSSYCategory.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+HSSYCatagory.h"
#import "KZImageViewer.h"
#import "KZImage.h"
#import "NSURL+HSSYImage.h"

@interface PagedImageScrollView() <UIScrollViewDelegate>
@property (nonatomic) BOOL pageControlIsChangingPage;
@property (nonatomic, retain) NSMutableArray *imageViews;
@end

@implementation PagedImageScrollView
@synthesize scrollViewHeightConstraint;

#define PAGECONTROL_DOT_WIDTH 20
#define PAGECONTROL_HEIGHT 20
-(void)awakeFromNib {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    self.scrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    [self addSubview:self.scrollView];
    //    NSMutableArray * tempConstraints = [NSMutableArray array];
    //    [tempConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:0 views:paramDic]];
    //    [tempConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:0 views:paramDic]];
    //    [self addConstraints:tempConstraints];
    NSLayoutConstraint *scrollViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView
                                                                               attribute:NSLayoutAttributeBottom
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1.0f
                                                                                constant:0.f];
    
    NSLayoutConstraint *scrollViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView
                                                                               attribute:NSLayoutAttributeLeading
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeLeading
                                                                              multiplier:1.0f
                                                                                constant:0.];
    
    NSLayoutConstraint *scrollViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeTrailing
                                                                              multiplier:1.0f
                                                                                constant:0.];
    
    self.scrollViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0f
                                                                    constant:self.frame.size.width / self.constraitImagePageViewRatio.multiplier];
    [self addConstraints:@[scrollViewBottomConstraint,scrollViewLeadingConstraint,scrollViewTrailingConstraint,self.scrollViewHeightConstraint]];
    
    
    
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints  = NO;
    NSDictionary *paramDic = NSDictionaryOfVariableBindings(_scrollView,_contentView);
    [self.scrollView  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|" options:0 metrics: 0 views:paramDic]];
    [self.scrollView  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" options:0 metrics: 0 views:paramDic]];
//    NSLayoutConstraint *constrainContentViewBottom = [NSLayoutConstraint constraintWithItem:self.contentView
//                                                                                  attribute:NSLayoutAttributeBottom
//                                                                                  relatedBy:NSLayoutRelationEqual
//                                                                                     toItem:self.scrollView
//                                                                                  attribute:NSLayoutAttributeBottom
//                                                                                 multiplier:1.0f
//                                                                                   constant:0.f];
//    [self.scrollView addConstraint:constrainContentViewBottom];
    NSLayoutConstraint *contentViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.scrollView
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0f
                                                          constant:0.0f];
    [self.scrollView  addConstraint:contentViewHeightConstraint];
    
    self.pageControl = [[UIPageControl alloc] init];
    [self setDefaults];
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];
    self.pageControl.translatesAutoresizingMaskIntoConstraints  = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_pageControl  attribute:NSLayoutAttributeCenterX  relatedBy:NSLayoutRelationEqual  toItem:self  attribute:NSLayoutAttributeCenterX  multiplier:1  constant:0 ] ] ;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl]-0-|" options:0 metrics: 0 views:NSDictionaryOfVariableBindings(_pageControl)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_pageControl(==20)]" options:0 metrics: 0 views:NSDictionaryOfVariableBindings(_pageControl)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl(==20)]" options:0 metrics: 0 views:NSDictionaryOfVariableBindings(_pageControl)]];
    self.scrollView.delegate = self;
    
    self.imageViews = [NSMutableArray array];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        [self.scrollView setBackgroundColor:[UIColor whiteColor]];
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touched:)];
        [self.scrollView addGestureRecognizer:singleFingerTap];
        self.pageControl = [[UIPageControl alloc] init];
        [self setDefaults];
        [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
        self.scrollView.delegate = self;
    }
    return self;
}




- (void)setPageControlPos:(enum PageControlPosition)pageControlPos
{
    CGFloat width = PAGECONTROL_DOT_WIDTH * self.pageControl.numberOfPages;
    _pageControlPos = pageControlPos;
    if (pageControlPos == PageControlPositionRightCorner)
    {
        self.pageControl.frame = CGRectMake(self.scrollView.frame.size.width - width, self.scrollView.frame.size.height - PAGECONTROL_HEIGHT, width, PAGECONTROL_HEIGHT);
    }else if (pageControlPos == PageControlPositionCenterBottom)
    {
        self.pageControl.frame = CGRectMake((self.scrollView.frame.size.width - width) / 2, self.scrollView.frame.size.height - PAGECONTROL_HEIGHT, width, PAGECONTROL_HEIGHT);
    }else if (pageControlPos == PageControlPositionLeftCorner)
    {
        self.pageControl.frame = CGRectMake(0, self.scrollView.frame.size.height - PAGECONTROL_HEIGHT, width, PAGECONTROL_HEIGHT);
    }

}



- (void)setDefaults
{
    self.pageControl.currentPageIndicatorTintColor = [UIColor paletteDCMainColor];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.hidesForSinglePage = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.pageControlPos = PageControlPositionRightCorner;
}


- (void)setScrollViewContents: (NSArray *)images
{
    for (UIView *imageView in self.imageViews) {
        [imageView removeFromSuperview];
    }
    [self.imageViews removeAllObjects];
    
    if (images && [images count]>0) {
        [self.labelHint setHidden:YES];
        [self.scrollView setHidden:NO];
        [self setHidden:NO];
        
//        self.scrollViewHeightConstraint.constant = self.frame.size.width / self.constraitImagePageViewRatio.multiplier;
        self.scrollViewHeightConstraint.constant = _imageTouchHandle == ImageTouchPush ? self.frame.size.height : self.frame.size.width / self.constraitImagePageViewRatio.multiplier;
        
        UIImageView* lastImageView = nil;
        for (int i = 0; i < images.count; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * i, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
            if ([images[i] isKindOfClass:[UIImage class]]) {
                [imageView setImage:images[i]];
            }
            else if([images[i] isKindOfClass:[NSString class]]) {
                [imageView customSd_setImageWithURL:[NSURL URLWithImagePath:images[i]] placeholderImage:[UIImage imageNamed:@"default_pile_image_long"]];
            }
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setClipsToBounds:YES];
            [self.contentView addSubview:imageView];
            [self.imageViews addObject:imageView];
            
            // 添加点击监听
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touched:)];
            [imageView addGestureRecognizer:singleFingerTap];
            
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSDictionary *paramDic = nil;
            if (lastImageView) {
                paramDic = NSDictionaryOfVariableBindings(_scrollView ,_contentView, imageView, lastImageView);
                [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[lastImageView]-0-[imageView]" options:0 metrics:0 views:paramDic]];
            }
            else {
                paramDic = NSDictionaryOfVariableBindings(_scrollView, _contentView, imageView);
                [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]" options:0 metrics:0 views:paramDic]];
            }
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]" options:0 metrics:0 views:paramDic]];
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(==_scrollView)]" options:0 metrics:0 views:paramDic]];
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(==_scrollView)]" options:0 metrics:0 views:paramDic]];
            lastImageView = imageView;
        }
        
        if (lastImageView) {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[lastImageView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(lastImageView)]];
        }
        
        self.pageControl.numberOfPages = images.count;
    }
    else {
        [self.labelHint setHidden:NO];
        [self.scrollView setHidden:YES];
        self.pageControl.numberOfPages = 0;
//        self.constraitImagePageViewRatio.multiplier = @(0.00000001);
        [self setHidden:YES];
    }
    
    //call pagecontrolpos setter.
    self.pageControlPos = self.pageControlPos;
}

- (void)setImageScrollViewHeight:(CGFloat)height {
    CGFloat targetHeight = MAX((self.frame.size.width / self.constraitImagePageViewRatio.multiplier - height),0);
    self.scrollViewHeightConstraint.constant = targetHeight;
}

- (void)changePage:(UIPageControl *)sender
{
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    self.pageControlIsChangingPage = YES;
}
- (void)touched:(UITapGestureRecognizer *)sender
{
    
    if (_imageTouchHandle == ImageTouchPush) {
        NSLog(@"ImageTouchPush");
        [_pushVC performSegueWithIdentifier:_SegueWithIdentifier sender:nil];
    }else{
        NSLog(@"Touched");
        //当前UIImageView 有图片才会显示
        UIImage *currentImage = [(UIImageView *)sender.view image];
        if (!currentImage)
        {
            return;
        }
        
        NSMutableArray  *kzImageArray = [NSMutableArray array];
        for (int i = 0; i < [self.imageViews count]; i++)
        {
            UIImageView *imageView = [self.imageViews objectAtIndex:i];
            KZImage *kzImage = [[KZImage alloc] initWithImage:imageView.image];
            kzImage.thumbnailImage = imageView.image;
            kzImage.srcImageView = imageView;
            [kzImageArray addObject:kzImage];
        }
        KZImageViewer *imageViewer = [[KZImageViewer alloc] init];
        [imageViewer showImages:kzImageArray atIndex:[self.imageViews indexOfObject:(UIImageView *)sender.view]];
    }
}

#pragma scrollviewdelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.pageControlIsChangingPage) {
        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    //switch page at 50% across
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControlIsChangingPage = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.pageControlIsChangingPage = NO;
}

@end
