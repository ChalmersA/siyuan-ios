//
//  CarouselView.m
//  循环播图
//
//  Created by lanou on 15/7/23.
//  Copyright (c) 2015年 lanou. All rights reserved.
//

#import "CarouselView.h"
#import "UIImageView+HSSYSDWebImageCategory.h"
#import "DCDynamicDetailsList.h"

@interface CarouselView()<UIScrollViewDelegate>

@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)UIPageControl *pageControl;
//@property(nonatomic, strong)UILabel *textLabel;
@property(nonatomic, assign)NSInteger curPage;
@property(nonatomic, strong)NSMutableArray *curArray;
@property(nonatomic, assign)CGFloat width;
@property(nonatomic, assign)CGFloat height;
@property(nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong) DCDynamicDetailsList *cur;

//@property (copy, nonatomic) NSString *url;

@end

@implementation CarouselView

-(instancetype)initWithFrame:(CGRect)frame
{
    // 设置宽 高(这样就可以在外面直接设置到滚动画面的大小了)
    _width = frame.size.width;
    _height = frame.size.height;
    if (self = [super initWithFrame:frame]) {
        [self initWithScrollView];
        [self initWithPageControl];
//        [self initWithTextLabel];
    }
    return self;
}
// 初始化scrollview
-(void)initWithScrollView
{
    // 初始化
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _width, _height)];
    // 设置分页
    _scrollView.pagingEnabled = YES;
    // 设置滑动区域
    _scrollView.contentSize = CGSizeMake(_width * 3, 0);
    // 取消滚动条的
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    // 签订代理
    _scrollView.delegate = self;
    // 设置当前显示的位置
    _scrollView.contentOffset = CGPointMake(_width, 0);
    
    self.curArray = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(_width * i, 0, _width, _height)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTheImageView)];
        [imageV addGestureRecognizer:tap];
        imageV.userInteractionEnabled = YES;
        [_scrollView addSubview:imageV];
    }
    // 添加scorllView到主页面上
    [self addSubview:_scrollView];
}
// 初始化pageControl
-(void)initWithPageControl
{
    // 初始化
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(_width / 2 - 35, _height - 30, 70, 30)];
    [self addSubview:self.pageControl];
}
// 初始化textlabel
//-(void)initWithTextLabel
//{
//    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _height - 40, _width - 100, 40)];
//    _textLabel.textColor = [UIColor greenColor];
//    [self addSubview:self.textLabel];
//}
// 传数据
-(void)setArray:(NSArray *)array
{   // 我的数据源等于传递过来的数据源
    _array = array;
    [self updateCurViewWithPage:0];
    self.pageControl.numberOfPages = [self.array count];
    // 设置定时器来自动播放
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(autoPlay) userInfo:nil repeats:YES];
}
#pragma -mark  定时器的方法
-(void)autoPlay
{   // 这里使用setContentOffset这个方法可以使滑动时加入动画
    [self.scrollView setContentOffset:CGPointMake(_width * 2, 0) animated:YES];
}

// 获取索引
-(NSInteger)updateCurpage:(NSInteger)page
{
    return (self.array.count + page) % self.array.count;
}

// 替换数据源
-(void)updateCurViewWithPage:(NSInteger)page
{
    NSString *url = nil;
    // 获取到显示上一张图片的索引
    NSInteger pre = [self updateCurpage:page - 1];
    // 获取到显示当前页的图片的索引
    _curPage = [self updateCurpage:page];
    // 获取显示下一张图片的索引
    NSInteger last = [self updateCurpage:page + 1];
    // 删除数组里的元素
    [self.curArray removeAllObjects];

    // 获取我当前像是的三张图片
    [self.curArray addObject:self.array[pre]];
    [self.curArray addObject:self.array[_curPage]];
    [self.curArray addObject:self.array[last]];
    // 获取scrollView的所有子视图
    NSArray *arrays = _scrollView.subviews;
    for (int i = 0; i < 3; i++) {
        UIImageView *imageV = arrays[i];
        imageV.contentMode = UIViewContentModeScaleAspectFill;
        self.cur = self.curArray[i];
        if ([self.cur.coverImg containsString:@"http:"]) {
            url = self.cur.coverImg;
        } else {
            url = [[NSString alloc] initWithString:[SERVER_URL stringByAppendingPathComponent:self.cur.coverImg]];
        }
        [imageV hssy_sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"default_pile_image_long"] completed:nil];
//        if (i == 1) {
//            self.textLabel.text = self.cur.sourceUrl;
//        }
    }
    // 设置当前显示的位置
    self.scrollView.contentOffset = CGPointMake(_width, 0);
    // 设置pageControl当前显示的索引
    self.pageControl.currentPage = self.curPage;
}
// 每次滑动完成后
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat x = _scrollView.contentOffset.x;
    // 向右滑动
    if(x >= _width * 2)
    {
        [self updateCurViewWithPage:_curPage + 1];
    }else if(x == 0) // 向左滑动
    {
        [self updateCurViewWithPage:_curPage - 1];
    }
}
// 开始拖拽
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 关闭定时器
    [self.timer invalidate];
    self.timer = nil;
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // 重新打开定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(autoPlay) userInfo:nil repeats:YES];
}

#pragma mark - Action
- (void)clickTheImageView {
    if ([self.delegate respondsToSelector:@selector(clickTheTopOfImageViewWithUrl:sourceType:)]) {
        DCDynamicDetailsList *a = self.array[self.curPage];
        [self.delegate clickTheTopOfImageViewWithUrl:a.sourceUrl sourceType:a.sourceType];
    }
}

@end
