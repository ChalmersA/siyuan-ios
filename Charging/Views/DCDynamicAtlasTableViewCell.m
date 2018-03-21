//
//  HSSYDynamicAtlasTableViewCell.m
//  Charging
//
//  Created by xpg on 15/9/16.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDynamicAtlasTableViewCell.h"
#import "UIImageView+WebCache.h"

#import "DCDynamicDetailsViewController.h"

@interface DCDynamicAtlasTableViewCell () <HSSYTopicDelegate>
@property (nonatomic) NSLayoutConstraint *imageViewConstraint;

@end

@implementation DCDynamicAtlasTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    //实例化
    self.topic = [[DCTopic alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen ].bounds.size.width, 200)];
    //代理
    self.topic.topicDelegate = self;
    //创建数据
    
    [self.dynamicImageView addSubview:self.topic];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)configureFordynamicTop:(NSArray*)dynamicTop{
    
    NSString *url = nil;
    NSMutableArray * tempArray = [[NSMutableArray alloc]init];
    UIImage * PlaceholderImage = [UIImage imageNamed:@"default_pile_image_long"];
    for (int inder = 0; inder < dynamicTop.count; inder ++) {
        DCDynamicDetailsList * dynamicDetailsListData = dynamicTop[inder];
        NSString *str = dynamicDetailsListData.coverImg;
        if ([str containsString:@"http:"]) {
            url = dynamicDetailsListData.coverImg;
        } else {
            url = [[NSString alloc] initWithString:[SERVER_URL stringByAppendingPathComponent:str]];
        }
        [tempArray addObject:[NSDictionary dictionaryWithObjects:@[url ,@NO, dynamicDetailsListData.dynamicId, PlaceholderImage, dynamicDetailsListData.sourceUrl, @(dynamicDetailsListData.sourceType)] forKeys:@[@"pic",@"isLoc",@"picID",@"placeholderImage", @"sourceUrl", @"sourceType"]]];
    }
    
    if (dynamicTop.count > 1) {
        self.page.hidden = NO;
    }else {
        self.page.hidden = YES;
    }
    //更新
    self.topic.pics = tempArray;
    [self.topic upDate];
}

#pragma mark HSSYTopicDelegate
-(void)didClick:(id)data {
    DDLogDebug(@"didClick--->Topic:%@",(NSArray*)data);
    NSString * arrayStr = [[NSString alloc]initWithFormat:@"%@",[data objectForKey:@"sourceUrl"]];
    DDLogDebug(@"\nURL:%@",arrayStr);
    [self.delegate didClickImageView:arrayStr sourceType:[[data objectForKey:@"sourceType"] integerValue]];//所定义的delegate方法
    
    [self.topic releaseTimer];//停止滑动
}

-(void)currentPage:(int)page total:(NSUInteger)total{
    self.page.numberOfPages = total;
    self.page.currentPage = page;
}

@end
