//
//  DCSettingViewController.m
//  Charging
//
//  Created by kufufu on 15/9/29.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCSettingViewController.h"
#import "DCBindAccountViewController.h"
#import "Reachability.h"

//const NSInteger HSSYListRowNews             = 0;//消息提醒
const NSInteger HSSYListRowCleanCache       = 0;//清除缓存
//const NSInteger HSSYListRowBindAccount      = 2;//账号绑定
const NSInteger HSSYListRowWifiMode         = 1;//wifi模式

@interface DCSettingViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UISwitch *sw;
@property (strong, nonatomic) NSUserDefaults *saveGPRSMode;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listItems;

@end

@implementation DCSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    self.tableView.separatorColor = [UIColor colorWithWhite:239/255.0 alpha:1];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
//    self.listItems = [NSArray arrayWithObjects:@"消息提醒", @"清除缓存", @"账号绑定", @"非wifi下使用节省流量模式", nil];
    self.listItems = [NSArray arrayWithObjects:@"清除缓存", @"非wifi下使用节省流量模式", nil];
    
    self.saveGPRSMode = [NSUserDefaults standardUserDefaults];
    self.sw = [[UISwitch alloc] init];
    if ([[self.saveGPRSMode objectForKey:@"saveGPRSMode"] isEqualToString:@"On"]) {
        [self.sw setOn:YES animated:YES];
    }else {
        [self.sw setOn:NO animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *id1 = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id1];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:id1];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.text = self.listItems[indexPath.row];
//    if (indexPath.row == 0 || indexPath.row == 2) {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
//    if (indexPath.row == 3) {
//        self.sw = [[UISwitch alloc] init];
//        self.sw.onTintColor = [UIColor paletteGreenColor];
//        [self.sw addTarget:self action:@selector(switchForWifiModel) forControlEvents:UIControlEventTouchUpInside];
//        cell.accessoryView = self.sw;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
    if (indexPath.row == HSSYListRowCleanCache) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1fM",(float)[[SDImageCache sharedImageCache] getSize]/(1024 * 1024)];
    }
    if (indexPath.row == HSSYListRowWifiMode) {
        self.sw.onTintColor = [UIColor paletteDCMainColor];
        [self.sw addTarget:self action:@selector(switchForWifiModel) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = self.sw;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
//        case HSSYListRowNews:
//            NSLog(@"点击进入消息提醒");
//            [self performSegueWithIdentifier:@"PushToNewsAlert" sender:nil];
//            break;
        case HSSYListRowCleanCache:
            NSLog(@"点击清除缓存");
            [[SDImageCache sharedImageCache] clearDisk];
            [tableView reloadData];
            break;
//        case HSSYListRowBindAccount: {
//            [self performSegueWithIdentifier:@"PushToBindAccount" sender:nil];
//            break;
//        }
        default:
            break;
    }
}

#pragma mark wifiModel
-(void)switchForWifiModel
{
    BOOL isButtonOn = [self.sw isOn];
    if (isButtonOn) {
        [self.saveGPRSMode setObject:@"On" forKey:@"saveGPRSMode"];
    }else {
        [self.saveGPRSMode setObject:@"Off" forKey:@"saveGPRSMode"];
    }
    [self.saveGPRSMode synchronize];
}

#pragma mark - Navigation
//- (void)pushToViewController:(UIViewController *)vc {
//    [self.navigationController pushViewController:vc animated:YES];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//}
@end
