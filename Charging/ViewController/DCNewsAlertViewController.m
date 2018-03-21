//
//  HSSYNewsAlertViewController.m
//  Charging
//
//  Created by kufufu on 15/10/20.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCNewsAlertViewController.h"
#import "DCNewsAlertCell.h"

@interface DCNewsAlertViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *newsTableView;
@property (weak, nonatomic) IBOutlet DCNewsAlertCell *newsAlertCell;

@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *detailArray;

@end

@implementation DCNewsAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.newsTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    self.newsTableView.separatorColor = [UIColor colorWithWhite:239/255.0 alpha:1];
    
    self.titleArray = [NSArray arrayWithObjects:@"消息推送", @"交易提醒", nil];
    self.detailArray = [NSArray arrayWithObjects:@"点评促销优惠活动及精彩内容", @"您的订单消费等相关消息", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DCNewsAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HSSYNewsAlertCell"];
    if (cell == nil) {
        cell = [[DCNewsAlertCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HSSYNewsAlertCell"];
    }
    cell.sw.onTintColor = [UIColor paletteDCMainColor];
    cell.titleL.text = self.titleArray[indexPath.row];
    cell.detailL.text = self.detailArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
