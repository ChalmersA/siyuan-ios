//
//  HSSYPoleShareCell.m
//  Charging
//
//  Created by xpg on 15/5/20.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPoleShareCell.h"
#import "DCPoleShareCellTimeView.h"

const CGFloat HSSYPoleShareCellTimeViewHeight = 50;

@implementation DCPoleShareCell

- (void)awakeFromNib {
    // Initialization code
    self.contentLabel.textColor = [UIColor paletteDCMainColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    [super setAccessoryType:accessoryType];
    self.trailingSpaceCons.constant = (accessoryType == UITableViewCellAccessoryNone)?20:0;
}

//TODO:价格显示
-(void)setContentLabel:(UILabel*)label WithPrice:(DCUVPrice *)price {
    NSString *defaultStr = @"";
    NSString *distanceSubfix = @"¥ ";
    NSString *tailStr = @"/kWh";
    
    // define colors
    UIColor *normalColor = [UIColor paletteNaviBgGrayColor];
    UIColor *numberColor = [UIColor paletteDCMainColor];
    // define font
    UIFont *normalFont = [UIFont systemFontOfSize:14];
    UIFont *numberFont = [UIFont systemFontOfSize:17];
    // define attribute
    NSDictionary *normalAttribs = @{NSForegroundColorAttributeName:normalColor, NSFontAttributeName:normalFont};
    NSDictionary *numberAttribs = @{NSForegroundColorAttributeName:numberColor, NSFontAttributeName:numberFont};
    
    if (price) {
        
        NSMutableArray *strArr = [NSMutableArray array];
        NSMutableArray *attriArr = [NSMutableArray array];
        
        [strArr addObject:distanceSubfix];
        [attriArr addObject:normalAttribs];
        
        [strArr addObject:[price stringOfPrice]];
        [attriArr addObject:numberAttribs];
        
        [strArr addObject:tailStr];
        [attriArr addObject:normalAttribs];
        
        [self joidStrings:strArr withAttributes:attriArr tolabel:label];
    }
    else {
        [self joidStrings:@[defaultStr] withAttributes:@[normalAttribs] tolabel:label];
    }
}

- (void)joidStrings:(NSArray*)strArr withAttributes:(NSArray*)attrArr tolabel:(UILabel*)targeLabel {
    if ([strArr count] != [attrArr count]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i< strArr.count; i++) {
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:strArr[i] attributes:attrArr[i]];
        [attributedText appendAttributedString:attrStr];
    }
    
    if ([targeLabel respondsToSelector:@selector(setAttributedText:)]) {
        targeLabel.attributedText = attributedText;
    }
    else {
        [targeLabel setText:attributedText.string];
    }
}



- (void)setPoleType:(HSSYPoleType)type {
    self.typeLabel.hidden = NO;
    self.typeLabel.backgroundColor = [UIColor digitalColorWithRed:243 green:159 blue:43];
    if (type == HSSYPoleTypeDC) {
        self.typeLabel.text = @"直";
    } else {
        self.typeLabel.text = @"交";
    }
}

- (void)setShareTimeArray:(NSArray *)timeArray conflictInfo:(NSDictionary *)conflictInfo {
    [self.timeView removeAllSubviews];
    for (NSInteger i = 0; i < timeArray.count; i++) {
        DCTime *time = timeArray[i];
        BOOL conflict = ([conflictInfo[time.timeId] count] > 0);
        DCPoleShareCellTimeView *view = [DCPoleShareCellTimeView loadFromNib];
        view.timeLabel.textColor = conflict ? [UIColor redColor] : [UIColor paletteDCMainColor];
        view.timeLabel.text = conflict ? [@"! " stringByAppendingString:time.timeFrameString] : time.timeFrameString;
        view.weekLabel.textColor = conflict ? [UIColor redColor] : [UIColor lightGrayColor];
        view.weekLabel.text = time.weekStringCN;
        view.bottomLine.hidden = (i == (timeArray.count - 1));
        [self.timeView addSubview:view];
        
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:HSSYPoleShareCellTimeViewHeight]];
        [self.timeView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.timeView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [self.timeView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.timeView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        [self.timeView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.timeView attribute:NSLayoutAttributeTop multiplier:1 constant:HSSYPoleShareCellTimeViewHeight * i]];
    }
}

+ (CGFloat)cellHeightForShareTimeArray:(NSArray *)timeArray {
    if (timeArray.count == 0) {
        return HSSYPoleShareCellTimeViewHeight;
    }
    return HSSYPoleShareCellTimeViewHeight * timeArray.count;
}

@end
