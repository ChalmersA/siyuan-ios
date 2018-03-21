//
//  HSSYPeriodSpliteCollectionViewCell.m
//  CollectionViewTest
//
//  Created by  Blade on 4/24/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import "DCPeriodSpliteCollectionViewCell.h"
@interface DCPeriodSpliteCollectionViewCell() {
    
}
@property (assign, nonatomic) CGRect originalFrameOfCell;
@end

@implementation DCPeriodSpliteCollectionViewCell
//- (void)prepareForReuse {
//    [super prepareForReuse];
//}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.theme_color_selectedBackground = [UIColor paletteDCMainColor];
    self.theme_color_unSelected_label = [UIColor paletteFontDarkGrayColor];
    self.theme_color_selected_label = [UIColor whiteColor];
    self.theme_color_diable_label = [UIColor colorWithRed:0.718 green:0.714 blue:0.718 alpha:1.000];
    self.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
    
    // Avoid the warnning about autolayout constraints
    self.contentView.frame = self.bounds;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Select background
    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor = self.theme_color_selectedBackground;
    
    // init the view
    [self setSelected:NO];
    
//    // pdetail_periodDisable
//    // pdetail_periodNotSelet
//    // pdetail_periodSelect
//    UIImage *originalImage = [UIImage imageNamed:@"pdetail_periodSelect"];
//    UIEdgeInsets insets = UIEdgeInsetsMake(6, 68, 6, 140);
//    UIImage *stretchableImage = [originalImage resizableImageWithCapInsets:insets];
////    [myButton setBackgroundImage:stretchableImage forState:UIControlStateNormal];
//    self.backgroundView = [[UIImageView alloc] initWithImage:stretchableImage];
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    if (CGRectEqualToRect(self.originalFrameOfCell, self.frame) == false) {
//        self.layer.cornerRadius = self.frame.size.height/2;
////        self.layer.masksToBounds = NO;
////        self.layer.shouldRasterize = YES;
////        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        self.originalFrameOfCell = self.frame;
//    }
//}

- (void) setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateCellView:selected];
}

- (void) setEnabled:(BOOL)disabled {
    _enabled = disabled;
    [self setUserInteractionEnabled:self.enabled];
    [self updateCellView:self.selected];
}


- (void)setupPeriodStr:(NSString*) periodStr{
    self.labelSplitedPeriod.text = periodStr;
}

- (void)setupPeriod:(DCSharePeriod*)sharePeriod withIndex:(NSInteger)index {
    self.sharePeriod = sharePeriod;
    self.index = index;
    
    self.labelSplitedPeriod.text = [self.sharePeriod splitePeriodStringAtIndex:self.index];
    [self setEnabled:[self.sharePeriod canSelected:self.index]];
}

- (NSArray*)datesForBooking {
    return [self.sharePeriod datesOfPeriodWithIndex:self.index];
}

#pragma mark - utilies functions
- (void) updateCellView:(BOOL)isSelected {
    if (self.enabled) {
        if (isSelected) {
            self.labelSplitedPeriod.textColor = self.theme_color_selected_label;
//            self.layer.borderWidth = 0;
//            self.layer.borderColor = [UIColor clearColor].CGColor;
            self.imageIcon.image = [UIImage imageNamed:@"pdetail_periodSelect"];
        }
        else {
            self.labelSplitedPeriod.textColor = self.theme_color_unSelected_label;
//            self.layer.borderWidth = 2;
//            self.layer.borderColor = self.theme_color_unSelected_label.CGColor;
            self.imageIcon.image = [UIImage imageNamed:@"pdetail_periodDisable"];
        }
    }
    else {
        self.labelSplitedPeriod.textColor = self.theme_color_diable_label;
//        self.layer.borderWidth = 2;
//        self.layer.borderColor = self.theme_color_diable_label.CGColor;
        self.imageIcon.image = [UIImage imageNamed:@"pdetail_periodDisable"];
    }
    
}
@end
