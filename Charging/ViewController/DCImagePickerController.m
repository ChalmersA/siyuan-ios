//
//  HSSYImagePickerController.m
//  Charging
//
//  Created by xpg on 15/1/27.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCImagePickerController.h"

@interface DCImagePickerController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource>
@property (strong, nonatomic) UIImage *originalImage;
@end

@implementation DCImagePickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    if (self.cropMode) {
        RSKImageCropMode mode = [self.cropMode integerValue];
        RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:mode];
        imageCropVC.delegate = self;
        imageCropVC.dataSource = self;
        imageCropVC.moveAndScaleLabel.text = @"移动和缩放";
        [imageCropVC.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [imageCropVC.chooseButton setTitle:@"确定" forState:UIControlStateNormal];
        [self pushViewController:imageCropVC animated:YES];
    } else {
        if (self.completion) {
            self.completion(image, image);
        }
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - RSKImageCropViewControllerDataSource
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller {
    CGSize maskSize;
    if ([controller isPortraitInterfaceOrientation]) {
        maskSize = CGSizeMake(250, 250);
    } else {
        maskSize = CGSizeMake(220, 220);
    }
    
//    CGFloat viewWidth = CGRectGetWidth(controller.view.frame);
    CGFloat viewHeight = CGRectGetHeight(controller.view.frame);
    
    CGRect maskRect = CGRectMake(0,
                                 (viewHeight - maskSize.height) * 0.5f - 40,
                                 self.view.bounds.size.width,
                                 self.view.bounds.size.width/2);
    
    return maskRect;
}

-(UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller {
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, controller.maskRect.size.height, self.view.bounds.size.width, self.view.bounds.size.width/2) cornerRadius:0];

    return roundedRect;
}
#pragma mark - RSKImageCropViewControllerDelegate
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self popToRootViewControllerAnimated:YES];
    }
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller willCropImage:(UIImage *)originalImage {
    self.originalImage = originalImage;
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect {
    [self imageCropViewController:controller didCropImage:croppedImage];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect rotationAngle:(CGFloat)rotationAngle {
    [self imageCropViewController:controller didCropImage:croppedImage];
}

#pragma mark - Extension
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage {
    if (self.completion) {
        self.completion(croppedImage, self.originalImage);
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
