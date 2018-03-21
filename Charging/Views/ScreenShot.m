//
//  ScreenShot.m
//  MyShowCase
//
//  Created by kufufu on 15/7/28.
//  Copyright (c) 2015年 Wikky. All rights reserved.
//

#import "ScreenShot.h"

@implementation ScreenShot
-(UIImage*)screenShot:(id)view {
    
    UIImage* viewImage = nil;
    
    if ([view isKindOfClass:[UITableView class]]) {
        UITableView *scrollView = view;
        //    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, scrollView.opaque, [UIScreen mainScreen].scale);
        UIGraphicsBeginImageContext(scrollView.contentSize);
        {
            CGPoint savedContentOffset = scrollView.contentOffset;
            CGRect savedFrame = scrollView.frame;
            
            scrollView.contentOffset = CGPointZero;
            scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
            
            [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
            viewImage = UIGraphicsGetImageFromCurrentImageContext();
            
            scrollView.contentOffset = savedContentOffset;
            scrollView.frame = savedFrame;
        }
        UIGraphicsEndImageContext();
    }
    
    if ([view isKindOfClass:[UIView class]]) {
        UIView *shotView = view;
        UIGraphicsBeginImageContext(shotView.frame.size);
        [shotView.layer renderInContext:UIGraphicsGetCurrentContext()];
        viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    self.screenImage = viewImage;
    // 把截图后的图片存在了本地相册里面
//    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    return viewImage;
}

- (NSString *)savePictureToDocument {
    //存图片
    NSData *imageData = UIImagePNGRepresentation(self.screenImage);
    //获取沙盒路径
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"shareImage.png"];
    [imageData writeToFile:fullPath atomically:NO];
    
    return fullPath;
}
@end
