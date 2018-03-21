//
//  HSSYPoleAnnotationView.m
//  Charging
//
//  Created by xpg on 15/4/23.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPoleAnnotationView.h"
#import "DCPoleMapAnnotation.h"
#import "UIImage+HSSYCategory.h"
#import "UIView+HSSYView.h"

@interface DCPoleAnnotationView ()
@property (strong, nonatomic) UILabel *textLabel;
@end

@implementation DCPoleAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.canShowCallout = NO;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:textLabel];
        _textLabel = textLabel;
        
        if (self.poleAnnotation) {
            [self configForAnnotation:self.poleAnnotation selected:self.selected];
        }
    }
    return self;
}

- (DCPoleMapAnnotation *)poleAnnotation {
    if ([self.annotation isKindOfClass:[DCPoleMapAnnotation class]]) {
        return self.annotation;
    }
    return nil;
}

- (void)configForAnnotation:(DCPoleMapAnnotation *)annotation selected:(BOOL)selected {
    DCStation *station = annotation.station;
    
    UIImage *image = [UIImage imageNamed:@"map_logo"];
    self.image = image;
    
    // make it directly "point" to the location
    float thePointingYInImage = 96.0;
    float theImageHeight = 121.0;
    self.centerOffset = CGPointMake(0, -(self.image.size.height*(thePointingYInImage/theImageHeight - 1.0/2)));
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.poleAnnotation) {
        [self configForAnnotation:self.poleAnnotation selected:selected];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectInset(self.bounds, CGRectGetWidth(self.bounds) * 0.2, CGRectGetHeight(self.bounds) * 0.3);
    self.textLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) * 0.4);
}

@end
