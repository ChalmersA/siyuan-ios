//
//  DCTextInputViewController.m
//  Charging
//
//  Created by xpg on 6/3/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCTextInputViewController.h"

@interface DCTextInputViewController () <UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) NSString * titleString;
@end

@implementation DCTextInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textField.text = self.text;
    NSString *suffixStr = self.maxLength ? [NSString stringWithFormat:@", 最长%ld字符", (long)[self.maxLength integerValue]] : @"";
    if (self.minLength && self.maxLength) {
        suffixStr = [NSString stringWithFormat:@", %d-%d字符", self.minLength.intValue, self.maxLength.intValue];
    }
    self.textField.placeholder = [NSString stringWithFormat:@"请输入%@%@", self.title, suffixStr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(limitTextField:) name:UITextFieldTextDidChangeNotification object:self.textField];

//    self.saveButton.backgroundColor = [UIColor paletteOrangeColor];
    self.titleString = [NSString stringWithFormat:@"%@不能为空",self.title];
        
    if (self.navigationItem.rightBarButtonItem) {
        self.bottomView.hidden = YES;
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.bottomView.hidden) {
        [self.textField becomeFirstResponder];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.requestTask cancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Action
- (IBAction)doneAction:(id)sender {
    [self.view endEditing:YES];
    if (self.textField.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self hideHUD:hud withText:self.titleString];
        return;
    }
    
    NSString *text = self.textField.text;
    if (self.minLength && (text.length < [self.minLength integerValue])) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self hideHUD:hud withText:self.textField.placeholder];
        return;
    }
    if (self.maxLength && (text.length > [self.maxLength integerValue])) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self hideHUD:hud withText:self.textField.placeholder];
        return;
    }
    
    if ([self.textField.text isEqualToString:self.text]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([NSString isStringContainsEmoji:self.textField.text]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self hideHUD:hud withText:@"用户名不能包含表情"];
        return;
    }
    
    if (self.textType == DCTextInputTypeUserName) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否保存您已修改的用户名？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否保存您的电桩名称？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (void)limitTextField:(NSNotification *)note {
    if (self.maxLength) {
        NSInteger maxLength = [self.maxLength integerValue];
        UITextField *textField = (UITextField *)note.object;
        NSString *toBeString = textField.text;
        NSString *lang = [textField.textInputMode primaryLanguage]; // 键盘输入模式a
        if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) { // 中文输入，包括简体拼音，健体五笔，简体手写
            UITextRange *selectedRange = [textField markedTextRange];
            //获取高亮部分
            UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position) {
                if (toBeString.length > maxLength) {
                    textField.text = [toBeString substringToIndex:maxLength];
                }
            }
            // 有高亮选择的字符串，则暂不对文字进行统计和限制
            else{
                
            }
        }
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        else{
            if (toBeString.length > maxLength) {
                textField.text = [toBeString substringToIndex:maxLength];
            }
        }
    }
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *text = self.textField.text;
        [self.delegate textInputViewController:self inputDone:text];
    }
}
@end
