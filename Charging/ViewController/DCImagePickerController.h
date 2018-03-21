//
//  DCImagePickerController.h
//  Charging
//
//  Created by xpg on 15/1/27.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSKImageCropper.h"

typedef void(^ImagePickerCompletion)(UIImage *image, UIImage *originalImage);

@interface DCImagePickerController : UIImagePickerController
@property (copy, nonatomic) ImagePickerCompletion completion;
@property (assign, nonatomic) NSNumber *cropMode;//@(RSKImageCropMode)
@end
