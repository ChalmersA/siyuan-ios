//
//  HSSYSelectAreaViewController.h
//  Charging
//
//  Created by  Blade on 4/1/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "BaiduMapKits.h"

@interface DCSelectDetailAreaViewController : DCViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate,UITextFieldDelegate, BMKPoiSearchDelegate>
@property (nonatomic, retain) NSString* defaultCity;
@property (nonatomic, retain) BMKPoiInfo* choosenPoiInfo;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITextField *searchTextFieldBar;
@property (weak, nonatomic) IBOutlet UIButton *lookingSearchButton;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIView *searchLayoutView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
