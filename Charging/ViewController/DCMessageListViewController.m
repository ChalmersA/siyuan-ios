//
//  HSSYMessageListViewController.m
//  Charging
//
//  Created by xpg on 15/3/19.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCMessageListViewController.h"
#import "DCMessage.h"
#import "DCMessageCell.h"
#import "DCMessageDetailViewController.h"
#import "Charging-Swift.h"
#import "PopUpView.h"
#import "DropListView.h"
#import "DCOrderDetailViewController.h"

static NSString * const HSSYMessageCellIdentifier = @"DCMessageCell";
static NSString * const HSSYSegueIdMessageDetail = @"PushToMessageDetail";
static const int DCMessageLoadCount = 10;
static BOOL NotificationSettingAlerted = NO;

@interface DCMessageListViewController () <UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableEmptyView;
@property (strong, nonatomic) ArrayDataSource *dataSource;
@property (strong, nonatomic) NSArray *messageList;
@property (weak, nonatomic) NSURLSessionDataTask *requestTask;
@property (weak, nonatomic) NSURLSessionDataTask *refreshUnreadMessageTask;
@property (weak, nonatomic) DropListView * listStateInformation;
@property (assign, nonatomic) DCMessageStatus messageListState;
@end

@implementation DCMessageListViewController

+ (instancetype)storyboardInstantiate {
    UIStoryboard *messageStoryboard = [UIStoryboard storyboardWithName:@"Message" bundle:nil];
    return [messageStoryboard instantiateViewControllerWithIdentifier:@"DCMessageListViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.messageListState = DCMessageStatusAll;
    
    self.tableEmptyView.hidden = NO;
    self.messageList = [NSArray array];
    self.dataSource = [ArrayDataSource dataSourceWithItems:self.messageList
                                            cellIdentifier:HSSYMessageCellIdentifier
                                        configureCellBlock:^(DCMessageCell *cell, DCMessage *message) {
                                            [cell configureForMessage:message];
                                        }];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    // refresh header
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf fetchMessageListWithStartIndex:1 count:DCMessageLoadCount];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.header = header;
    
    // refresh footer
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf fetchMessageListWithStartIndex:[weakSelf.messageList count] count:DCMessageLoadCount];
    }];
    self.tableView.footer.hidden = YES;
    // ********* FOR auto resizing **********//
    self.tableView.estimatedRowHeight = 107;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView.header beginRefreshing];
    [self observeNotification];
    
    if (!NotificationSettingAlerted) {
        BOOL enabled = [[UIApplication sharedApplication] checkNotificationSetting];
        if (!enabled) {
            NotificationSettingAlerted = YES;
        }
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_button_more"] style:UIBarButtonItemStylePlain target:self action:@selector(listStateInformationAvtion:)];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self refreshUnreadMessageCount];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.requestTask cancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:HSSYSegueIdMessageDetail]) {
        DCMessageDetailViewController *messageVC = segue.destinationViewController;
        messageVC.message = sender;
    }
}

#pragma mark - Request
- (void)refreshUnreadMessageCount {
    [self.refreshUnreadMessageTask cancel];
    self.refreshUnreadMessageTask = [DCSiteApi getUnreadMessageCount:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if ([webResponse isSuccess]) {
            NSNumber *unreadMessageCount = [webResponse.result numberObject];
            if (unreadMessageCount) {
                [DCDefault saveNewMessageCount:[unreadMessageCount integerValue]];
            }
        }
    }];
}

#pragma mark - Extensions
- (void)fetchMessageListWithStartIndex:(NSUInteger)index count:(NSUInteger)count {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.requestTask = [DCSiteApi getMessageListWithStatus:self.messageListState userId:[DCApp sharedApp].user.userId page:@(index) pageSize:@(count) completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        
        NSArray *messageArray = [webResponse.result arrayObject];
        if (index == 1) {//pull down
            self.messageList = [NSArray array];
        }
        NSArray *messages = [self filterMessageResult:messageArray];
        self.messageList = [self.messageList arrayByAddingObjectsFromArray:messages];
        self.tableView.arrayDataSource.items = self.messageList;
        [self.tableView reloadData];
        self.tableView.footer.hidden = (messageArray.count < count);
        self.tableEmptyView.hidden = (self.messageList.count > 0);
        [hud hide:YES];
    }];
}

- (NSArray *)filterMessageResult:(NSArray *)result {
    NSMutableArray *filterMessages = [NSMutableArray array];
    BOOL filterSameMessage = YES;
    for (NSDictionary *dict in result) {
        if (![dict isKindOfClass:[NSDictionary class]]) { //处理服务器返回null的异常
            continue;
        }
        DCMessage *message = [[DCMessage alloc] initWithDict:dict];
        if (filterSameMessage) {
            if ([self.messageList containsObject:message]) {
                continue;//same message do not add to list
            } else {
                filterSameMessage = NO;
            }
        }
        [filterMessages addObject:message];
    }
    return [filterMessages copy];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DCMessage *message = self.messageList[indexPath.row];
    
    if (message.status != DCMessageStatusRead) {
        NSMutableArray *messageIdArray = [NSMutableArray array];
        [messageIdArray addObject:message.messageId];
        [DCSiteApi postMessageIds:messageIdArray status:DCMessageStatusRead type:DCMessageSetTypeSpecial userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (webResponse.isSuccess) {
                message.status = DCMessageStatusRead;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_DID_READ object:message];
                [DCDefault saveNewMessageCount:[DCDefault loadNewMessageCount] - 1];
            }
        }];
    }
    
    switch (message.type) {
        case DCMessageTypeCharge:
        case DCMessageTypeChargeCoin:
        case DCMessageTypeAddStation:
            /**
             *  TODO: 这些消息类型不做任何操作
             **/
            break;
            
        case DCMessageTypeOrder: {
            DCOrderDetailViewController *vc = [DCOrderDetailViewController storyboardInstantiateWithIdentifier:@"DCOrderDetailViewController"];
            vc.orderId = message.typeId;
            [self.navigationController pushViewController:vc animated:YES];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
            break;
            
        case DCMessageTypeArticle: {
            CircleArticleViewController *vc = [CircleArticleViewController storyboardInstantiateWithIdentifierInAttention:@"CircleArticleViewController"];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [DCSiteApi getArticleInfo:message.typeId userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if (![webResponse isSuccess]) {
                    [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                    return;
                }
                [hud hide:YES];
                DCArticle *article = [[DCArticle alloc] initWithDict:webResponse.result];
                vc.article = article;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
            break;
            
            default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static DCMessageCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:HSSYMessageCellIdentifier];
    });
    
    sizingCell.frameWidth = self.view.frameWidth;
    [sizingCell layoutIfNeeded];
    sizingCell.contentLabel.preferredMaxLayoutWidth = sizingCell.contentLabel.frameWidth;
    
    DCMessage *item = self.dataSource.items[indexPath.row];
    [sizingCell configureForMessage:item];

    [sizingCell layoutIfNeeded];
    CGFloat height = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1.0f;// Add 1.0f for the cell separator height
    return height;
}

#pragma mark - Notification
- (void)observeNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidRead:) name:NOTIFICATION_MESSAGE_DID_READ object:nil];
}

- (void)messageDidRead:(NSNotification *)note {
    DCMessage *message = note.object;
    NSUInteger index = [self.messageList indexOfObject:message];
    if (index != NSNotFound) {
        DCMessage *message = self.messageList[index];
        message.status = DCMessageStatusRead;
        [self.tableView reloadData];
    }
}
#pragma mark - rigthBarButtonItem_action
- (void)listStateInformationAvtion:(id)sender{
    NSInteger number = [DCDefault loadNewMessageCount];
    NSString *numStr = [NSString stringWithFormat:@"未读(%d)", (int)number];
    
    if (self.listStateInformation) {
        [self.listStateInformation dismiss];
    } else {
        NSInteger index = 0;
        if (self.messageListState == DCMessageStatusUnread) {
            index = 1;
        }
        ListView *filterList = [[ListView alloc] initWithItems:@[@"显示所有", numStr, @"清空所有"] selectedIndex:index];
        DropListView *dropList = [[DropListView alloc] initWithListView:filterList];
        [dropList dropListAlignRightOnView:self.view topSpace:self.topLayoutGuide.length];
        self.listStateInformation = dropList;
        
        typeof(self) __weak weakSelf = self;
        filterList.didSelectIndex = ^(NSInteger index) {
            [weakSelf.listStateInformation dismiss];
            if(index == 0){
                self.messageListState = DCMessageStatusAll;
                [self fetchMessageListWithStartIndex:1 count:DCMessageLoadCount];
            } else if (index == 1) {//未读
                self.messageListState = DCMessageStatusUnread;
                [self fetchMessageListWithStartIndex:1 count:DCMessageLoadCount];
            }else if(index == 2){//清空all    注意修改回来   2
                [self.requestTask cancel];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否清空所有消息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"清空", nil];
                [alert show];
                
            }
        };
    }
}

#pragma mark - Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        typeof(self) __weak weakSelf = self;
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [DCSiteApi postClearMessageListWithMessageIds:nil type:DCMessageDeleteTypeAll userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            typeof(weakSelf) __strong strongSelf = weakSelf;
            if (![webResponse isSuccess]) {
                [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                return;
            }
            
            [DCDefault saveNewMessageCount:0];
            
            strongSelf.messageList = [NSArray array];
            strongSelf.tableView.arrayDataSource.items = strongSelf.messageList;
            [strongSelf.tableView reloadData];
            strongSelf.tableView.footer.hidden = YES;
            strongSelf.tableEmptyView.hidden = (strongSelf.messageList.count > 0);
            [hud hide:YES];
        }];
    }
}

@end
