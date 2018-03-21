//
//  DCPileEvaluationViewController.m
//  Charging
//
//  Created by xpg on 15/9/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPileEvaluationViewController.h"
#import "DCPoleImageControl.h"
#import "IQTextView.h"
#import "CWStarRateView.h"
#import "DCImagePickerController.h"
#import "KZPhotoBrowser.h"
#import "UIViewController+HSSYExtensions.h"
#import "Charging-Swift.h"
#import "DCSiteApi.h"
#import "DCArea.h"

#define BOOKMARK_WORD_LIMIT 200
typedef NS_ENUM(NSInteger, DCSatisfaction)
{
    //评价等级(未选中、1星、2星、3星、4星、5星)
    stateless = 0,
    poor = 1,
    general = 2,
    satisfied = 3,
    verySatisfied = 4,
    superSatisfied = 5
};

@interface DCPileEvaluationViewController () <UIScrollViewDelegate,UITextViewDelegate,CWStarRateViewDelegate,KZPhotoBrowserDelegate>{
    //    int evaluateValue;
}


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

//满意度 （差、一般、满意、很满意、强烈推荐）
@property (weak, nonatomic) IBOutlet UIView *satisfactionView;
@property (weak, nonatomic) IBOutlet UIView *poorView;
@property (weak, nonatomic) IBOutlet UILabel *poorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *poorImageView;

@property (weak, nonatomic) IBOutlet UIView *generalView;
@property (weak, nonatomic) IBOutlet UILabel *generalLable;
@property (weak, nonatomic) IBOutlet UIImageView *generalImageView;

@property (weak, nonatomic) IBOutlet UIView *satisfiedView;
@property (weak, nonatomic) IBOutlet UILabel *satisfiedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *satisfiedImageView;

@property (weak, nonatomic) IBOutlet UIView *verySatisfiedView;
@property (weak, nonatomic) IBOutlet UILabel *verySatisfiedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *verySatisfiedImageView;

@property (weak, nonatomic) IBOutlet UIView *superSatisfiedView;
@property (weak, nonatomic) IBOutlet UILabel *superSatisfiedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *superSatisfiedImageView;

//星级
@property (weak, nonatomic) IBOutlet UIView *starView;
@property (weak, nonatomic) IBOutlet UIView *satisfactionStarsView;

//桩客观评价
@property (weak, nonatomic) IBOutlet UIView *objectiveView;
@property (weak, nonatomic) IBOutlet UIView *environmentView;//环境
@property (weak, nonatomic) IBOutlet UIView *appearanceView;//服务
@property (weak, nonatomic) IBOutlet UIView *performanceView;//性能

//评论
@property (weak, nonatomic) IBOutlet UIView *introduceView;
@property (weak, nonatomic) IBOutlet IQTextView *introduceTextView;

@property (weak, nonatomic) IBOutlet UILabel *photoImages;
//照片
@property (weak, nonatomic) IBOutlet UIView *photoView;

@property (weak, nonatomic) IBOutlet DCPoleImageControl *photo1;
@property (weak, nonatomic) IBOutlet DCPoleImageControl *photo2;
@property (weak, nonatomic) IBOutlet DCPoleImageControl *photo3;
@property (weak, nonatomic) IBOutlet DCPoleImageControl *photo4;
@property (weak, nonatomic) IBOutlet DCPoleImageControl *photo5;
@property (weak, nonatomic) IBOutlet DCPoleImageControl *photo6;

@property (copy, nonatomic) NSArray *photoImgs;

//为了区别各评价等级分数
@property CWStarRateView *startRateView;
@property CWStarRateView *environmentStarView;
@property CWStarRateView *appearanceStarView;
@property CWStarRateView *performanceStarView;
@property CWStarRateView *serviceStarView;
//为了区别各评价评语
@property (strong, nonatomic) NSString *satisFactionString;
@property (strong, nonatomic) NSString *environmentString;
@property (strong, nonatomic) NSString *appearanceString;
@property (strong, nonatomic) NSString *performanceString;

@property (strong, nonatomic) NSMutableArray *browserPhotos;

@property (assign) int starCount;
@property (assign ,nonatomic) DCSatisfaction satisFactionType;

@property (strong, nonatomic) NSString * textViewText;
@property (strong, nonatomic) NSURLSessionDataTask *requestTask;

@property (nonatomic) LocationService *locationService;

@end

@implementation DCPileEvaluationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self.view setBackgroundColor:[UIColor paletteSeparateLineLightGrayColor]];
    
    self.browserPhotos = [NSMutableArray array];
    [self initSatisfactionStarsView];
    
    _environmentStarView = [self initialControlAddedToView:self.environmentView];
    _appearanceStarView = [self initialControlAddedToView:self.appearanceView];
    _performanceStarView = [self initialControlAddedToView:self.performanceView];
    
    self.introduceTextView.delegate = self;
    self.introduceTextView.placeholder = @"这里充电给力吗，环境如何？(写够15字，才是好同志~)";
    
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;//释放键盘
    
    [self placeholderImages:nil ImageNumber:stateless];
    
    self.locationService = [[LocationService alloc] init];
    [self.locationService startUserLocationService];
}

-(void)viewWillAppear:(BOOL)animated {
    if (self.browserPhotos.count) {
        [self placeholderImages:self.browserPhotos ImageNumber:self.browserPhotos.count];
    }
    self.photoImages.text = [NSString stringWithFormat:@"%lu/6",(unsigned long)self.browserPhotos.count];
}

#pragma mark - 主观评价点击事件
- (void)initSatisfactionStarsView {
    UITapGestureRecognizer * poorViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(satisfactionClickEvent:)];
    [self.poorView addGestureRecognizer:poorViewTap];
    UITapGestureRecognizer * generalViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(satisfactionClickEvent:)];
    [self.generalView addGestureRecognizer:generalViewTap];
    UITapGestureRecognizer * satisfiedViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(satisfactionClickEvent:)];
    [self.satisfiedView addGestureRecognizer:satisfiedViewTap];
    UITapGestureRecognizer * verySatisfiedViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(satisfactionClickEvent:)];
    [self.verySatisfiedView addGestureRecognizer:verySatisfiedViewTap];
    UITapGestureRecognizer * superSatisfiedViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(satisfactionClickEvent:)];
    [self.superSatisfiedView addGestureRecognizer:superSatisfiedViewTap];
    
    _startRateView = [[CWStarRateView alloc]initWithFrame:self.satisfactionStarsView.frame numberOfStars:5 referView:self.satisfactionStarsView];
    _startRateView.scorePercent = stateless / 5.0;
    _startRateView.allowIncompleteStar = NO;
    _startRateView.delegate = self;
    self.satisfactionStarsView.userInteractionEnabled = NO;
    [self.satisfactionStarsView addSubview:_startRateView];

}

- (void)satisfactionClickEvent:(id)sender {
    UIGestureRecognizer * tapView;
    tapView = sender;
    
    //设置主观初始状态
    [self setNotSelectedView:self.poorView Label:self.poorLabel ImageView:self.poorImageView ImageName:@"assess_btn_link_angry"];
    [self setNotSelectedView:self.generalView Label:self.generalLable ImageView:self.generalImageView ImageName:@"assess_btn_link_normal"];
    [self setNotSelectedView:self.satisfiedView Label:self.satisfiedLabel ImageView:self.satisfiedImageView ImageName:@"assess_btn_link_ok"];
    [self setNotSelectedView:self.verySatisfiedView Label:self.verySatisfiedLabel ImageView:self.verySatisfiedImageView ImageName:@"assess_btn_link_good"];
    [self setNotSelectedView:self.superSatisfiedView Label:self.superSatisfiedLabel ImageView:self.superSatisfiedImageView ImageName:@"assess_btn_link_well"];
    
    if (tapView.view == self.poorView) {
        [self setSelectedView:self.poorView Label:self.poorLabel ImageView:self.poorImageView ImageName:@"assess_btn_pressed_angry"];
        self.startRateView.scorePercent = poor / 5.0;
        self.satisFactionType = poor;
    }
    else if (tapView.view == self.generalView) {
        [self setSelectedView:self.generalView Label:self.generalLable ImageView:self.generalImageView ImageName:@"assess_btn_pressed_normal"];
        self.startRateView.scorePercent =  general / 5.0;
        self.satisFactionType = general;
    }
    else if (tapView.view == self.satisfiedView) {
        [self setSelectedView:self.satisfiedView Label:self.satisfiedLabel ImageView:self.satisfiedImageView ImageName:@"assess_btn_pressed_ok"];
        self.startRateView.scorePercent =  satisfied / 5.0;
        self.satisFactionType = satisfied;
    }
    else if (tapView.view == self.verySatisfiedView) {
        [self setSelectedView:self.verySatisfiedView Label:self.verySatisfiedLabel ImageView:self.verySatisfiedImageView ImageName:@"assess_btn_pressed_good"];
        self.startRateView.scorePercent =  verySatisfied / 5.0;
        self.satisFactionType = verySatisfied;
    }
    else if (tapView.view == self.superSatisfiedView) {
        [self setSelectedView:self.superSatisfiedView Label:self.superSatisfiedLabel ImageView:self.superSatisfiedImageView ImageName:@"assess_btn_pressed_well"];
        self.startRateView.scorePercent =  superSatisfied / 5.0;
        self.satisFactionType = superSatisfied;
    }
//    switch (self.satisFactionType) {
//        case poor: {
//            self.satisFactionString = @"充电不尽人意，";
//        }
//            break;
//        case general: {
//            self.satisFactionString = @"充电有点小意外，";
//        }
//            break;
//        case satisfied: {
//            self.satisFactionString = @"挺好，正常充电，";
//        }
//            break;
//        case verySatisfied: {
//            self.satisFactionString = @"超乎所想，充电很顺利！";
//        }
//            break;
//        case superSatisfied: {
//            self.satisFactionString = @"充电体验很棒！强烈推荐！";
//        }
//            break;
//            
//        default:
//            break;
//    }
//    self.introduceTextView.placeholder = [NSString stringWithFormat:@"%@%@%@%@",self.satisFactionString?:@"",self.environmentString?:@"",self.appearanceString?:@"",self.performanceString?:@""];
}

#pragma mark - 客观评价
- (CWStarRateView *)initialControlAddedToView:(UIView *)addedToview {
    
    CWStarRateView *star = [[CWStarRateView alloc] initWithFrame:addedToview.bounds
                                                   numberOfStars:5
                                                       referView:addedToview
                                             backgroundImageName:[NSString stringWithFormat:@"assess_btn_link_face01"]
                                             foregroundImageName:[NSString stringWithFormat:@"assess_btn_link_face02"]];
    
    star.scorePercent = stateless / 5.0;
    star.allowIncompleteStar = NO;
    star.delegate = self;
    [addedToview addSubview:star];
    return star;
}

-(void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent {
//    if (starRateView == self.environmentStarView){
//        /**
//         周边环境：
//         1-2星：环境一般，
//         3星：有停车位，充电环境还可以，
//         4-5星：地址很好找，充电位无人占用，
//         */
//        
//        //scorePercent 得分值，范围为0--1，默认为1
//        if (newScorePercent < 3) {
//            self.environmentString = @"环境一般，";
//        }
//        else if (newScorePercent > 3){
//            self.environmentString = @"地址很好找，充电位无人占用，";
//        }
//        else {
//            self.environmentString = @"有停车位，充电环境还可以，";
//        }
//        
//    }
//    else if (starRateView == self.appearanceStarView) {
//        /**
//         1-2星：根本充不了电，
//         3星：充电设备有点老旧，
//         4-5星：充电设备新建成，
//         */
//        if (newScorePercent < 3) {
//            self.appearanceString = @"根本充不了电，";
//        }
//        else if (newScorePercent > 3){
//            self.appearanceString = @"充电设备新建成，";
//        }
//        else {
//            self.appearanceString = @"充电设备有点老旧，";
//        }
//    }
//    else if (starRateView == self.performanceStarView) {
//        /**
//         充电速度：
//         1-2星：充电速度与电桩类型不符。
//         3星：充电速度还行。
//         4-5星：充电速度令我满意。
//         */
//        if (newScorePercent < 3) {
//            self.performanceString = @"充电速度与电桩类型不符。";
//        }
//        else if (newScorePercent > 3){
//            self.performanceString = @"充电速度令我满意。";
//        }
//        else {
//            self.performanceString = @"充电速度还行。";
//        }
//    }
//    self.introduceTextView.placeholder = [NSString stringWithFormat:@"%@%@%@%@",self.satisFactionString?:@"",self.environmentString?:@"",self.appearanceString?:@"",self.performanceString?:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.photoView.frameHeight = self.browserPhotos.count > 2 ? self.photo1.frameHeight * 2 + 30: self.photo1.frameHeight + 20;

    CGRect newFrame = self.photoView.frame;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, newFrame.origin.y + newFrame.size.height);
}

- (void)textViewDidChange:(UITextView *)textView {
    //该判断用于输入字数限定
    if (textView.text.length > BOOKMARK_WORD_LIMIT)
    {
        textView.text = [textView.text substringToIndex:BOOKMARK_WORD_LIMIT];
//        NSLog(@"wenzi shangx文字上限！·");
    }
}

- (void)setNotSelectedView:(UIView*)view Label:(UILabel*)lable ImageView:(UIImageView*)imageView ImageName:(NSString*)imageName {
    view.backgroundColor = [UIColor whiteColor];
    lable.textColor = [UIColor lightGrayColor];
    imageView.image = [UIImage imageNamed:imageName];
}

- (void)setSelectedView:(UIView*)view Label:(UILabel*)lable ImageView:(UIImageView*)imageView ImageName:(NSString*)imageName {
    view.backgroundColor = [UIColor paletteBottomBtnLightGrayColor];
    lable.textColor = [UIColor blackColor];
    imageView.image = [UIImage imageNamed:imageName];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - @selector
- (IBAction)releaseButton:(id)sender {
    
    [self.introduceTextView resignFirstResponder];

    if ([self.introduceTextView.text isEqualToString:@""]) {
       _textViewText = self.introduceTextView.placeholder;
    }else {
        _textViewText = self.introduceTextView.text;
    }
    
    DDLogDebug(@"\n评价：分数：%d  客观分数：%d ,%d ,%d ,%d   评语:%@  图片:%@  userId:%@  orderId:%@",
               (int)(_startRateView.scorePercent * 5),
               (int)(_environmentStarView.scorePercent * 5),
               (int)(_appearanceStarView.scorePercent * 5),
               (int)(_performanceStarView.scorePercent * 5),
               (int)(_serviceStarView.scorePercent * 5),
               _textViewText,
               self.browserPhotos,
               [DCApp sharedApp].user.userId,
               self.order.orderId);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    if (_startRateView.scorePercent == 0) {
        [self hideHUD:hud withText:@"请进行主观评分"];
    }
    else if (_environmentStarView.scorePercent == 0 || _appearanceStarView.scorePercent == 0 || _performanceStarView.scorePercent == 0 ){
        [self hideHUD:hud withText:@"请进行客观评分"];
    }
    else if (_textViewText == self.introduceTextView.placeholder) {
        [self hideHUD:hud withText:@"请填写评价内容"];
    }
    else if (_textViewText.length < 15) {
        [self hideHUD:hud withText:@"最少评价字数为15字"];
    }
    else {
        //上传评论
        //        postPileEvaluate:
        
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"正在提交...";
        
        self.requestTask = [DCSiteApi postEvaluate:[DCApp sharedApp].user.userId
                                           orderId:self.order.orderId
                                         starScore:(int)(_startRateView.scorePercent * 5)
                                        envirScore:(int)(_environmentStarView.scorePercent * 5)
                                       facadeScore:(int)(_appearanceStarView.scorePercent * 5)
                                        speedScore:(int)(_performanceStarView.scorePercent * 5)
                                           content:self.textViewText
                                            images:self.browserPhotos
                                            cityId:[DCArea findCityByCityName:self.locationService.locationAddress].cityId
                                        completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                                            if (![webResponse isSuccess]) {
                                                [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                                            }
                                            else {
                                                [self hideHUD:hud withText:@"评价成功"];
                                                [self.delegate pileDidEvaluated];
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }
                                        }];
        
    }
}

- (void)tapOnView:(id)sender {
    [self.introduceTextView resignFirstResponder];
}

- (IBAction)evaluationImage:(DCPoleImageControl *)sender {
    if (sender.hasImage) {//browser
        KZPhotoBrowser *browser = [[KZPhotoBrowser alloc] initWithDelegate:self];
        [browser reloadData];
        NSUInteger index = [self.browserPhotos indexOfObject:sender.imageView.image];
        [browser setCurrentPhotoIndex:index];
        [self.navigationController pushViewController:browser animated:YES];
    }
    else {
        NSInteger maxImageCount = MAX(0, self.photoImgs.count - self.browserPhotos.count);
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
                    
                    [self.browserPhotos addObjectsFromArray:@[image]];
                };
            }
            else {//相册
                PhotoPickerViewController *pickerVC = [[PhotoPickerViewController alloc] init];
                pickerVC.status = PickerViewShowStatusCameraRoll;
                pickerVC.minCount = maxImageCount;
                [pickerVC show];
                pickerVC.callBack = ^(NSArray *assets) {
                    NSArray *images = [weakSelf imagesFromAssets:assets];
                    [self.browserPhotos addObjectsFromArray:images];
                    [weakSelf placeholderImages:self.browserPhotos ImageNumber:self.browserPhotos.count];
                };
            }
        }];
    }
}

- (void)placeholderImages:(NSArray *)images ImageNumber:(NSInteger)number {
    self.photoImgs = @[self.photo1, self.photo2, self.photo3, self.photo4, self.photo5, self.photo6];
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
    self.photoImages.text = [NSString stringWithFormat:@"%lu/6",(unsigned long)self.browserPhotos.count];
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
    return self.browserPhotos.count;
}

- (KZPhoto *)photoBrowser:(KZPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    KZPhoto *photoImage = [[KZPhoto alloc] initWithImage:self.browserPhotos[index]];
    return photoImage;
}

- (void)photoBrowser:(KZPhotoBrowser *)photoBrowser deletePhotoAtIndex:(NSUInteger)index {
    
    [photoBrowser reloadData];
    [self.browserPhotos removeObjectAtIndex:index];
    [self placeholderImages:self.browserPhotos ImageNumber:self.browserPhotos.count];
}

@end
