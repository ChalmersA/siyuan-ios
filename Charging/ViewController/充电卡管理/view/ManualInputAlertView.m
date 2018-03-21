//
//  ManualInputAlertView.m
//  aaa
//
//  Created by gaoml on 2018/3/7.
//  Copyright © 2018年 钞王. All rights reserved.
//

#define KSW [UIScreen mainScreen].bounds.size.width
#define KSH [UIScreen mainScreen].bounds.size.height
#define XXViewH(size) size/750.0 * KSH
#define XXViewW(size) size/375.0 * KSW
#define SizeScale (KSW != 414 ? 1 : 1.2)
#define kFont(value) [UIFont systemFontOfSize:value * SizeScale]

#import "ManualInputAlertView.h"

@interface ManualInputAlertView ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLb;

@property (nonatomic, strong) UIView *inputView;

@property (nonatomic, strong) NSMutableArray *selectButtonA;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIButton *sureButton;

/** label数组 */
@property (nonatomic, strong) NSMutableArray<UILabel *> * labels;
/**textField*/
@property (nonatomic, weak) UITextField *textField;

@end


@implementation ManualInputAlertView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    self.layer.cornerRadius = 5;
    
    [self buildView];
    [self.textField becomeFirstResponder];
    return self;
}

-(void)buildView
{
    self.labels = [NSMutableArray <UILabel *> array];

    self.titleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    [self.titleLb setText:@"请输入充电桩编号"];
    [self.titleLb setTextColor:[UIColor whiteColor]];
    [self.titleLb setFont:[UIFont systemFontOfSize:18]];
    [self.titleLb setBackgroundColor:[UIColor paletteDCMainColor]];
    self.titleLb.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLb];
    
    CGFloat spacing = XXViewW(0);//间距
    CGFloat w = (self.frame.size.width - spacing * 15) / 16.0;
    CGFloat h = 50;

    //数字输入框
    self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.frame.size.width, h)];
    [self.inputView setBackgroundColor:[UIColor grayColor]];
    [self addSubview:self.inputView];
    UITapGestureRecognizer *tapnumView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numViewTap)];
    [self.inputView addGestureRecognizer:tapnumView];
    
    // 数字框
    for (int i = 0; i < 16; i++) {
        UIView *numv = [[UIView alloc] init];
        numv.layer.borderWidth = 0.5;
        numv.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        [self.inputView addSubview:numv];
        numv.frame = CGRectMake(i * (w+spacing), 0, w, h);
        UILabel *numL = [[UILabel alloc] init];
        [self.labels addObject:numL];
        [numv addSubview:numL];
        numL.textColor = [UIColor whiteColor];
        numL.frame = CGRectMake(0, 0, w, h);
        numL.textAlignment = NSTextAlignmentCenter;
        numL.font = kFont(15);
        numL.text = @"";
        
    }
    // 添加textfield
    UITextField *textField = [[UITextField alloc] init];
    textField.delegate = self;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    [textField addTarget:self action:@selector(changeButtonWith:) forControlEvents:UIControlEventEditingChanged];
    [self.inputView addSubview:textField];
    self.textField = textField;
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.inputView.frame.size.height + self.inputView.frame.origin.y, self.frame.size.width/2, 50)];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor paletteDCMainColor] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundColor:[UIColor whiteColor]];
    [self.cancelButton setTag:666];
    [self.cancelButton addTarget:self action:@selector(selectButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    
    self.sureButton = [[UIButton alloc] initWithFrame:CGRectMake(self.cancelButton.frame.origin.x + self.cancelButton.frame.size.width, self.cancelButton.frame.origin.y, self.frame.size.width/2, 50)];
    [self.sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sureButton setBackgroundColor:[UIColor paletteDCMainColor]];
    [self.sureButton setTag:667];
    [self.sureButton addTarget:self action:@selector(selectButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sureButton];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

#pragma mark --- 完成
- (void)commintButtonClick
{
    if (self.cardNum== nil || self.cardNum.length != 16) {
//        [SVProgressHUD showErrorWithStatus:@"单车编号不正确!"];
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//        [SVProgressHUD dismissWithDelay:1.0];
        return;
    }
//    [self scanToOpenLuck:self.bikeNo];
 
}

#pragma mark --- 弹出键盘
- (void)numViewTap
{
    // 弹出键盘
    [self.textField becomeFirstResponder];
}

- (void)changeButtonWith:(UITextField *)textField
{
    NSString *str = textField.text;
    if (str.length == 0) {
        self.labels[0].text = @"";
        self.labels[0].superview.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    }
    if (str.length > 16) {
        
        return;
    }else
    {
        if (str.length == 16) {
 //           self.descriptionL.text = @"若因输错自行车编码造成自行车丢失，您将承担高达2000元的赔偿责任";
 //   self.descriptionL.textColor = [UIColor redColor];
            str = [str substringWithRange:NSMakeRange(0, 16)];
            self.cardNum = str;
            NSLog(@"%@,",self.cardNum);
            
        }else
        {
//            self.descriptionL.text = @"请确认输入了正确的自行车编号";
 //           self.descriptionL.textColor = [UIColor blackColor];
        }
        
        for (int i = 0; i < str.length; i++) {
            self.labels[i].textColor = [UIColor whiteColor];
            self.labels[i].text =[str substringWithRange:NSMakeRange(i, 1)];
            self.labels[i].superview.layer.borderColor = [[UIColor whiteColor] CGColor];
            for (int k = 0; k < self.labels.count; k++) {
                if (k <= i) {
                    continue;
                }
                // 清除label
                self.labels[k].text = @"";
                self.labels[k].superview.layer.borderColor = [[UIColor darkGrayColor] CGColor];
            }
        }
    }
}


- (void)selectButtonClickAction: (UIButton *)sender {
    
    if (sender.tag == 666) {
        
        if (self.clickCancelButtonBlock) {
            self.clickCancelButtonBlock();
        }
        
    } else {
        
        if (self.clickSureButtonBlock) {
            self.clickSureButtonBlock();
        }
    }
    
}

@end
