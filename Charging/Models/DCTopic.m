//
//  HSSYTopic.m
//  Charging
//
//  Created by xpg on 15/9/17.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCTopic.h"
#import "UIImageView+HSSYCatagory.h"
#define VIEW_BOUNDS [UIScreen mainScreen ].bounds.size
#define TIME_Interval 3
@implementation DCTopic
//@synthesize HSSYTopicdelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self setSelf];
    }
    return self;
}
-(void)setSelf{
    self.pagingEnabled = YES;
    self.scrollEnabled = YES;
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.backgroundColor = [UIColor whiteColor];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self setSelf];
    // Drawing code
}
-(void)upDate{
    NSMutableArray * tempImageArray = [[NSMutableArray alloc]init];
    
    if (!self.pics) {
        self.pics = [NSArray array];
    }else{
        [tempImageArray addObject:[self.pics lastObject]];
        for (id obj in self.pics) {
            [tempImageArray addObject:obj];
        }
        
        [tempImageArray addObject:[self.pics objectAtIndex:0]];
        
        self.pics = Nil;
        self.pics = tempImageArray;
    }
    int i = 0;
    for (id obj in self.pics) {
        pic= Nil;
        pic = [UIButton buttonWithType:UIButtonTypeCustom];
        pic.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [pic setFrame:CGRectMake(i*VIEW_BOUNDS.width,0, VIEW_BOUNDS.width, 200)];
        UIImageView * tempImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, VIEW_BOUNDS.width, pic.frame.size.height)];
        tempImage.contentMode = UIViewContentModeScaleAspectFill;
        [tempImage setClipsToBounds:YES];
        if ([[obj objectForKey:@"isLoc"]boolValue]) {
            [tempImage setImage:[obj objectForKey:@"pic"]];
        }else{
            [tempImage customSd_setImageWithURL:[NSURL URLWithString:[obj objectForKey:@"pic"]] placeholderImage:[obj objectForKey:@"placeholderImage"]];
        }
        [pic addSubview:tempImage];
        [pic setBackgroundColor:[UIColor grayColor]];
        pic.tag = i;
        [pic addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pic];
                
//        UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(i*VIEW_BOUNDS.width, self.frame.size.height-60, VIEW_BOUNDS.width,30)];
//        [title setBackgroundColor:[UIColor blackColor]];
//        //        [title sette
//        [title setAlpha:.5f];
//        [title setText:[NSString stringWithFormat:@" %@",[obj objectForKey:@"title"]]];
//        [title setTextColor:[UIColor whiteColor]];
//        [title setFont:[UIFont fontWithName:@"Helvetica" size:12]];
//        [self addSubview:title];
        i ++;
    }
    [self setContentSize:CGSizeMake(VIEW_BOUNDS.width*[self.pics count], self.frame.size.height)];
    [self setContentOffset:CGPointMake(VIEW_BOUNDS.width, 0) animated:NO];
    
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
        
    }
    [self setScrollTimer];
    
    
}
-(void)click:(id)sender{
    UIButton * button = sender;
    [self.topicDelegate didClick:[self.pics objectAtIndex:button.tag]];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat Width=VIEW_BOUNDS.width;
    if (scrollView.contentOffset.x == VIEW_BOUNDS.width) {
        flag = YES;
    }
    if (flag) {
        if (scrollView.contentOffset.x <= 0) {
            [self setContentOffset:CGPointMake(Width*([self.pics count]-2), 0) animated:NO];
        }else if (scrollView.contentOffset.x >= Width*([self.pics count]-1)) {
            [self setContentOffset:CGPointMake(VIEW_BOUNDS.width, 0) animated:NO];
        }
    }
    currentPage = scrollView.contentOffset.x/VIEW_BOUNDS.width-1;
    [self.topicDelegate currentPage:currentPage total:[self.pics count]-2];
    scrollTopicFlag = currentPage+2==2?2:currentPage+2;
    scrollView.scrollEnabled = self.pics.count<4?NO:YES; // 这里设置4张是因为滑动是多添加两张作为轮播头尾；
}
-(void)scrollTopic{
    [self setContentOffset:CGPointMake(VIEW_BOUNDS.width*scrollTopicFlag, 0) animated:YES];
    
    if (scrollTopicFlag > [self.pics count]) {
        scrollTopicFlag = 1;
    }else {
        scrollTopicFlag++;
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self setScrollTimer];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
    }
    
}

-(void)setScrollTimer {
    [self releaseTimer];
    if (self.pics.count > 3) {
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_Interval target:self selector:@selector(scrollTopic) userInfo:nil repeats:YES];
    }
}

-(void)releaseTimer{
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
        
    }
}

@end
