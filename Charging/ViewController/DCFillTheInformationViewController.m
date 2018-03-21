//
//  DCFillTheInformationViewController.m
//  Charging
//
//  Created by xpg on 15/9/22.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCFillTheInformationViewController.h"
#import "DCPoleImageControl.h"
#import "IQTextView.h"

#import "DCListView.h"
#import "PopUpView.h"
#import "DCPeriodTableViewCell.h"

#import "DCImagePickerController.h"
#import "KZPhotoBrowser.h"
#import "Charging-Swift.h"

#import "DCSiteApi.h"
#import "DCUser.h"
#import <MBProgressHUD/MBProgressHUD.h>

#import "DCColorButton.h"

#import "DCAddSuccessViewController.h"

typedef NS_ENUM(NSInteger, DCPileStandingType) {
    pile = 1,
    standing = 2
};

#define STANDINGTYPEHEIGHT 30
#define PILETEPYHEIGHT 70

static NSString *kCellIdentifier = @"DCPeriodTableViewCell";
static NSString *DCFillTheInformationVC = @"DCAddSuccessViewController";


@interface DCFillTheInformationViewController () <UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, HSSYListViewDelegate, UITableViewDelegate, KZPhotoBrowserDelegate> {
    DCListView *listView;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkAddressButton;//返回地图

@property (weak, nonatomic) IBOutlet UIButton *stationTypeButton;//桩群类型
@property (weak, nonatomic) IBOutlet UIButton *runningStateButton;//桩群状态

//站
@property (weak, nonatomic) IBOutlet DCPoleImageControl *imageView1;
@property (weak, nonatomic) IBOutlet DCPoleImageControl *imageView2;
@property (weak, nonatomic) IBOutlet DCPoleImageControl *imageView3;
@property (weak, nonatomic) IBOutlet DCPoleImageControl *imageView4;
@property (weak, nonatomic) IBOutlet DCPoleImageControl *imageView5;

@property (weak, nonatomic) IBOutlet UITextField *vendorNameTextFieled;//桩群名字
@property (weak, nonatomic) IBOutlet UIView *pileDescribeView;
@property (weak, nonatomic) IBOutlet DCTextView *pileDescribeTextView;//描述

@property (assign, nonatomic) DCPileStandingType pileType; // 选择桩或站
@property (nonatomic, strong) ArrayDataSource *periodSource;
@property (weak, nonatomic) PopUpView *popUpView;

@property (strong, nonatomic) NSString *popUpViewTitle;
@property (strong, nonatomic) NSArray *dataArr;

@property (assign, nonatomic) NSInteger runningStatus;
@property (assign, nonatomic) NSInteger stationType;

@property (strong, nonatomic) UIButton *stateTypeButton; //设置状态

@property (copy, nonatomic) NSArray *photoImgs;
@property (strong, nonatomic) NSMutableArray *browserPhotosUrl;

@property (strong,nonatomic) DCUser *user;
@end

@implementation DCFillTheInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _pileType = pile;
    self.pileDescribeTextView.delegate = self;
    self.pileDescribeTextView.placeholder = @"桩群描述";
    self.pileDescribeTextView.scrollsToTop = NO;
    
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;//释放键盘
    
    self.browserPhotosUrl = [NSMutableArray array];
    [self placeholderImages:nil ImageNumber:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.browserPhotosUrl.count) {
        [self placeholderImages:self.browserPhotosUrl ImageNumber:self.browserPhotosUrl.count];
    }
    
    _addressLabel.text = self.address;
    DDLogDebug(@"cll2D:latitude-%f  longitude-%f",self.LocationCoordinate.latitude,self.LocationCoordinate.longitude);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:DCFillTheInformationVC]) {
        DCAddSuccessViewController *vc = segue.destinationViewController;
        vc.LocationCoordinate = self.LocationCoordinate;
    }
}

#pragma mark - Navigation_address
- (IBAction)checkAddress:(id)sender {
    [self navigateBack:nil];
    [self keyboardResignFirstResponder];
}

#pragma mark 设置桩或站资料弹框显示
- (IBAction)selectionType:(id)sender {
    [self keyboardResignFirstResponder];
    _stateTypeButton = (UIButton*)sender;
    
    [listView.tableView reloadData];
    
    if (_stateTypeButton ==  self.stationTypeButton) {
        _popUpViewTitle = @"桩群类型";
        _dataArr = @[@"公共桩群",@"专用桩群",@"其他"];
        
    }
    else if (_stateTypeButton ==  self.runningStateButton) {
        _popUpViewTitle = @"桩群状态";
        _dataArr = @[@"已投运",@"未投运",@"建设中",@"规划中",@"其他"];
        
    }
    [self showListView];
    
}
-(void)showListView {
    self.periodSource = [ArrayDataSource dataSourceWithItems:_dataArr
                                              cellIdentifier:kCellIdentifier
                                          configureCellBlock:^(DCPeriodTableViewCell *cell, NSString *aPeriod) {
                                              cell.frameHeight = 40;
                                              [cell.periodLabel setFont:[UIFont systemFontOfSize:15]];
                                              cell.periodLabel.textColor = [UIColor blackColor];
                                              cell.periodLabel.text = aPeriod;
                                          }];
    
    listView = nil;
    listView = [DCListView loadViewWithNib:@"BluetoothList"];
    listView.dismissButton.hidden = YES;
    [listView.labelTitl setText:_popUpViewTitle];
    [listView.labelTitl setFont:[UIFont systemFontOfSize:17]];
    listView.frame = CGRectInset(self.view.bounds, self.view.bounds.size.width / 6, (self.view.bounds.size.height -(_dataArr.count +1) * 40) / 2);
    
    [listView.tableView registerNib:[UINib nibWithNibName:@"DCPeriodTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    listView.tableView.backgroundColor = [UIColor clearColor];
    listView.tableView.alwaysBounceVertical = NO;
    
    self.popUpView = [PopUpView popUpWithContentView:listView withController:self];
    listView.tableView.delegate = self;
    listView.tableView.dataSource = self.periodSource;
    listView.tableView.scrollEnabled = NO;
    listView.delegate = self;
}

#pragma mark - UITableViewDelegate
//弹框列表选中后
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.popUpView dismiss];
    NSString * didSelectRowString = [_dataArr objectAtIndex:indexPath.row];
    [_stateTypeButton setTitle:didSelectRowString forState:UIControlStateNormal];
    if (_stateTypeButton ==  self.runningStateButton) {
        // _dataArr = @[@"正投运",@"未投运",@"建设中",@"规划中",@"其他"];
        self.runningStatus = indexPath.row + 1;
        if (indexPath.row == 4) {
            self.runningStatus = 0;
        }
        DDLogDebug(@"runningStatus:%ld", (long)_runningStatus);
    }
    if (_stateTypeButton == self.stationTypeButton) {
        self.stationType = indexPath.row + 1;
        if (indexPath.row == 2) {
            self.stationType = 0;
        }
        DDLogDebug(@"pileType:%ld",(long)_stationType);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == listView.tableView) {
        return 39;
    }
    return 0;
    
}

#pragma mark - 信息发布
- (IBAction)informationRelease:(id)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    if ([self.stationTypeButton.titleLabel.text isEqualToString:@"桩群类型"]) {
        hud.labelText = @"请选择桩群类型";
        [hud hide:YES afterDelay:1];
        
    }
    else if ([self.runningStateButton.titleLabel.text isEqualToString:@"桩群状态"]){
        hud.labelText = @"请选择桩群状态";
        [hud hide:YES afterDelay:1];
        
    }
    else if (self.browserPhotosUrl.count == 0){
        hud.labelText = @"请添加桩群图片，以便审核";
        [hud hide:YES afterDelay:1];
        
    }
    else {
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"正在提交...";
        
        [DCSiteApi postAddStation:[DCApp sharedApp].user.userId
                          address:self.address
                        longitude:self.LocationCoordinate.longitude
                         latitude:self.LocationCoordinate.latitude
                    stationStatus:self.runningStatus
                      stationType:self.stationType
                           images:self.browserPhotosUrl
                     stationName:self.vendorNameTextFieled.text
                             desp:self.pileDescribeTextView.text
                       completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                           if (![webResponse isSuccess]) {
                               [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                           } else {
                               [hud hide:YES];
                               [self performSegueWithIdentifier:DCFillTheInformationVC sender:nil];
                           }
                       }];
        
    }
}

#pragma mark listViewDismissClick
-(void)listViewDismissClick{
    [self.popUpView dismiss];
}

#pragma mark - DCPoleImageControl
- (IBAction)setImageView:(DCPoleImageControl *)sender {
    [self keyboardResignFirstResponder];
    if (sender.hasImage) {//browser
        KZPhotoBrowser *browser = [[KZPhotoBrowser alloc] initWithDelegate:self];
        [browser reloadData];
        NSUInteger index = [self.browserPhotosUrl indexOfObject:sender.imageView.image];
        [browser setCurrentPhotoIndex:index];
        [self.navigationController pushViewController:browser animated:YES];
    }
    else {
        NSInteger maxImageCount = MAX(0, self.photoImgs.count - self.browserPhotosUrl.count);
        if (maxImageCount == 0) {
            return;
        }
        __weak typeof(self) weakSelf = self;
        [self selectImagePickerSource:^(UIImagePickerControllerSourceType source) {
            if (source == UIImagePickerControllerSourceTypeCamera) {//拍摄
                DCImagePickerController *imagePickerController = [[DCImagePickerController alloc] init];
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
                imagePickerController.completion = ^(UIImage *image, UIImage *originalImage) {
                    image = [weakSelf scaleIntroImage:originalImage];
                    sender.imageView.hidden = NO;
                    sender.imageView.image = image;
                    [self.browserPhotosUrl addObjectsFromArray:@[image]];
                };
            }
            else {//相册
                PhotoPickerViewController *pickerVC = [[PhotoPickerViewController alloc] init];
                pickerVC.status = PickerViewShowStatusCameraRoll;
                pickerVC.minCount = maxImageCount;
                [pickerVC show];
                pickerVC.callBack = ^(NSArray *assets) {
                    NSArray *images = [weakSelf imagesFromAssets:assets];
                    [self.browserPhotosUrl addObjectsFromArray:images];
                    [weakSelf placeholderImages:self.browserPhotosUrl ImageNumber:self.browserPhotosUrl.count];
                };
            }
        }];
    }
}

- (void)placeholderImages:(NSArray *)images ImageNumber:(NSInteger)number {
    self.photoImgs = @[self.imageView1, self.imageView2, self.imageView3, self.imageView4, self.imageView5];
    for (NSInteger i = 0; i < self.photoImgs.count; i++) {
        DCPoleImageControl *introImage = self.photoImgs[i];
        if (i < images.count) {
            // 设置下一张
            introImage.hidden = NO;
            UIImage *image = nil;
            if (i < images.count) {
                image = images[i];
                if (![image isKindOfClass:[UIImage class]]) {
                    image = nil;
                }
            }
            //返回的图片
            introImage.imageView.image = image;
            introImage.imageView.hidden = NO;
        }
        else if (i == number){//有图时设置下一张显示
            introImage.hidden = NO;
            introImage.imageView.image = nil;
            introImage.imageView.hidden = YES;
        }
        else {//无图
            introImage.hidden = YES;
            introImage.imageView.image = nil;
            introImage.imageView.hidden = YES;
        }
    }
    
}

- (NSArray *)imagesFromAssets:(NSArray *)assets {
    NSMutableArray *images = [NSMutableArray array];
    for (MLSelectPhotoAssets *mlAsset in assets) {
        @autoreleasepool {
            ALAsset *asset = mlAsset.asset;
            ALAssetRepresentation *assetRepresentation = asset.defaultRepresentation;//NSLog(@"size %lld scale %f orientation %d", assetRepresentation.size, assetRepresentation.scale, (int)assetRepresentation.orientation);
            UIImage *image = [UIImage imageWithCGImage:assetRepresentation.fullResolutionImage scale:assetRepresentation.scale orientation:(UIImageOrientation)assetRepresentation.orientation];
            image = [self scaleIntroImage:image];
            [images addObject:image];
        }
    }
    return images;
}

- (UIImage *)scaleIntroImage:(UIImage *)image {
    //scale size
    CGFloat length = MAX(image.size.width, image.size.height);
    if (length > 1080) {
        image = [image imageScaled:1080.0/length];
    }
    //compress
    NSData *data = UIImageJPEGRepresentation(image, 1);
    data = UIImageJPEGRepresentation(image, 1000.0/[data length]);
    image = [UIImage imageWithData:data];
    //    NSLog(@"size %@ scale %f orientation %d data %ld", NSStringFromCGSize(image.size), image.scale, (int)image.imageOrientation, (long)data.length);
    return image;
}

#pragma mark - KZPhotoBrowser
- (NSUInteger)numberOfPhotosInPhotoBrowser:(KZPhotoBrowser *)photoBrowser {
    return self.browserPhotosUrl.count;
}

- (KZPhoto *)photoBrowser:(KZPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    KZPhoto *photoImage = [[KZPhoto alloc] initWithImage:self.browserPhotosUrl[index]];
    return photoImage;
}

- (void)photoBrowser:(KZPhotoBrowser *)photoBrowser deletePhotoAtIndex:(NSUInteger)index {
    
    [photoBrowser reloadData];
    [self.browserPhotosUrl removeObjectAtIndex:index];
    [self placeholderImages:self.browserPhotosUrl ImageNumber:self.browserPhotosUrl.count];
    
}

//键盘释放；
- (void)keyboardResignFirstResponder{
    [self.vendorNameTextFieled resignFirstResponder];
    [self.pileDescribeTextView resignFirstResponder];
    
}

//textField.text 输入之前的值         string 输入的字符
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//
//    if ([self.pileParameterTextField.text rangeOfString:@"."].location==NSNotFound) {
//        _isHaveDian=NO;
//    }
//    if ([string length]>0)
//    {
//        unichar single=[string characterAtIndex:0];//当前输入的字符
//        if ((single >='0' && single<='9') || single=='.')//数据格式正确
//        {
//            //首字母不能为0和小数点
//            if([self.pileParameterTextField.text length]==0){
//                if(single == '.'){
//                    //第一个数字不能为小数点;
//                    [self.pileParameterTextField.text stringByReplacingCharactersInRange:range withString:@""];
//                    return NO;
//
//                }
////                if (single == '0') {
////                    //第一个数字不能为0;
////                    [self.pileParameterTextField.text stringByReplacingCharactersInRange:range withString:@""];
////                    return NO;
////
////                }
//            }
//            if (single=='.')
//            {
//                if(!_isHaveDian)//text中还没有小数点
//                {
//                    _isHaveDian=YES;
//                    return YES;
//                }else
//                {
//                    //已经输入过小数点了;
//                    [self.pileParameterTextField.text stringByReplacingCharactersInRange:range withString:@""];
//                    return NO;
//                }
//            }
//            else
//            {
//                if (_isHaveDian)//存在小数点
//                {
//                    //判断小数点的位数
//                    NSRange ran=[self.pileParameterTextField.text rangeOfString:@"."];
//                    int tt=range.location-ran.location;
//                    if (tt <= 2){
//                        return YES;
//                    }else{
//                        //最多输入两位小数;
//                        return NO;
//                    }
//                }
//                else
//                {
//                    return YES;
//                }
//            }
//        }
//        else{
//            //输入的数据格式不正确
//            //输入的格式不正确;
//            [self.pileParameterTextField.text stringByReplacingCharactersInRange:range withString:@""];
//            return NO;
//        }
//    }
//    else
//    {
//        return YES;
//    }
//
//}

@end
