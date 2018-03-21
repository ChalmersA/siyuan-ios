//
//  DCChargingAnimationView.m
//  Charging
//
//  Created by kufufu on 16/4/15.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCChargingAnimationView.h"
#import "PieSliceLayer.h"

#define PI 3.14159265358979323846
static inline float radians(double degrees) {
    return degrees * PI / 180;
}

@interface DCChargingAnimationView ()

@property (strong, nonatomic) PieSliceLayer *shapeLayer;

@property (weak, nonatomic) IBOutlet UIImageView *radioWaveImageView;
@property (strong, nonatomic) NSMutableArray *imageArray;

@end

@implementation DCChargingAnimationView

- (void)awakeFromNib {
//    _imageArray = [NSMutableArray array];
//    for (int i = 0; i < 15; i++) {
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"charge_%d.png", i]];
//        [_imageArray addObject:image];
//    }
}

- (void)startAnimation {
    NSLog(@"startAnimation~~~");
//    self.shapeLayer = [PieSliceLayer layer];
//    self.shapeLayer.frame = self.highLigthView.bounds;
//    self.shapeLayer.startAngle = radians(140);
//    self.shapeLayer.endAngle = radians(40);
//    self.shapeLayer.strokeColor = [UIColor redColor];
//    self.highLigthView.layer.mask = self.shapeLayer;
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.shapeLayer.endAngle = radians(400);
//    });
//    
//    self.radioWaveImageView.animationImages = self.imageArray;
//    self.radioWaveImageView.animationDuration = 0.5;
//    self.radioWaveImageView.animationRepeatCount = 0;
//    [self.radioWaveImageView startAnimating];
}

- (void)stopAnimation {
//    [self.radioWaveImageView stopAnimating];
}

@end
