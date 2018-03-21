//
//  ScanQrcodeView.m
//  ScanQrcode
//
//  Created by chenzhibin on 15/10/29.
//  Copyright © 2015年 chenzhibin. All rights reserved.
//

#import "ScanQrcodeView.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanQrcodeView () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureMetadataOutput *output;

@property (nonatomic) UIView *captureView;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) CAShapeLayer *maskLayer;

@property (weak, nonatomic) IBOutlet UIImageView *boundaryView;
@property (nonatomic) UIImageView *scanLine;
@end

@implementation ScanQrcodeView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.captureView.frame = self.bounds;
    self.previewLayer.frame = self.captureView.bounds;
    self.maskLayer.frame = self.captureView.bounds;
    
    [self updateMaskLayer];
    [self updateScanLine];
}

- (void)setup {
    if ([self setupCaptureSession]) {
        [self addPreviewLayer];
        [self addMaskLayer];
    }
}

- (BOOL)setupCaptureSession {
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (input) {
        [session addInput:input];
    }
    else {
        [self.delegate scanError:error];
        return NO;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [session addOutput:output];
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output = output;
    
    self.session = session;
    return YES;
}

- (void)addPreviewLayer {
    self.captureView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.captureView];
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.captureView.layer addSublayer:previewLayer];
    previewLayer.frame = self.layer.bounds;
    self.previewLayer = previewLayer;
}

- (void)addMaskLayer {
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    maskLayer.opacity = 0.5;
    [self.captureView.layer addSublayer:maskLayer];
    maskLayer.frame = self.layer.bounds;
    self.maskLayer = maskLayer;
    
    [self updateMaskLayer];
}

- (void)updateMaskLayer {
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.maskLayer.bounds];
    [path appendPath:[UIBezierPath bezierPathWithRect:self.boundaryView.frame]];
    layer.path = path.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.fillColor = [UIColor blackColor].CGColor;
    self.maskLayer.mask = layer;
    
    CGFloat height = CGRectGetHeight(self.maskLayer.frame);
    CGFloat width = CGRectGetWidth(self.maskLayer.frame);
    CGRect rect = self.boundaryView.frame;
    CGRect interestRect = CGRectMake(CGRectGetMinY(rect)/height, CGRectGetMinX(rect)/width, CGRectGetHeight(rect)/height, CGRectGetWidth(rect)/width);
    [self.output setRectOfInterest:interestRect];
}

- (void)awakeFromNib {
    [self sendSubviewToBack:self.captureView];
    self.scanLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_line"]];
}

- (void)startScan {
    [self.session startRunning];
    [self updateScanLine];
    self.isScan = YES;
}

- (void)stopScan {
    [self.session stopRunning];
    [self updateScanLine];
    self.isScan = NO;
}

- (void)updateScanLine {
    if (self.session.isRunning) {
        if (!self.scanLine.superview) {
            [self.boundaryView addSubview:self.scanLine];
        }
        CABasicAnimation* theAnim;
//        theAnim = (CABasicAnimation*)[self.scanLine.layer animationForKey:@"AnimateFrame"];
//        if (theAnim && [theAnim isKindOfClass:[CABasicAnimation class]]) {
//            [theAnim autoDescription];
//        }
//        else {
//            CGRect frame = self.boundaryView.bounds;
//            frame.size.height = 4;
//            self.scanLine.frame = frame;
//            
//            theAnim = [CABasicAnimation animationWithKeyPath:@"position"];
//            theAnim.fromValue = [NSValue valueWithCGPoint:self.scanLine.layer.position];
//            CGPoint newPosition = CGPointMake(self.scanLine.layer.position.x, CGRectGetHeight(self.boundaryView.bounds) - CGRectGetHeight(frame));
//            theAnim.toValue = [NSValue valueWithCGPoint:newPosition];
//            theAnim.duration = 3.0;
//            theAnim.autoreverses = YES;
//            theAnim.repeatCount = MAXFLOAT;
//            [self.scanLine.layer addAnimation:theAnim forKey:@"AnimateFrame"];
//        }
        
        CGRect frame = self.boundaryView.bounds;
        frame.size.height = 4;
        self.scanLine.frame = frame;
        
        theAnim = [CABasicAnimation animationWithKeyPath:@"position"];
        theAnim.fromValue = [NSValue valueWithCGPoint:self.scanLine.layer.position];
        CGPoint newPosition = CGPointMake(self.scanLine.layer.position.x, CGRectGetHeight(self.boundaryView.bounds) - CGRectGetHeight(frame));
        theAnim.toValue = [NSValue valueWithCGPoint:newPosition];
        theAnim.duration = 1.0;
        theAnim.autoreverses = YES;
        theAnim.repeatCount = HUGE_VALF;
        [self.scanLine.layer addAnimation:theAnim forKey:@"AnimateFrame"];
        
//        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
//            CGRect frame = self.scanLine.frame;
//            frame.origin.y = CGRectGetHeight(self.boundaryView.bounds) - CGRectGetHeight(frame);
//            self.scanLine.frame = frame;
//        } completion:^(BOOL finished) {
//        
//        }];
    } else {
        [self.scanLine removeFromSuperview];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects firstObject];
    if ([metadataObj.type isEqualToString:AVMetadataObjectTypeQRCode]) {
        NSString *result = metadataObj.stringValue;
        if (result) {
//            NSArray *array = [result componentsSeparatedByString:@"pileId="];
//            NSString *pileId = [array lastObject];
//            [self.delegate scanSuccess:pileId];
            [self.delegate scanSuccess:result];
            [self stopScan];
        }
    }
}

@end
